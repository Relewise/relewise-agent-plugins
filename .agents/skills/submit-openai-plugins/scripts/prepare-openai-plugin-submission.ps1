[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('relewise', 'relewise-developer')][string] $Plugin,
    [Parameter(Mandatory)][ValidatePattern('^\d+\.\d+\.\d+$')][string] $Version,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $ReleaseNotes,
    [ValidatePattern('^https://')][string] $DemoRecordingUrl,
    [string] $RepositoryRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path,
    [string] $OutputRoot
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Assert-File([string] $Path, [string] $Label) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "Missing $Label`: $Path" }
}

function Resolve-RepositoryPath([string] $RelativePath) {
    $root = [IO.Path]::GetFullPath($RepositoryRoot).TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
    $resolved = [IO.Path]::GetFullPath((Join-Path $RepositoryRoot $RelativePath))
    if (-not $resolved.StartsWith($root, [StringComparison]::OrdinalIgnoreCase)) { throw "Path escapes repository: $RelativePath" }
    return $resolved
}

function Get-PngDimensions([string] $Path) {
    $bytes = [IO.File]::ReadAllBytes($Path)
    $signature = @(0x89,0x50,0x4e,0x47,0x0d,0x0a,0x1a,0x0a)
    if ($bytes.Length -lt 24) { throw "PNG is too short: $Path" }
    for ($i = 0; $i -lt $signature.Count; $i++) { if ($bytes[$i] -ne $signature[$i]) { throw "Expected a PNG asset: $Path" } }
    $width = ([int]$bytes[16] -shl 24) -bor ([int]$bytes[17] -shl 16) -bor ([int]$bytes[18] -shl 8) -bor [int]$bytes[19]
    $height = ([int]$bytes[20] -shl 24) -bor ([int]$bytes[21] -shl 16) -bor ([int]$bytes[22] -shl 8) -bor [int]$bytes[23]
    return [ordered]@{ width = $width; height = $height }
}

$metadataPath = Resolve-RepositoryPath "marketplace/$Plugin/openai/submission.json"
$schemaPath = Resolve-RepositoryPath 'contracts/openai-plugin-submission.schema.json'
$pluginRoot = Resolve-RepositoryPath "plugins/$Plugin"
Assert-File $metadataPath 'submission metadata'
Assert-File $schemaPath 'submission schema'

if (-not (Test-Json -LiteralPath $metadataPath -SchemaFile $schemaPath)) { throw "$Plugin submission metadata does not match the schema." }
$metadata = Get-Content -Raw -LiteralPath $metadataPath | ConvertFrom-Json -AsHashtable

if ($metadata.starterPrompts.Count -gt 3) { throw 'The portal supports at most three starter prompts.' }
if ($metadata.testCases.Count -ne 5) { throw 'Exactly five positive test cases are required.' }
if ($metadata.negativeTestCases.Count -ne 3) { throw 'Exactly three negative test cases are required.' }

$mcpPath = Join-Path $pluginRoot 'mcp.json'
Assert-File $mcpPath 'portable MCP configuration'
$mcp = Get-Content -Raw -LiteralPath $mcpPath | ConvertFrom-Json -AsHashtable
$server = $mcp.mcpServers[$metadata.mcp.serverName]
if ($null -eq $server -or $server.url.TrimEnd('/') -ne $metadata.mcp.url.TrimEnd('/')) {
    throw "MCP endpoint mismatch between submission metadata and plugins/$Plugin/mcp.json."
}

$directoryIcon = Resolve-RepositoryPath $metadata.assets.directoryIcon
$composerIcon = Resolve-RepositoryPath $metadata.assets.composerIcon
Assert-File $directoryIcon 'directoryIcon'
Assert-File $composerIcon 'composerIcon'
$directoryDimensions = Get-PngDimensions $directoryIcon
$composerDimensions = Get-PngDimensions $composerIcon
if ($directoryDimensions.width -ne $directoryDimensions.height -or $directoryDimensions.width -lt 256) { throw 'Directory icon must be a square PNG at least 256 x 256 px.' }
if ($composerDimensions.width -ne $composerDimensions.height -or $composerDimensions.width -lt 48) { throw 'Composer icon must be a square PNG at least 48 x 48 px.' }
Assert-File (Resolve-RepositoryPath $metadata.reviewerSetup) 'reviewer setup'
foreach ($skill in $metadata.skills) {
    $skillRoot = Join-Path $pluginRoot "skills/$skill"
    Assert-File (Join-Path $skillRoot 'SKILL.md') "skill $skill"
}

if ([string]::IsNullOrWhiteSpace($OutputRoot)) { $OutputRoot = Join-Path $RepositoryRoot "artifacts/openai-submission/$Plugin/$Version" }
$OutputRoot = [IO.Path]::GetFullPath($OutputRoot)
New-Item -ItemType Directory -Force -Path $OutputRoot, (Join-Path $OutputRoot 'skills'), (Join-Path $OutputRoot 'assets') | Out-Null

$skillArtifacts = @()
foreach ($skill in $metadata.skills) {
    $skillRoot = Join-Path $pluginRoot "skills/$skill"
    $zipPath = Join-Path $OutputRoot "skills/$skill.zip"
    if (Test-Path -LiteralPath $zipPath) { Remove-Item -LiteralPath $zipPath -Force }
    Compress-Archive -Path (Join-Path $skillRoot '*') -DestinationPath $zipPath -CompressionLevel Optimal
    $skillArtifacts += [ordered]@{ name = $skill; path = "skills/$skill.zip"; sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $zipPath).Hash.ToLowerInvariant() }
}

$pluginZip = Join-Path $OutputRoot "$Plugin-plugin.zip"
if (Test-Path -LiteralPath $pluginZip) { Remove-Item -LiteralPath $pluginZip -Force }
Compress-Archive -Path (Join-Path $pluginRoot '*') -DestinationPath $pluginZip -CompressionLevel Optimal

Copy-Item -LiteralPath $directoryIcon -Destination (Join-Path $OutputRoot 'assets/directory-icon.png') -Force
Copy-Item -LiteralPath $composerIcon -Destination (Join-Path $OutputRoot 'assets/composer-icon.png') -Force

$toolJustifications = [ordered]@{}
if ($metadata.mcp.ContainsKey('toolCatalog')) {
    $catalogPath = Resolve-RepositoryPath $metadata.mcp.toolCatalog
    Assert-File $catalogPath 'MCP tool catalog'
    $catalog = Get-Content -Raw -LiteralPath $catalogPath | ConvertFrom-Json -AsHashtable
    foreach ($tool in $catalog.tools) {
        $annotations = $tool.annotations
        $toolJustifications[$tool.name] = [ordered]@{
            read_only_justification = if ($annotations.readOnlyHint) { "This tool reads authorized Relewise data and does not change external state." } else { "This tool can change authorized Relewise state as described by its tool metadata; readOnlyHint is false." }
            open_world_justification = if ($annotations.openWorldHint) { "This tool can interact with open-ended external entities as described by its metadata." } else { "This tool is limited to the authenticated user's bounded Relewise account and Datasets; it does not access the open web." }
            destructive_justification = if ($annotations.destructiveHint) { "This tool can cause the irreversible or overwrite behavior described by its metadata; destructiveHint is true." } else { "This tool does not delete, overwrite, revoke, send, or cause another irreversible side effect." }
        }
    }
} elseif ($metadata.mcp.ContainsKey('toolNames')) {
    foreach ($toolName in $metadata.mcp.toolNames) {
        $toolJustifications[$toolName] = [ordered]@{
            read_only_justification = $metadata.toolJustificationDefaults.readOnly
            open_world_justification = $metadata.toolJustificationDefaults.openWorld
            destructive_justification = $metadata.toolJustificationDefaults.destructive
        }
    }
}

$auth = if ($metadata.mcp.authentication -eq 'NONE') { @([ordered]@{ type = 'NONE' }) } else { @([ordered]@{ type = 'OAUTH' }) }
$portal = [ordered]@{
    display_name = $metadata.displayName
    version = $Version
    subtitle = $metadata.subtitle
    description = $metadata.description
    developer_identity_name = $metadata.developerIdentity
    developer_name = $metadata.developerName
    entity_type = $metadata.entityType
    plugin_category = $metadata.category.ToLowerInvariant()
    branding = [ordered]@{
        customer_support = $metadata.branding.customerSupport
        privacy_policy = $metadata.branding.privacyPolicy
        terms_of_service = $metadata.branding.termsOfService
        website = $metadata.branding.website
    }
    brand_color = $metadata.assets.brandColor
    mcp_url = $metadata.mcp.url
    supported_auth = $auth
    screenshots = @($metadata.starterPrompts | ForEach-Object { [ordered]@{ user_prompt = $_ } })
    test_cases = @($metadata.testCases | ForEach-Object { [ordered]@{ description=$_.description; user_prompt=$_.userPrompt; tools_triggered=$_.toolsTriggered; expected_output=$_.expectedOutput } })
    negative_test_cases = @($metadata.negativeTestCases | ForEach-Object { [ordered]@{ description=$_.description; user_prompt=$_.userPrompt; expected_output=$_.expectedBehavior } })
    tool_justifications = $toolJustifications
    release_notes = $ReleaseNotes
    demo_recording_url = if ([string]::IsNullOrWhiteSpace($DemoRecordingUrl)) { $null } else { $DemoRecordingUrl }
    country_filtering = if ($metadata.availability -eq 'all') { $null } else { $metadata.availability }
    intended_audience = $metadata.policy.intendedAudience
    commerce_enabled = $metadata.policy.commerceEnabled
    no_serving_or_displaying_advertisements = -not $metadata.policy.advertising
    no_money_transfers_crypto_or_investment_trades = -not $metadata.policy.moneyTransfers
    not_marketed_to_children_under_13 = -not $metadata.policy.marketedToChildrenUnder13
}
$portal | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath (Join-Path $OutputRoot 'chatgpt-app-submission.json') -Encoding utf8
Copy-Item -LiteralPath $metadataPath -Destination (Join-Path $OutputRoot 'canonical-submission.json') -Force
Copy-Item -LiteralPath (Resolve-RepositoryPath $metadata.reviewerSetup) -Destination (Join-Path $OutputRoot 'reviewer-setup.md') -Force

$reviewerCases = @("# Reviewer test cases: $($metadata.displayName)", '', '## Positive cases', '')
$caseNumber = 0
foreach ($case in $metadata.testCases) {
    $caseNumber++
    $reviewerCases += @("$caseNumber. **$($case.description)**", "   - Prompt: ``$($case.userPrompt)``", "   - Tools: $($case.toolsTriggered)", "   - Expected: $($case.expectedOutput)", '')
}
$reviewerCases += @('## Negative cases', '')
$caseNumber = 0
foreach ($case in $metadata.negativeTestCases) {
    $caseNumber++
    $reviewerCases += @("$caseNumber. **$($case.description)**", "   - Prompt: ``$($case.userPrompt)``", "   - Expected: $($case.expectedBehavior)", '')
}
$reviewerCases | Set-Content -LiteralPath (Join-Path $OutputRoot 'reviewer-test-cases.md') -Encoding utf8

$manifest = [ordered]@{
    plugin = $Plugin
    version = $Version
    generatedAtUtc = [DateTimeOffset]::UtcNow.ToString('O')
    sourcePluginVersion = (Get-Content -Raw -LiteralPath (Join-Path $pluginRoot 'plugin.json') | ConvertFrom-Json).version
    mcpConfiguration = 'plugins/' + $Plugin + '/mcp.json'
    fullPlugin = [ordered]@{ path="$Plugin-plugin.zip"; sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $pluginZip).Hash.ToLowerInvariant() }
    skills = $skillArtifacts
    assets = @('assets/directory-icon.png','assets/composer-icon.png')
    reviewerSetup = 'reviewer-setup.md'
    reviewerTestCases = 'reviewer-test-cases.md'
    canonicalSubmission = 'canonical-submission.json'
}
$manifest | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath (Join-Path $OutputRoot 'artifact-manifest.json') -Encoding utf8

$recordingStatus = if ($DemoRecordingUrl) { '[x] Demo recording URL supplied; verify it still covers the submitted behavior.' } else { '[ ] Record or approve a reusable demo video and enter its HTTPS URL.' }
$checklist = @"
# Manual OpenAI submission checklist: $($metadata.displayName) $Version

- [ ] Confirm the branch has the intended source changes and synchronized marketplace payload/version.
- [ ] Confirm Apps Management write access and the verified Relewise business identity.
- [ ] Create the correct portal draft: Create plugin / With MCP for an initial submission, or plugin-level Create Draft for an update.
- [ ] Review every value imported from chatgpt-app-submission.json.
- [ ] Upload directory and composer icons from assets/.
- [ ] Configure and scan $($metadata.mcp.url); resolve all validation errors.
- [ ] Compare every discovered tool annotation and justification with actual server behavior.
- [ ] Upload every ZIP under skills/; confirm scripts, references, and assets are present.
- [ ] Run all five positive and three negative reviewer cases.
- [ ] Supply reviewer access through the secure portal channel; never commit credentials.
- $recordingStatus
- [ ] Review availability, release notes, policies, privacy disclosures, and attestations.
- [ ] Obtain authorization immediately before Submit for Review.
- [ ] After approval, obtain authorization immediately before Publish.
"@
$checklist | Set-Content -LiteralPath (Join-Path $OutputRoot 'manual-checklist.md') -Encoding utf8

Write-Host "Prepared OpenAI submission artifacts: $OutputRoot"

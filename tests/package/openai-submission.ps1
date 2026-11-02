param([string] $RepositoryRoot = (Resolve-Path "$PSScriptRoot/../..").Path)
$ErrorActionPreference = 'Stop'
$testRoot = Join-Path ([IO.Path]::GetTempPath()) "relewise-openai-submission-$([guid]::NewGuid())"
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Assert-ArchiveContainsTree([string] $ArchivePath, [string] $SourceRoot) {
    $archive = [IO.Compression.ZipFile]::OpenRead($ArchivePath)
    try {
        $entries = @($archive.Entries | Where-Object { -not [string]::IsNullOrEmpty($_.Name) } | ForEach-Object { $_.FullName.Replace('\', '/') })
        $sourceFiles = @(Get-ChildItem -LiteralPath $SourceRoot -Recurse -File | ForEach-Object { [IO.Path]::GetRelativePath($SourceRoot, $_.FullName).Replace('\', '/') })
        foreach ($sourceFile in $sourceFiles) { if ($entries -notcontains $sourceFile) { throw "$ArchivePath is missing $sourceFile" } }
    } finally { $archive.Dispose() }
}
. (Join-Path $RepositoryRoot '.agents/skills/submit-openai-plugins/scripts/get-reviewed-tool-justifications.ps1')
function Assert-RejectedToolReview([scriptblock] $Mutation, [string] $ExpectedMessage) {
    $catalog = Get-Content -Raw -LiteralPath (Join-Path $RepositoryRoot 'generated/mcp-tools.json') | ConvertFrom-Json -AsHashtable
    $reviewed = Get-Content -Raw -LiteralPath (Join-Path $RepositoryRoot 'marketplace/relewise/openai/tool-justifications.json') | ConvertFrom-Json -AsHashtable
    & $Mutation $catalog $reviewed
    try { $null = Get-ReviewedToolJustifications $catalog $reviewed }
    catch {
        if ($_.Exception.Message -notlike "*$ExpectedMessage*") { throw "Expected '$ExpectedMessage', got: $($_.Exception.Message)" }
        return
    }
    throw "Invalid tool review was accepted: $ExpectedMessage"
}
try {
    foreach ($hint in @('readOnlyHint', 'destructiveHint', 'openWorldHint')) {
        Assert-RejectedToolReview { param($catalog, $reviewed) $catalog.tools[0].annotations.Remove($hint) } "boolean $hint"
        Assert-RejectedToolReview { param($catalog, $reviewed) $catalog.tools[0].annotations[$hint] = $null } "boolean $hint"
        Assert-RejectedToolReview { param($catalog, $reviewed) $catalog.tools[0].annotations[$hint] = 'false' } "boolean $hint"
        Assert-RejectedToolReview { param($catalog, $reviewed) $catalog.tools[0].annotations[$hint] = -not $catalog.tools[0].annotations[$hint] } "$hint changed"
        Assert-RejectedToolReview { param($catalog, $reviewed) $reviewed[$catalog.tools[0].name].annotations.Remove($hint) } "reviewed boolean $hint"
    }
    foreach ($reason in @('readOnly', 'destructive', 'openWorld')) {
        Assert-RejectedToolReview { param($catalog, $reviewed) $reviewed[$catalog.tools[0].name].Remove($reason) } "non-empty $reason explanation"
        Assert-RejectedToolReview { param($catalog, $reviewed) $reviewed[$catalog.tools[0].name][$reason] = ' ' } "non-empty $reason explanation"
    }
    Assert-RejectedToolReview { param($catalog, $reviewed) $reviewed.Remove($catalog.tools[0].name) } 'Missing reviewed explanations'
    Assert-RejectedToolReview { param($catalog, $reviewed) $reviewed['removed_tool'] = $reviewed[$catalog.tools[0].name] } 'unknown MCP tool'
    Assert-RejectedToolReview { param($catalog, $reviewed) $catalog.tools += $catalog.tools[0] } 'duplicate MCP tool'
    foreach ($plugin in @('relewise', 'relewise-developer')) {
        $metadataPath = Join-Path $RepositoryRoot "marketplace/$plugin/openai/submission.json"
        $schemaPath = Join-Path $RepositoryRoot 'contracts/openai-plugin-submission.schema.json'
        if (-not (Test-Json -LiteralPath $metadataPath -SchemaFile $schemaPath)) { throw "$plugin metadata is invalid." }
        foreach ($submissionMode in @('Initial', 'Update')) {
        $output = Join-Path $testRoot "$plugin-$submissionMode"
        & (Join-Path $RepositoryRoot '.agents/skills/submit-openai-plugins/scripts/prepare-openai-plugin-submission.ps1') `
            -Plugin $plugin -SubmissionMode $submissionMode -Version '9.9.9' -ReleaseNotes 'Automated packaging validation.' -RepositoryRoot $RepositoryRoot -OutputRoot $output
        foreach ($required in @('chatgpt-app-submission.json','canonical-submission.json','artifact-manifest.json','manual-checklist.md','reviewer-setup.md','reviewer-test-cases.md',"$plugin-plugin.zip",'assets/directory-icon.png','assets/composer-icon.png')) {
            if (-not (Test-Path -LiteralPath (Join-Path $output $required) -PathType Leaf)) { throw "$plugin missing artifact: $required" }
        }
        $submission = Get-Content -Raw -LiteralPath (Join-Path $output 'chatgpt-app-submission.json') | ConvertFrom-Json
        if ($submission.version -ne '9.9.9' -or $submission.test_cases.Count -ne 5 -or $submission.negative_test_cases.Count -ne 3 -or $submission.screenshots.Count -gt 3) {
            throw "$plugin generated portal metadata has invalid counts or version."
        }
        $manifest = Get-Content -Raw -LiteralPath (Join-Path $output 'artifact-manifest.json') | ConvertFrom-Json
        if ($manifest.submissionMode -ne $submissionMode) { throw "$plugin did not preserve submission mode $submissionMode." }
        if ($manifest.skills.Count -ne (Get-Content -Raw -LiteralPath $metadataPath | ConvertFrom-Json).skills.Count) { throw "$plugin did not package every skill." }
        $checklist = Get-Content -Raw -LiteralPath (Join-Path $output 'manual-checklist.md')
        $expectedAction = if ($submissionMode -eq 'Initial') { 'Create plugin / With MCP' } else { 'plugin-level Create Draft' }
        if ($checklist -notlike "*$expectedAction*") { throw "$plugin $submissionMode checklist has the wrong portal action." }
        Assert-ArchiveContainsTree (Join-Path $output "$plugin-plugin.zip") (Join-Path $RepositoryRoot "plugins/$plugin")
        foreach ($skill in $manifest.skills.name) {
            Assert-ArchiveContainsTree (Join-Path $output "skills/$skill.zip") (Join-Path $RepositoryRoot "plugins/$plugin/skills/$skill")
        }
        if ($plugin -eq 'relewise') {
            $catalog = Get-Content -Raw -LiteralPath (Join-Path $RepositoryRoot 'generated/mcp-tools.json') | ConvertFrom-Json
            $knownTools = $catalog.tools.name
            $declaredTools = $submission.test_cases.tools_triggered -split ', ' | Sort-Object -Unique
            foreach ($tool in $declaredTools) { if ($knownTools -notcontains $tool) { throw "Unknown Relewise test tool: $tool" } }
            if (@($submission.tool_justifications.PSObject.Properties).Count -ne $catalog.toolCount) { throw 'Relewise must generate a justification for every MCP tool.' }
            $reviewed = Get-Content -Raw -LiteralPath (Join-Path $RepositoryRoot 'marketplace/relewise/openai/tool-justifications.json') | ConvertFrom-Json -AsHashtable
            $reviewedSource = Join-Path $RepositoryRoot 'marketplace/relewise/openai/tool-justifications.json'
            $reviewedArtifact = Join-Path $output $manifest.reviewedToolAnnotations
            if ((Get-FileHash -LiteralPath $reviewedSource).Hash -ne (Get-FileHash -LiteralPath $reviewedArtifact).Hash) {
                throw 'Submission artifacts must preserve the reviewed annotations and explanations.'
            }
            foreach ($tool in $knownTools) {
                $actual = $submission.tool_justifications.$tool
                if ($actual.read_only_justification -cne $reviewed[$tool].readOnly -or
                    $actual.destructive_justification -cne $reviewed[$tool].destructive -or
                    $actual.open_world_justification -cne $reviewed[$tool].openWorld) {
                    throw "$tool did not preserve its reviewed explanations."
                }
            }
        } elseif (@($submission.tool_justifications.PSObject.Properties).Count -ne 5) {
            throw 'Relewise Developer must generate a justification for every MCP tool.'
        }
        }
    }
    Write-Host 'OpenAI submission metadata and deterministic packaging validated.'
} finally {
    $resolved = [IO.Path]::GetFullPath($testRoot)
    if ($resolved.StartsWith([IO.Path]::GetFullPath([IO.Path]::GetTempPath()), [StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $resolved)) {
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}

param(
    [Parameter(Mandatory = $true)]
    [string] $MarketplaceRoot
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$resolvedMarketplaceRoot = (Resolve-Path -LiteralPath $MarketplaceRoot).Path
$marketplacePath = Join-Path $resolvedMarketplaceRoot '.agents\plugins\marketplace.json'
$marketplace = Get-Content -Raw -LiteralPath $marketplacePath | ConvertFrom-Json

if ($marketplace.name -ne 'relewise') { throw 'Unexpected Codex marketplace name.' }
if ($marketplace.plugins.Count -ne 1) { throw 'Codex marketplace must contain exactly one plugin.' }
$entry = $marketplace.plugins[0]
if ($entry.name -ne 'relewise') { throw 'Unexpected Codex marketplace plugin name.' }
if ($entry.source.source -ne 'local' -or $entry.source.path -ne './plugins/relewise') {
    throw 'Codex marketplace does not reference the repository-backed plugin.'
}
if ($entry.policy.installation -ne 'AVAILABLE' -or $entry.policy.authentication -ne 'ON_INSTALL') {
    throw 'Codex marketplace policy is incomplete.'
}

$vendorMarketplaces = @(
    @{ Vendor = 'Claude Code'; Path = '.claude-plugin\marketplace.json' },
    @{ Vendor = 'GitHub Copilot CLI'; Path = '.github\plugin\marketplace.json' }
)
foreach ($vendorMarketplace in $vendorMarketplaces) {
    $catalog = Get-Content -Raw -LiteralPath (Join-Path $resolvedMarketplaceRoot $vendorMarketplace.Path) | ConvertFrom-Json
    if ($catalog.name -ne 'relewise' -or $catalog.owner.name -ne 'Relewise') {
        throw "$($vendorMarketplace.Vendor) marketplace metadata is invalid."
    }
    if ($catalog.plugins.Count -ne 1 -or $catalog.plugins[0].name -ne 'relewise') {
        throw "$($vendorMarketplace.Vendor) marketplace must contain exactly the Relewise plugin."
    }
    if ($catalog.plugins[0].source -ne './plugins/relewise') {
        throw "$($vendorMarketplace.Vendor) marketplace does not reference the canonical plugin."
    }
}

$pluginRoot = Join-Path $resolvedMarketplaceRoot 'plugins\relewise'
$manifest = Get-Content -Raw -LiteralPath (Join-Path $pluginRoot '.codex-plugin\plugin.json') | ConvertFrom-Json
if ($manifest.name -ne $entry.name) { throw 'Marketplace and plugin manifest names do not match.' }
$portableManifest = Get-Content -Raw -LiteralPath (Join-Path $pluginRoot 'plugin.json') | ConvertFrom-Json
$claudeManifest = Get-Content -Raw -LiteralPath (Join-Path $pluginRoot '.claude-plugin\plugin.json') | ConvertFrom-Json
if ($portableManifest.name -ne 'relewise' -or $claudeManifest.name -ne 'relewise') {
    throw 'Vendor plugin manifests do not identify the canonical Relewise plugin.'
}
if ($manifest.version -ne $portableManifest.version -or $manifest.version -ne $claudeManifest.version) {
    throw 'Committed vendor plugin manifest versions are not synchronized.'
}
if (-not $claudeManifest.userConfig.agent_gateway_token.sensitive -or -not $claudeManifest.userConfig.agent_gateway_token.required) {
    throw 'Claude Code manifest does not require protected Agent Gateway authentication.'
}

$canonicalSkills = Get-ChildItem -LiteralPath (Join-Path $repositoryRoot 'plugins\relewise\skills') -Directory
$installedSkills = Get-ChildItem -LiteralPath (Join-Path $pluginRoot 'skills') -Directory
if ($canonicalSkills.Count -ne $installedSkills.Count) { throw 'Repository-backed Codex plugin does not contain every canonical skill.' }
foreach ($canonicalSkill in $canonicalSkills) {
    $installedSkillPath = Join-Path $pluginRoot "skills\$($canonicalSkill.Name)\SKILL.md"
    if (-not (Test-Path -LiteralPath $installedSkillPath)) { throw "Missing Codex skill '$($canonicalSkill.Name)'." }
    $canonicalContent = Get-Content -Raw -LiteralPath (Join-Path $canonicalSkill.FullName 'SKILL.md')
    $installedContent = Get-Content -Raw -LiteralPath $installedSkillPath
    if (-not $installedContent.StartsWith($canonicalContent)) { throw "Codex skill '$($canonicalSkill.Name)' is stale." }
    if (-not $installedContent.Contains('../../bin/relewise-agent')) { throw "Codex skill '$($canonicalSkill.Name)' cannot locate its bundled CLI." }
}

$runtimeFiles = @(
    'libexec\win-x64\relewise-agent.exe',
    'libexec\linux-x64\relewise-agent',
    'libexec\linux-arm64\relewise-agent',
    'libexec\osx-x64\relewise-agent',
    'libexec\osx-arm64\relewise-agent'
)
foreach ($runtimeFile in $runtimeFiles) {
    $runtimePath = Join-Path $pluginRoot $runtimeFile
    if (-not (Test-Path -LiteralPath $runtimePath)) { throw "Missing Codex runtime '$runtimeFile'." }
    if ((Get-Item -LiteralPath $runtimePath).Length -lt 1MB) { throw "Codex runtime '$runtimeFile' is unexpectedly small." }
}

$currentExecutable = if ($IsWindows) {
    Join-Path $pluginRoot 'libexec\win-x64\relewise-agent.exe'
} elseif ($IsMacOS) {
    $rid = if ([Runtime.InteropServices.RuntimeInformation]::OSArchitecture -eq 'Arm64') { 'osx-arm64' } else { 'osx-x64' }
    Join-Path $pluginRoot "libexec\$rid\relewise-agent"
} else {
    $rid = if ([Runtime.InteropServices.RuntimeInformation]::OSArchitecture -eq 'Arm64') { 'linux-arm64' } else { 'linux-x64' }
    Join-Path $pluginRoot "libexec\$rid\relewise-agent"
}
$versionResponse = (& $currentExecutable --version | Out-String) | ConvertFrom-Json
if (-not $versionResponse.success -or $versionResponse.data.name -ne 'relewise-agent') {
    throw 'The bundled Codex runtime did not return a valid version response.'
}

Write-Host "Repository marketplace tests passed for Codex, Claude Code and GitHub Copilot CLI at version $($manifest.version)"

param(
    [Parameter(Mandatory = $true)]
    [string] $MarketplaceRoot,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$')]
    [string] $Version
)

$ErrorActionPreference = 'Stop'
$resolvedMarketplaceRoot = (Resolve-Path -LiteralPath $MarketplaceRoot).Path
$pluginRoot = Join-Path $resolvedMarketplaceRoot 'plugins\relewise'

foreach ($catalog in @('.agents\plugins\marketplace.json', '.claude-plugin\marketplace.json', '.github\plugin\marketplace.json')) {
    $catalogPath = Join-Path $resolvedMarketplaceRoot $catalog
    if (-not (Test-Path -LiteralPath $catalogPath -PathType Leaf)) { throw "Portable marketplace is missing $catalog." }
    $catalogJson = Get-Content -Raw -LiteralPath $catalogPath | ConvertFrom-Json
    if ($catalogJson.name -ne 'relewise') { throw "$catalog must identify the relewise marketplace." }
    if ($catalogJson.plugins.Count -ne 1 -or $catalogJson.plugins[0].name -ne 'relewise') { throw "$catalog must contain only the Relewise plugin." }
}

foreach ($manifest in @('plugin.json', '.claude-plugin\plugin.json', '.codex-plugin\plugin.json')) {
    $manifestJson = Get-Content -Raw -LiteralPath (Join-Path $pluginRoot $manifest) | ConvertFrom-Json
    if ($manifestJson.version -ne $Version) { throw "$manifest version is not $Version." }
}

foreach ($runtime in @('win-x64', 'linux-x64', 'linux-arm64', 'osx-x64', 'osx-arm64')) {
    $executableName = if ($runtime -eq 'win-x64') { 'relewise-agent.exe' } else { 'relewise-agent' }
    if (-not (Test-Path -LiteralPath (Join-Path $pluginRoot "libexec\$runtime\$executableName") -PathType Leaf)) {
        throw "Portable marketplace is missing its $runtime executable."
    }
}

foreach ($requiredFile in @('README.md', 'LICENSE', 'plugins\relewise\scripts\relewise-agent')) {
    if (-not (Test-Path -LiteralPath (Join-Path $resolvedMarketplaceRoot $requiredFile) -PathType Leaf)) {
        throw "Portable marketplace is missing $requiredFile."
    }
}

foreach ($repositoryMetadata in @('runtime-source.sha256', 'runtime-version.txt', 'source.sha256')) {
    if (Test-Path -LiteralPath (Join-Path $pluginRoot ".codex-plugin\$repositoryMetadata")) {
        throw "Portable marketplace must not contain repository-only metadata $repositoryMetadata."
    }
}

Write-Host 'Portable marketplace tests passed.'

param(
    [Parameter(Mandatory = $true)]
    [string] $ExecutablesRoot,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$')]
    [string] $Version,

    [string] $OutputRoot
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$resolvedExecutablesRoot = (Resolve-Path -LiteralPath $ExecutablesRoot).Path
if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
    $OutputRoot = Join-Path $repositoryRoot 'artifacts\portable-marketplace'
}
$resolvedOutputRoot = [IO.Path]::GetFullPath($OutputRoot)
$marketplaceRoot = Join-Path $resolvedOutputRoot 'relewise-agent-plugins'

if (Test-Path -LiteralPath $marketplaceRoot) {
    Remove-Item -LiteralPath $marketplaceRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $marketplaceRoot | Out-Null

foreach ($catalog in @('.agents\plugins', '.claude-plugin', '.github\plugin')) {
    $source = Join-Path $repositoryRoot $catalog
    $destination = Join-Path $marketplaceRoot $catalog
    New-Item -ItemType Directory -Force -Path (Split-Path $destination) | Out-Null
    Copy-Item -LiteralPath $source -Destination (Split-Path $destination) -Recurse
}

$pluginsRoot = Join-Path $marketplaceRoot 'plugins'
New-Item -ItemType Directory -Force -Path $pluginsRoot | Out-Null
Copy-Item -LiteralPath (Join-Path $repositoryRoot 'plugins\relewise') -Destination $pluginsRoot -Recurse
$pluginRoot = Join-Path $pluginsRoot 'relewise'
Remove-Item -LiteralPath (Join-Path $pluginRoot 'libexec') -Recurse -Force
New-Item -ItemType Directory -Force -Path (Join-Path $pluginRoot 'libexec') | Out-Null
foreach ($repositoryMetadata in @('runtime-source.sha256', 'runtime-version.txt', 'source.sha256')) {
    Remove-Item -LiteralPath (Join-Path $pluginRoot ".codex-plugin\$repositoryMetadata") -Force
}

foreach ($runtime in @('win-x64', 'linux-x64', 'linux-arm64', 'osx-x64', 'osx-arm64')) {
    $executableName = if ($runtime -eq 'win-x64') { 'relewise-agent.exe' } else { 'relewise-agent' }
    $runtimeRoot = Join-Path $resolvedExecutablesRoot $runtime
    if (-not (Test-Path -LiteralPath $runtimeRoot -PathType Container)) {
        $runtimeRoots = @(Get-ChildItem -LiteralPath $resolvedExecutablesRoot -Directory | Where-Object { $_.Name.EndsWith("-$runtime", [StringComparison]::Ordinal) })
        if ($runtimeRoots.Count -ne 1) {
            throw "Expected exactly one downloaded artifact directory for $runtime under $resolvedExecutablesRoot."
        }
        $runtimeRoot = $runtimeRoots[0].FullName
    }
    $executablePath = Join-Path $runtimeRoot $executableName
    if (-not (Test-Path -LiteralPath $executablePath -PathType Leaf)) {
        throw "Missing $runtime executable: $executablePath"
    }
    $runtimeDestination = Join-Path $pluginRoot "libexec\$runtime"
    New-Item -ItemType Directory -Force -Path $runtimeDestination | Out-Null
    Copy-Item -LiteralPath $executablePath -Destination (Join-Path $runtimeDestination $executableName)
}

foreach ($manifest in @('plugin.json', '.claude-plugin\plugin.json', '.codex-plugin\plugin.json')) {
    & (Join-Path $PSScriptRoot 'set-manifest-version.ps1') -ManifestPath (Join-Path $pluginRoot $manifest) -Version $Version
}

Copy-Item -LiteralPath (Join-Path $repositoryRoot 'LICENSE') -Destination $marketplaceRoot
Copy-Item -LiteralPath (Join-Path $repositoryRoot 'marketplace\relewise\portable-marketplace-README.md') -Destination (Join-Path $marketplaceRoot 'README.md')

if (-not $IsWindows) {
    & chmod +x (Join-Path $pluginRoot 'scripts\relewise-agent')
    foreach ($runtime in @('linux-x64', 'linux-arm64', 'osx-x64', 'osx-arm64')) {
        & chmod +x (Join-Path $pluginRoot "libexec\$runtime\relewise-agent")
    }
}

Write-Host "Created portable marketplace at $marketplaceRoot"

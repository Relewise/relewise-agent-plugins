param(
    [Parameter(Mandatory = $true)]
    [string] $PluginRoot,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$')]
    [string] $Version
)

$ErrorActionPreference = 'Stop'
$resolvedPluginRoot = (Resolve-Path -LiteralPath $PluginRoot).Path
$manifestPath = Join-Path $resolvedPluginRoot '.claude-plugin\plugin.json'
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
    throw 'Claude plugin archive must place .claude-plugin/plugin.json at its root.'
}
$manifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
if ($manifest.name -ne 'relewise') { throw 'Claude plugin archive must contain the Relewise plugin.' }
if ($manifest.version -ne $Version) { throw "Claude plugin manifest version is not $Version." }
if (Test-Path -LiteralPath (Join-Path $resolvedPluginRoot '.claude-plugin\marketplace.json')) {
    throw 'Claude plugin archive must contain a plugin manifest, not a marketplace manifest.'
}
if (Test-Path -LiteralPath (Join-Path $resolvedPluginRoot 'bin')) {
    throw 'Claude-hosted plugins must not contain a top-level bin directory.'
}

foreach ($runtime in @('win-x64', 'linux-x64', 'linux-arm64', 'osx-x64', 'osx-arm64')) {
    $executableName = if ($runtime -eq 'win-x64') { 'relewise-agent.exe' } else { 'relewise-agent' }
    if (-not (Test-Path -LiteralPath (Join-Path $resolvedPluginRoot "libexec\$runtime\$executableName") -PathType Leaf)) {
        throw "Claude plugin archive is missing its $runtime executable."
    }
}
foreach ($requiredPath in @('skills\relewise-core\SKILL.md', 'scripts\relewise-agent', 'LICENSE')) {
    if (-not (Test-Path -LiteralPath (Join-Path $resolvedPluginRoot $requiredPath) -PathType Leaf)) {
        throw "Claude plugin archive is missing $requiredPath."
    }
}

Write-Host 'Claude plugin archive tests passed.'

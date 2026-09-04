param(
    [Parameter(Mandatory = $true)]
    [string] $PackagesRoot,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$')]
    [string] $Version
)

$ErrorActionPreference = 'Stop'
$resolvedPackagesRoot = (Resolve-Path -LiteralPath $PackagesRoot).Path
$runtimes = @('win-x64', 'linux-x64', 'linux-arm64', 'osx-x64', 'osx-arm64')
$manifestPaths = @{
    'claude' = '.claude-plugin\plugin.json'
    'github-copilot' = 'plugin.json'
    'openai' = '.codex-plugin\plugin.json'
    'google' = 'gemini-extension.json'
}

foreach ($vendor in $manifestPaths.Keys) {
    $packageRoot = Join-Path $resolvedPackagesRoot "$vendor\relewise"
    $manifest = Get-Content -Raw -LiteralPath (Join-Path $packageRoot $manifestPaths[$vendor]) | ConvertFrom-Json
    if ($manifest.version -ne $Version) { throw "$vendor manifest version is not $Version." }
    foreach ($runtime in $runtimes) {
        $executableName = if ($runtime -eq 'win-x64') { 'relewise-agent.exe' } else { 'relewise-agent' }
        if (-not (Test-Path -LiteralPath (Join-Path $packageRoot "libexec\$runtime\$executableName") -PathType Leaf)) {
            throw "$vendor package is missing its $runtime executable."
        }
    }
    $launcher = Get-Content -Raw -LiteralPath (Join-Path $packageRoot 'scripts\relewise-agent')
    foreach ($runtime in $runtimes) {
        if (-not $launcher.Contains("runtime_id=`"$runtime`"")) { throw "$vendor launcher does not select $runtime." }
    }
}

Write-Host 'Universal package tests passed.'

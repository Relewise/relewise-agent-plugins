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
    if ($vendor -eq 'google' -and -not (Test-Path -LiteralPath (Join-Path $packageRoot 'scripts\relewise-agent.ps1') -PathType Leaf)) {
        throw 'Google package is missing its Windows PowerShell launcher.'
    }
    if ($vendor -eq 'google') {
        $windowsInstruction = 'On Windows, when `../../scripts/relewise-agent.ps1` exists relative to this file, resolve it to an absolute path and use that PowerShell launcher.'
        $otherPlatformsInstruction = 'On other platforms, when `../../scripts/relewise-agent` exists, resolve it to an absolute path and use that launcher.'
        foreach ($skillFile in Get-ChildItem -LiteralPath (Join-Path $packageRoot 'skills') -Filter 'SKILL.md' -File -Recurse) {
            $skillContent = Get-Content -Raw -LiteralPath $skillFile.FullName
            if (-not $skillContent.Contains($windowsInstruction) -or -not $skillContent.Contains($otherPlatformsInstruction)) {
                throw "Universal Google skill '$($skillFile.FullName)' does not direct both Windows and non-Windows platforms to their bundled launchers."
            }
        }
    }
}

Write-Host 'Universal package tests passed.'

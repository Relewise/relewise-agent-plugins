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
    $OutputRoot = Join-Path $repositoryRoot 'artifacts\universal'
}
$resolvedOutputRoot = [IO.Path]::GetFullPath($OutputRoot)

$runtimes = @('win-x64', 'linux-x64', 'linux-arm64', 'osx-x64', 'osx-arm64')
$vendors = @('claude', 'github-copilot', 'openai', 'google')

foreach ($vendor in $vendors) {
    $vendorOutput = Join-Path $resolvedOutputRoot $vendor
    $first = $true
    foreach ($runtime in $runtimes) {
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

        $arguments = @{
            RuntimeIdentifier = $runtime
            ExecutablePath = $executablePath
            OutputRoot = $vendorOutput
        }
        if (-not $first) { $arguments.Merge = $true }
        & (Join-Path $PSScriptRoot "$vendor.ps1") @arguments
        $first = $false
    }

    $manifestPath = switch ($vendor) {
        'claude' { Join-Path $vendorOutput 'relewise\.claude-plugin\plugin.json' }
        'github-copilot' { Join-Path $vendorOutput 'relewise\plugin.json' }
        'openai' { Join-Path $vendorOutput 'relewise\.codex-plugin\plugin.json' }
        'google' { Join-Path $vendorOutput 'relewise\gemini-extension.json' }
    }
    & (Join-Path $PSScriptRoot 'set-manifest-version.ps1') -ManifestPath $manifestPath -Version $Version
}

Write-Host "Created universal vendor packages at $resolvedOutputRoot"

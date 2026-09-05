param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('claude', 'github-copilot', 'openai')]
    [string] $Vendor,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$')]
    [string] $Version,

    [string] $OutputRoot
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
    $OutputRoot = Join-Path $repositoryRoot "artifacts\$Vendor"
}
$resolvedOutputRoot = [IO.Path]::GetFullPath($OutputRoot)
$packageRoot = [IO.Path]::GetFullPath((Join-Path $resolvedOutputRoot 'relewise-developer'))
if (-not $packageRoot.StartsWith($resolvedOutputRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Resolved package path is outside the requested output root.'
}
if (Test-Path -LiteralPath $packageRoot) {
    Remove-Item -LiteralPath $packageRoot -Recurse -Force
}

$sourceRoot = Join-Path $repositoryRoot 'plugins\relewise-developer'
New-Item -ItemType Directory -Path $packageRoot | Out-Null
foreach ($directory in @('assets', 'skills')) {
    Copy-Item -LiteralPath (Join-Path $sourceRoot $directory) -Destination $packageRoot -Recurse
}
foreach ($file in @('.mcp.json', 'README.md')) {
    Copy-Item -LiteralPath (Join-Path $sourceRoot $file) -Destination $packageRoot
}
Copy-Item -LiteralPath (Join-Path $repositoryRoot 'LICENSE') -Destination $packageRoot

$manifestPath = switch ($Vendor) {
    'claude' {
        Copy-Item -LiteralPath (Join-Path $repositoryRoot 'vendors\claude\relewise-developer\.claude-plugin') -Destination $packageRoot -Recurse
        Join-Path $packageRoot '.claude-plugin\plugin.json'
    }
    'openai' {
        Copy-Item -LiteralPath (Join-Path $repositoryRoot 'vendors\openai\relewise-developer\.codex-plugin') -Destination $packageRoot -Recurse
        Join-Path $packageRoot '.codex-plugin\plugin.json'
    }
    'github-copilot' {
        Copy-Item -LiteralPath (Join-Path $sourceRoot 'plugin.json') -Destination $packageRoot
        Join-Path $packageRoot 'plugin.json'
    }
}

& (Join-Path $PSScriptRoot 'set-manifest-version.ps1') -ManifestPath $manifestPath -Version $Version
Write-Host "Packaged Relewise Developer for $Vendor at $packageRoot"

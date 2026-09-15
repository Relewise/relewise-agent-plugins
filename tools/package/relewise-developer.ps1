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
foreach ($file in @('README.md')) {
    Copy-Item -LiteralPath (Join-Path $sourceRoot $file) -Destination $packageRoot
}
Copy-Item -LiteralPath (Join-Path $repositoryRoot 'LICENSE') -Destination $packageRoot

& "$PSScriptRoot/write-plugin-configuration.ps1" -PluginName relewise-developer -Vendor $Vendor -OutputRoot $packageRoot -Version $Version
Write-Host "Packaged Relewise Developer for $Vendor at $packageRoot"

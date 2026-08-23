param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$')]
    [string] $Version,

    [string] $PackagesRoot,

    [string] $OutputDirectory
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
if ([string]::IsNullOrWhiteSpace($PackagesRoot)) { $PackagesRoot = Join-Path $repositoryRoot 'artifacts\universal' }
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) { $OutputDirectory = Join-Path $repositoryRoot 'artifacts\release-universal' }

$resolvedPackagesRoot = [IO.Path]::GetFullPath($PackagesRoot)
$resolvedOutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $resolvedOutputDirectory | Out-Null

foreach ($vendor in @('claude', 'github-copilot', 'openai', 'google')) {
    $packageParent = Join-Path $resolvedPackagesRoot $vendor
    $packageRoot = Join-Path $packageParent 'relewise'
    if (-not (Test-Path -LiteralPath $packageRoot -PathType Container)) { throw "Missing universal package: $packageRoot" }
    $archivePath = Join-Path $resolvedOutputDirectory "relewise-$vendor-universal-v$Version.tar.gz"
    & tar -czf $archivePath -C $packageParent relewise
    if ($LASTEXITCODE -ne 0) { throw "tar failed while creating $archivePath" }
    Write-Host "Created $archivePath"
}

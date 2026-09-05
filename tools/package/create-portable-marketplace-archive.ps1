param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$')]
    [string] $Version,

    [string] $PackagesRoot,

    [string] $OutputDirectory
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
if ([string]::IsNullOrWhiteSpace($PackagesRoot)) { $PackagesRoot = Join-Path $repositoryRoot 'artifacts\portable-marketplace' }
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) { $OutputDirectory = Join-Path $repositoryRoot 'artifacts\release-portable' }

$resolvedPackagesRoot = (Resolve-Path -LiteralPath $PackagesRoot).Path
$marketplaceRoot = Join-Path $resolvedPackagesRoot 'relewise-agent-plugins'
if (-not (Test-Path -LiteralPath $marketplaceRoot -PathType Container)) {
    throw "Missing portable marketplace: $marketplaceRoot"
}
$resolvedOutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $resolvedOutputDirectory | Out-Null
$archivePath = Join-Path $resolvedOutputDirectory "relewise-portable-marketplace-v$Version.zip"
if (Test-Path -LiteralPath $archivePath) { Remove-Item -LiteralPath $archivePath -Force }

$zip = Get-Command zip -ErrorAction SilentlyContinue
if ($null -ne $zip) {
    Push-Location $resolvedPackagesRoot
    try {
        & $zip.Source -q -r $archivePath 'relewise-agent-plugins'
        if ($LASTEXITCODE -ne 0) { throw "zip failed while creating $archivePath" }
    }
    finally {
        Pop-Location
    }
}
elseif ($IsWindows) {
    & tar -a -cf $archivePath -C $resolvedPackagesRoot 'relewise-agent-plugins'
    if ($LASTEXITCODE -ne 0) { throw "tar failed while creating $archivePath" }
}
else {
    throw 'The zip command is required to preserve executable permissions in the portable marketplace archive.'
}

Write-Host "Created portable marketplace archive $archivePath"

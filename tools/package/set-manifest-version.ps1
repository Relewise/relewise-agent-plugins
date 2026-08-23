param(
    [Parameter(Mandatory = $true)]
    [string] $ManifestPath,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$')]
    [string] $Version
)

$ErrorActionPreference = 'Stop'
$resolvedManifest = (Resolve-Path -LiteralPath $ManifestPath).Path
$manifest = Get-Content -Raw -LiteralPath $resolvedManifest | ConvertFrom-Json
$manifest.version = $Version
$json = $manifest | ConvertTo-Json -Depth 100
[IO.File]::WriteAllText($resolvedManifest, "$json`n", [Text.UTF8Encoding]::new($false))

Write-Host "Set package manifest version to $Version in $resolvedManifest"

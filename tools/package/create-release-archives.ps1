param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('win-x64', 'linux-x64', 'linux-arm64', 'osx-x64', 'osx-arm64')]
    [string] $RuntimeIdentifier,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$')]
    [string] $Version,

    [string] $ArtifactsRoot,

    [string] $OutputDirectory
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
if ([string]::IsNullOrWhiteSpace($ArtifactsRoot)) {
    $ArtifactsRoot = Join-Path $repositoryRoot 'artifacts'
}
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $ArtifactsRoot 'release'
}

$resolvedArtifactsRoot = [IO.Path]::GetFullPath($ArtifactsRoot)
$resolvedOutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $resolvedOutputDirectory | Out-Null

$vendors = @('claude', 'github-copilot', 'openai', 'google')
foreach ($vendor in $vendors) {
    $packageParent = Join-Path $resolvedArtifactsRoot "$vendor\$RuntimeIdentifier"
    $packageRoot = Join-Path $packageParent 'relewise'
    if (-not (Test-Path -LiteralPath $packageRoot -PathType Container)) {
        throw "Package directory does not exist: $packageRoot"
    }

    $baseName = "relewise-$vendor-$RuntimeIdentifier-v$Version"
    if ($RuntimeIdentifier -eq 'win-x64') {
        $archivePath = Join-Path $resolvedOutputDirectory "$baseName.zip"
        Compress-Archive -LiteralPath $packageRoot -DestinationPath $archivePath -Force
    }
    else {
        $archivePath = Join-Path $resolvedOutputDirectory "$baseName.tar.gz"
        & tar -czf $archivePath -C $packageParent relewise
        if ($LASTEXITCODE -ne 0) {
            throw "tar failed while creating $archivePath"
        }
    }

    Write-Host "Created $archivePath"
}

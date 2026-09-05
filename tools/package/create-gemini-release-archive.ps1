param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('win-x64', 'linux-x64', 'linux-arm64', 'osx-x64', 'osx-arm64')]
    [string] $RuntimeIdentifier,

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
$packageParent = Join-Path $resolvedArtifactsRoot "google\$RuntimeIdentifier"
$packageRoot = Join-Path $packageParent 'relewise'
if (-not (Test-Path -LiteralPath $packageRoot -PathType Container)) {
    throw "Gemini package directory does not exist: $packageRoot"
}
New-Item -ItemType Directory -Force -Path $resolvedOutputDirectory | Out-Null

$geminiPlatform = switch ($RuntimeIdentifier) {
    'win-x64' { 'win32.x64' }
    'linux-x64' { 'linux.x64' }
    'linux-arm64' { 'linux.arm64' }
    'osx-x64' { 'darwin.x64' }
    'osx-arm64' { 'darwin.arm64' }
}
$baseName = "$geminiPlatform.relewise"
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

Write-Host "Created Gemini release asset $archivePath"

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('win-x64', 'linux-x64', 'linux-arm64', 'osx-x64', 'osx-arm64')]
    [string] $RuntimeIdentifier,

    [Parameter(Mandatory = $true)]
    [string] $ExecutablePath,

    [string] $OutputRoot,

    [switch] $Merge
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$resolvedExecutable = (Resolve-Path -LiteralPath $ExecutablePath).Path
$expectedExecutableName = if ($RuntimeIdentifier -eq 'win-x64') { 'relewise-agent.exe' } else { 'relewise-agent' }
if ([IO.Path]::GetFileName($resolvedExecutable) -ne $expectedExecutableName) {
    throw "Runtime '$RuntimeIdentifier' requires an executable named '$expectedExecutableName'."
}

$artifactsRoot = [IO.Path]::GetFullPath((Join-Path $repositoryRoot 'artifacts\claude'))
if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
    $OutputRoot = Join-Path $artifactsRoot $RuntimeIdentifier
}
$resolvedOutputRoot = [IO.Path]::GetFullPath($OutputRoot)
$packageRoot = [IO.Path]::GetFullPath((Join-Path $resolvedOutputRoot 'relewise'))
if (-not $packageRoot.StartsWith($resolvedOutputRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Resolved package path is outside the requested output root.'
}
if ((Test-Path -LiteralPath $packageRoot) -and -not $Merge) {
    Remove-Item -LiteralPath $packageRoot -Recurse -Force
}

$adapterRoot = Join-Path $repositoryRoot 'vendors\claude\relewise'
if (-not (Test-Path -LiteralPath $packageRoot)) {
    New-Item -ItemType Directory -Path $packageRoot | Out-Null
    Copy-Item -LiteralPath (Join-Path $adapterRoot '.claude-plugin') -Destination $packageRoot -Recurse
    Copy-Item -LiteralPath (Join-Path $repositoryRoot 'plugins\relewise\skills') -Destination $packageRoot -Recurse
    Copy-Item -LiteralPath (Join-Path $repositoryRoot 'LICENSE') -Destination $packageRoot
    New-Item -ItemType Directory -Path (Join-Path $packageRoot 'scripts'), (Join-Path $packageRoot 'libexec') | Out-Null

    $launcher = (Get-Content -Raw -LiteralPath (Join-Path $adapterRoot 'scripts\relewise-agent')).Replace("`r`n", "`n")
    [IO.File]::WriteAllText(
        (Join-Path $packageRoot 'scripts\relewise-agent'),
        $launcher,
        [Text.UTF8Encoding]::new($false))
}

$runtimeDirectory = Join-Path $packageRoot "libexec\$RuntimeIdentifier"
New-Item -ItemType Directory -Force -Path $runtimeDirectory | Out-Null
Copy-Item -LiteralPath $resolvedExecutable -Destination (Join-Path $runtimeDirectory $expectedExecutableName) -Force

if (-not $IsWindows) {
    & chmod +x (Join-Path $packageRoot 'scripts\relewise-agent') (Join-Path $runtimeDirectory $expectedExecutableName)
}

Write-Host "Packaged Claude Code plugin for $RuntimeIdentifier at $packageRoot"

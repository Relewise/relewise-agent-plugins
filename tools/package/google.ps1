param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('win-x64', 'linux-x64', 'linux-arm64', 'osx-x64', 'osx-arm64')]
    [string] $RuntimeIdentifier,

    [Parameter(Mandatory = $true)]
    [string] $ExecutablePath,

    [string] $OutputRoot
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$resolvedExecutable = (Resolve-Path -LiteralPath $ExecutablePath).Path
$expectedExecutableName = if ($RuntimeIdentifier -eq 'win-x64') { 'relewise-agent.exe' } else { 'relewise-agent' }
if ([IO.Path]::GetFileName($resolvedExecutable) -ne $expectedExecutableName) {
    throw "Runtime '$RuntimeIdentifier' requires an executable named '$expectedExecutableName'."
}

$artifactsRoot = [IO.Path]::GetFullPath((Join-Path $repositoryRoot 'artifacts\google'))
if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
    $OutputRoot = Join-Path $artifactsRoot $RuntimeIdentifier
}
$resolvedOutputRoot = [IO.Path]::GetFullPath($OutputRoot)
$packageRoot = [IO.Path]::GetFullPath((Join-Path $resolvedOutputRoot 'relewise'))
if (-not $packageRoot.StartsWith($resolvedOutputRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Resolved package path is outside the requested output root.'
}
if (Test-Path -LiteralPath $packageRoot) {
    Remove-Item -LiteralPath $packageRoot -Recurse -Force
}

$adapterRoot = Join-Path $repositoryRoot 'vendors\google\relewise'
New-Item -ItemType Directory -Path $packageRoot | Out-Null
Copy-Item -LiteralPath (Join-Path $adapterRoot 'gemini-extension.json') -Destination $packageRoot
Copy-Item -LiteralPath (Join-Path $repositoryRoot 'plugins\relewise\skills') -Destination $packageRoot -Recurse
Copy-Item -LiteralPath (Join-Path $repositoryRoot 'LICENSE') -Destination $packageRoot
New-Item -ItemType Directory -Path (Join-Path $packageRoot 'bin'), (Join-Path $packageRoot 'libexec') | Out-Null

$instruction = @'

## Google Gemini CLI execution

This packaged skill includes the CLI at `../../bin/relewise-agent` relative to this `SKILL.md`. Resolve that path to an absolute path before invoking it; do not assume `relewise-agent` is globally installed.
'@
Get-ChildItem -LiteralPath (Join-Path $packageRoot 'skills') -Directory | ForEach-Object {
    $skillPath = Join-Path $_.FullName 'SKILL.md'
    [IO.File]::AppendAllText($skillPath, $instruction.Replace("`r`n", "`n"), [Text.UTF8Encoding]::new($false))
}

$launcher = Get-Content -Raw -LiteralPath (Join-Path $adapterRoot 'bin\relewise-agent')
$launcher = $launcher.Replace('__RELEWISE_AGENT_EXECUTABLE__', $expectedExecutableName).Replace("`r`n", "`n")
[IO.File]::WriteAllText((Join-Path $packageRoot 'bin\relewise-agent'), $launcher, [Text.UTF8Encoding]::new($false))
Copy-Item -LiteralPath $resolvedExecutable -Destination (Join-Path $packageRoot "libexec\$expectedExecutableName")

if (-not $IsWindows) {
    & chmod +x (Join-Path $packageRoot 'bin\relewise-agent') (Join-Path $packageRoot "libexec\$expectedExecutableName")
}

Write-Host "Packaged Google Gemini CLI extension for $RuntimeIdentifier at $packageRoot"

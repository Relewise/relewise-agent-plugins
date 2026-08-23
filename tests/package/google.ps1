param(
    [Parameter(Mandatory = $true)]
    [string] $PackagePath,

    [Parameter(Mandatory = $true)]
    [ValidateSet('win-x64', 'linux-x64', 'linux-arm64', 'osx-x64', 'osx-arm64')]
    [string] $RuntimeIdentifier
)

$ErrorActionPreference = 'Stop'
$packageRoot = (Resolve-Path -LiteralPath $PackagePath).Path
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$manifest = Get-Content -Raw -LiteralPath (Join-Path $packageRoot 'gemini-extension.json') | ConvertFrom-Json

if ($manifest.version -notmatch '^\d+\.\d+\.\d+$') { throw 'Gemini extension manifest version is not semantic.' }
$tokenSetting = @($manifest.settings) | Where-Object envVar -eq 'RELEWISE_AGENT_GATEWAY_TOKEN'
if ($tokenSetting.Count -ne 1 -or -not $tokenSetting.sensitive) { throw 'Agent Gateway PAT must be declared as one sensitive Gemini setting.' }

$sourceSkills = Get-ChildItem -LiteralPath (Join-Path $repositoryRoot 'plugins\relewise\skills') -Directory
$packagedSkills = Get-ChildItem -LiteralPath (Join-Path $packageRoot 'skills') -Directory
if ($sourceSkills.Count -ne $packagedSkills.Count) { throw 'Package does not contain every canonical skill.' }
foreach ($sourceSkill in $sourceSkills) {
    $packagedSkill = Join-Path $packageRoot "skills\$($sourceSkill.Name)\SKILL.md"
    if (-not (Test-Path -LiteralPath $packagedSkill)) { throw "Package is missing skill '$($sourceSkill.Name)'." }
    $content = Get-Content -Raw -LiteralPath $packagedSkill
    if (-not $content.Contains('../../bin/relewise-agent')) { throw "Packaged skill '$($sourceSkill.Name)' does not locate the bundled CLI." }
    if (-not $content.StartsWith((Get-Content -Raw -LiteralPath (Join-Path $sourceSkill.FullName 'SKILL.md')))) {
        throw "Packaged skill '$($sourceSkill.Name)' does not preserve its canonical source."
    }
}

$expectedExecutable = if ($RuntimeIdentifier -eq 'win-x64') { 'relewise-agent.exe' } else { 'relewise-agent' }
if (-not (Test-Path -LiteralPath (Join-Path $packageRoot "libexec\$expectedExecutable"))) { throw 'Package is missing its native executable.' }
$launcher = Get-Content -Raw -LiteralPath (Join-Path $packageRoot 'bin\relewise-agent')
if ($launcher.Contains('__RELEWISE_AGENT_EXECUTABLE__')) { throw 'Launcher contains an unresolved executable placeholder.' }
if (-not $launcher.Contains('RELEWISE_AGENT_GATEWAY_TOKEN')) { throw 'Launcher does not enforce the CLI environment-variable contract.' }

Write-Host "Google Gemini CLI package smoke tests passed for $RuntimeIdentifier"

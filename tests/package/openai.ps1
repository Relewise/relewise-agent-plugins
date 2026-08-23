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
$manifest = Get-Content -Raw -LiteralPath (Join-Path $packageRoot '.codex-plugin\plugin.json') | ConvertFrom-Json

if ($manifest.name -ne 'relewise') { throw 'Codex plugin manifest has an unexpected name.' }
if ($manifest.skills -ne './skills/') { throw 'Codex plugin manifest does not expose the packaged skills.' }
if ($manifest.author.name -ne 'Relewise') { throw 'Codex plugin manifest has an unexpected author.' }
if ($null -ne $manifest.userConfig) { throw 'Codex plugin manifest must not claim unsupported protected user configuration.' }

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

Write-Host "OpenAI Codex package smoke tests passed for $RuntimeIdentifier"

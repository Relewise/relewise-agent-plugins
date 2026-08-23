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
$manifest = Get-Content -Raw -LiteralPath (Join-Path $packageRoot '.claude-plugin\plugin.json') | ConvertFrom-Json

$tokenOption = $manifest.userConfig.agent_gateway_token
if (-not $tokenOption.required -or -not $tokenOption.sensitive) { throw 'Agent Gateway PAT must be required and sensitive.' }

$sourceSkills = Get-ChildItem -LiteralPath (Join-Path $repositoryRoot 'plugins\relewise\skills') -Directory
$packagedSkills = Get-ChildItem -LiteralPath (Join-Path $packageRoot 'skills') -Directory
if ($sourceSkills.Count -ne $packagedSkills.Count) { throw 'Package does not contain every canonical skill.' }
foreach ($sourceSkill in $sourceSkills) {
    $packagedSkill = Join-Path $packageRoot "skills\$($sourceSkill.Name)\SKILL.md"
    if (-not (Test-Path -LiteralPath $packagedSkill)) { throw "Package is missing skill '$($sourceSkill.Name)'." }
    $sourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $sourceSkill.FullName 'SKILL.md')).Hash
    $packageHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $packagedSkill).Hash
    if ($sourceHash -ne $packageHash) { throw "Packaged skill '$($sourceSkill.Name)' differs from its canonical source." }
}

$expectedExecutable = if ($RuntimeIdentifier -eq 'win-x64') { 'relewise-agent.exe' } else { 'relewise-agent' }
if (-not (Test-Path -LiteralPath (Join-Path $packageRoot "libexec\$expectedExecutable"))) { throw 'Package is missing its native executable.' }
$launcher = Get-Content -Raw -LiteralPath (Join-Path $packageRoot 'bin\relewise-agent')
if ($launcher.Contains('__RELEWISE_AGENT_EXECUTABLE__')) { throw 'Launcher contains an unresolved executable placeholder.' }
if (-not $launcher.Contains('CLAUDE_PLUGIN_OPTION_agent_gateway_token') -or -not $launcher.Contains('RELEWISE_AGENT_GATEWAY_TOKEN')) {
    throw 'Launcher does not map Claude sensitive configuration to the CLI environment variable.'
}

Write-Host "Claude Code package smoke tests passed for $RuntimeIdentifier"

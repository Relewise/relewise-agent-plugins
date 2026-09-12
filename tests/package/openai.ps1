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
if (-not (Test-Path -LiteralPath (Join-Path $packageRoot 'LICENSE'))) { throw 'Package is missing its license.' }

if ($manifest.skills -ne './skills/') { throw 'Codex plugin manifest does not expose the packaged skills.' }
if ($null -ne $manifest.userConfig) { throw 'Codex plugin manifest must not claim unsupported protected user configuration.' }
if ($manifest.interface.logo -ne './assets/logo.png') { throw 'Codex plugin manifest does not reference the Relewise logo.' }
if (-not (Test-Path -LiteralPath (Join-Path $packageRoot 'assets\logo.png'))) { throw 'Package is missing the Relewise logo.' }
$server = $manifest.mcpServers.'relewise-agent-gateway'
if ($server.type -ne 'http' -or $server.url -ne 'https://my.relewise.com/agents/mcp') { throw 'Codex plugin has the wrong Agent Gateway MCP endpoint.' }
if ($null -ne $server.bearer_token_env_var) { throw 'Codex plugin must leave MCP authentication to the client OAuth flow.' }

$sourceSkills = Get-ChildItem -LiteralPath (Join-Path $repositoryRoot 'plugins\relewise\skills') -Directory
$packagedSkills = Get-ChildItem -LiteralPath (Join-Path $packageRoot 'skills') -Directory
if ($sourceSkills.Count -ne $packagedSkills.Count) { throw 'Package does not contain every canonical skill.' }
foreach ($sourceSkill in $sourceSkills) {
    $packagedSkill = Join-Path $packageRoot "skills\$($sourceSkill.Name)\SKILL.md"
    if (-not (Test-Path -LiteralPath $packagedSkill)) { throw "Package is missing skill '$($sourceSkill.Name)'." }
    $content = Get-Content -Raw -LiteralPath $packagedSkill
    if ($sourceSkill.Name -ne 'relewise-agent-gateway' -and -not $content.Contains('relewise-execution-skill: relewise-agent-gateway')) { throw "Packaged domain skill '$($sourceSkill.Name)' does not delegate execution to the shared Agent Gateway skill." }
    if (-not $content.StartsWith((Get-Content -Raw -LiteralPath (Join-Path $sourceSkill.FullName 'SKILL.md')))) {
        throw "Packaged skill '$($sourceSkill.Name)' does not preserve its canonical source."
    }
}
$expectedExecutable = if ($RuntimeIdentifier -eq 'win-x64') { 'relewise-agent.exe' } else { 'relewise-agent' }
$gatewayScripts = Join-Path $packageRoot 'skills\relewise-agent-gateway\scripts'
if (-not (Test-Path -LiteralPath (Join-Path $gatewayScripts "libexec\$RuntimeIdentifier\$expectedExecutable"))) { throw 'Shared Agent Gateway skill is missing its native executable.' }
$packagedRuntimes = @(Get-ChildItem -LiteralPath (Join-Path $gatewayScripts 'libexec') -Directory)
if ($packagedRuntimes.Count -ne 1 -or $packagedRuntimes[0].Name -ne $RuntimeIdentifier) { throw 'Platform package must contain exactly its requested runtime.' }
$launcher = Get-Content -Raw -LiteralPath (Join-Path $gatewayScripts 'relewise-agent')
if (-not $launcher.Contains('runtime_id="win-x64"') -or -not $launcher.Contains('runtime_id="osx-arm64"')) { throw 'Launcher does not select a native executable by platform.' }
if (-not (Test-Path -LiteralPath (Join-Path $gatewayScripts 'relewise-agent.ps1'))) { throw 'Shared Agent Gateway skill is missing its Windows PowerShell launcher.' }
if ((Test-Path -LiteralPath (Join-Path $packageRoot 'scripts')) -or (Test-Path -LiteralPath (Join-Path $packageRoot 'libexec'))) { throw 'CLI payload must be skill-local, not plugin-level.' }

Write-Host "OpenAI Codex package smoke tests passed for $RuntimeIdentifier"

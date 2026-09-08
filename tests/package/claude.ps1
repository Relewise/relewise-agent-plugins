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
if (-not (Test-Path -LiteralPath (Join-Path $packageRoot 'LICENSE'))) { throw 'Package is missing its license.' }

if ($manifest.userConfig.agent_gateway_token.type -ne 'string' -or
    $manifest.userConfig.agent_gateway_token.sensitive -ne $true -or
    $manifest.userConfig.agent_gateway_token.required -ne $true) {
    throw 'Claude Code manifest does not request the Agent Gateway PAT as required protected configuration.'
}
if ($manifest.mcpServers -ne './.claude-plugin/mcp.json') { throw 'Claude Code manifest does not declare its protected Agent Gateway MCP configuration.' }
$mcp = Get-Content -Raw -LiteralPath (Join-Path $packageRoot '.claude-plugin\mcp.json') | ConvertFrom-Json
$server = $mcp.mcpServers.'relewise-agent-gateway'
if ($server.type -ne 'http' -or $server.url -ne 'https://my.relewise.com/agents/mcp') { throw 'Claude package has the wrong Agent Gateway MCP endpoint.' }
if ($server.headers.Authorization -ne 'Bearer ${user_config.agent_gateway_token}') { throw 'Claude package does not obtain MCP authentication from protected user configuration.' }

$sourceSkills = Get-ChildItem -LiteralPath (Join-Path $repositoryRoot 'plugins\relewise\skills') -Directory
$packagedSkills = Get-ChildItem -LiteralPath (Join-Path $packageRoot 'skills') -Directory
if ($sourceSkills.Count -ne $packagedSkills.Count) { throw 'Package does not contain every canonical skill.' }
foreach ($sourceSkill in $sourceSkills) {
    $packagedSkill = Join-Path $packageRoot "skills\$($sourceSkill.Name)\SKILL.md"
    if (-not (Test-Path -LiteralPath $packagedSkill)) { throw "Package is missing skill '$($sourceSkill.Name)'." }
    $sourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $sourceSkill.FullName 'SKILL.md')).Hash
    $packageHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $packagedSkill).Hash
    if ($sourceHash -ne $packageHash) { throw "Packaged skill '$($sourceSkill.Name)' differs from its canonical source." }
    $content = Get-Content -Raw -LiteralPath $packagedSkill
    if ($sourceSkill.Name -ne 'relewise-agent-gateway' -and -not $content.Contains('relewise-execution-skill: relewise-agent-gateway')) { throw "Packaged domain skill '$($sourceSkill.Name)' does not delegate execution to the shared Agent Gateway skill." }
}

$expectedExecutable = if ($RuntimeIdentifier -eq 'win-x64') { 'relewise-agent.exe' } else { 'relewise-agent' }
$gatewayScripts = Join-Path $packageRoot 'skills\relewise-agent-gateway\scripts'
if (-not (Test-Path -LiteralPath (Join-Path $gatewayScripts "libexec\$RuntimeIdentifier\$expectedExecutable"))) { throw 'Shared Agent Gateway skill is missing its native executable.' }
$packagedRuntimes = @(Get-ChildItem -LiteralPath (Join-Path $gatewayScripts 'libexec') -Directory)
if ($packagedRuntimes.Count -ne 1 -or $packagedRuntimes[0].Name -ne $RuntimeIdentifier) { throw 'Platform package must contain exactly its requested runtime.' }
if (Test-Path -LiteralPath (Join-Path $packageRoot 'bin')) { throw 'Claude-hosted package must not contain a top-level bin directory.' }
$launcher = Get-Content -Raw -LiteralPath (Join-Path $gatewayScripts 'relewise-agent')
if (-not $launcher.Contains('runtime_id="win-x64"') -or -not $launcher.Contains('runtime_id="osx-arm64"')) { throw 'Launcher does not select a native executable by platform.' }
if ($launcher.Contains('CLAUDE_PLUGIN_OPTION_') -or $launcher.Contains('RELEWISE_AGENT_GATEWAY_TOKEN is required')) {
    throw 'Launcher must delegate authentication handling to the executable.'
}
if (-not (Test-Path -LiteralPath (Join-Path $gatewayScripts 'relewise-agent.ps1'))) { throw 'Shared Agent Gateway skill is missing its Windows PowerShell launcher.' }
if ((Test-Path -LiteralPath (Join-Path $packageRoot 'scripts')) -or (Test-Path -LiteralPath (Join-Path $packageRoot 'libexec'))) { throw 'CLI payload must be skill-local, not plugin-level.' }

Write-Host "Claude Code package smoke tests passed for $RuntimeIdentifier"

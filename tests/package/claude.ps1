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

if ($null -ne $manifest.userConfig) { throw 'Claude Code manifest must not declare protected user configuration.' }
if ($manifest.mcpServers -ne './.mcp.json') { throw 'Claude Code manifest does not declare Agent Gateway MCP.' }
$mcp = Get-Content -Raw -LiteralPath (Join-Path $packageRoot '.mcp.json') | ConvertFrom-Json
$server = $mcp.mcpServers.'relewise-agent-gateway'
if ($server.type -ne 'http' -or $server.url -ne 'https://my.relewise.com/agents/mcp') { throw 'Claude package has the wrong Agent Gateway MCP endpoint.' }
if ($server.headers.Authorization -ne 'Bearer ${RELEWISE_AGENT_GATEWAY_TOKEN:-}') { throw 'Claude package does not obtain MCP authentication from the shared PAT environment variable.' }

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
$sourceReferenceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $repositoryRoot 'plugins\relewise\references\agent-gateway-transports.md')).Hash
$packageReferenceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $packageRoot 'references\agent-gateway-transports.md')).Hash
if ($sourceReferenceHash -ne $packageReferenceHash) { throw 'Packaged transport-selection reference differs from its canonical source.' }

$expectedExecutable = if ($RuntimeIdentifier -eq 'win-x64') { 'relewise-agent.exe' } else { 'relewise-agent' }
if (-not (Test-Path -LiteralPath (Join-Path $packageRoot "libexec\$RuntimeIdentifier\$expectedExecutable"))) { throw 'Package is missing its native executable.' }
if (Test-Path -LiteralPath (Join-Path $packageRoot 'bin')) { throw 'Claude-hosted package must not contain a top-level bin directory.' }
$launcher = Get-Content -Raw -LiteralPath (Join-Path $packageRoot 'scripts\relewise-agent')
if (-not $launcher.Contains('runtime_id="win-x64"') -or -not $launcher.Contains('runtime_id="osx-arm64"')) { throw 'Launcher does not select a native executable by platform.' }
if ($launcher.Contains('CLAUDE_PLUGIN_OPTION_') -or $launcher.Contains('RELEWISE_AGENT_GATEWAY_TOKEN is required')) {
    throw 'Launcher must delegate authentication handling to the executable.'
}

Write-Host "Claude Code package smoke tests passed for $RuntimeIdentifier"

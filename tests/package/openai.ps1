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
if ($manifest.mcpServers -ne './.mcp.json') { throw 'Codex plugin manifest does not declare Agent Gateway MCP.' }
$mcp = Get-Content -Raw -LiteralPath (Join-Path $packageRoot '.mcp.json') | ConvertFrom-Json
$server = $mcp.mcpServers.'relewise-agent-gateway'
if ($server.type -ne 'http' -or $server.url -ne 'https://my.relewise.com/agents/mcp') { throw 'Codex plugin has the wrong Agent Gateway MCP endpoint.' }
if ($server.headers.Authorization -ne 'Bearer ${RELEWISE_AGENT_GATEWAY_TOKEN:-}') { throw 'Codex plugin does not obtain MCP authentication from the shared PAT environment variable.' }

$sourceSkills = Get-ChildItem -LiteralPath (Join-Path $repositoryRoot 'plugins\relewise\skills') -Directory
$packagedSkills = Get-ChildItem -LiteralPath (Join-Path $packageRoot 'skills') -Directory
if ($sourceSkills.Count -ne $packagedSkills.Count) { throw 'Package does not contain every canonical skill.' }
foreach ($sourceSkill in $sourceSkills) {
    $packagedSkill = Join-Path $packageRoot "skills\$($sourceSkill.Name)\SKILL.md"
    if (-not (Test-Path -LiteralPath $packagedSkill)) { throw "Package is missing skill '$($sourceSkill.Name)'." }
    $content = Get-Content -Raw -LiteralPath $packagedSkill
    if (-not $content.Contains('../../references/agent-gateway-transports.md')) { throw "Packaged skill '$($sourceSkill.Name)' does not use the shared transport rules." }
    if (-not $content.StartsWith((Get-Content -Raw -LiteralPath (Join-Path $sourceSkill.FullName 'SKILL.md')))) {
        throw "Packaged skill '$($sourceSkill.Name)' does not preserve its canonical source."
    }
}
$sourceReferenceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $repositoryRoot 'plugins\relewise\references\agent-gateway-transports.md')).Hash
$packageReferenceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $packageRoot 'references\agent-gateway-transports.md')).Hash
if ($sourceReferenceHash -ne $packageReferenceHash) { throw 'Packaged transport-selection reference differs from its canonical source.' }

$expectedExecutable = if ($RuntimeIdentifier -eq 'win-x64') { 'relewise-agent.exe' } else { 'relewise-agent' }
if (-not (Test-Path -LiteralPath (Join-Path $packageRoot "libexec\$RuntimeIdentifier\$expectedExecutable"))) { throw 'Package is missing its native executable.' }
$launcher = Get-Content -Raw -LiteralPath (Join-Path $packageRoot 'scripts\relewise-agent')
if (-not $launcher.Contains('runtime_id="win-x64"') -or -not $launcher.Contains('runtime_id="osx-arm64"')) { throw 'Launcher does not select a native executable by platform.' }

Write-Host "OpenAI Codex package smoke tests passed for $RuntimeIdentifier"

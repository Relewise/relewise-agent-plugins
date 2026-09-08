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
$sourceManifest = Get-Content -Raw -LiteralPath (Join-Path $repositoryRoot 'gemini-extension.json') | ConvertFrom-Json
$plannedVersion = (Get-Content -Raw -LiteralPath (Join-Path $repositoryRoot 'version.json') | ConvertFrom-Json).version
if (-not (Test-Path -LiteralPath (Join-Path $packageRoot 'LICENSE'))) { throw 'Package is missing its license.' }

if ($manifest.version -notmatch '^\d+\.\d+\.\d+$') { throw 'Gemini extension manifest version is not semantic.' }
if ($sourceManifest.version -ne $plannedVersion) { throw 'Root Gemini extension manifest version does not match version.json.' }
$tokenSettings = @($manifest.settings) | Where-Object envVar -eq 'RELEWISE_AGENT_GATEWAY_TOKEN'
if ($tokenSettings.Count -ne 1 -or $tokenSettings[0].sensitive -ne $true) {
    throw 'Gemini must request the Agent Gateway PAT as one sensitive extension setting.'
}
$server = $manifest.mcpServers.'relewise-agent-gateway'
if ($server.httpUrl -ne 'https://my.relewise.com/agents/mcp') { throw 'Gemini package has the wrong Agent Gateway MCP endpoint.' }
if ($server.headers.Authorization -ne 'Bearer ${RELEWISE_AGENT_GATEWAY_TOKEN:-}') { throw 'Gemini package has the wrong Agent Gateway MCP authorization header.' }
if ($server.env.RELEWISE_AGENT_GATEWAY_TOKEN -ne '${RELEWISE_AGENT_GATEWAY_TOKEN:-}') { throw 'Gemini package does not explicitly expose the shared token to the MCP server.' }

$sourceSkills = Get-ChildItem -LiteralPath (Join-Path $repositoryRoot 'plugins\relewise\skills') -Directory
$packagedSkills = Get-ChildItem -LiteralPath (Join-Path $packageRoot 'skills') -Directory
if ($sourceSkills.Count -ne $packagedSkills.Count) { throw 'Package does not contain every canonical skill.' }
foreach ($sourceSkill in $sourceSkills) {
    $packagedSkill = Join-Path $packageRoot "skills\$($sourceSkill.Name)\SKILL.md"
    if (-not (Test-Path -LiteralPath $packagedSkill)) { throw "Package is missing skill '$($sourceSkill.Name)'." }
    $content = Get-Content -Raw -LiteralPath $packagedSkill
    $sourceContent = Get-Content -Raw -LiteralPath (Join-Path $sourceSkill.FullName 'SKILL.md')
    if ($content -cne $sourceContent) {
        throw "Packaged skill '$($sourceSkill.Name)' differs from its expected vendor-specific content."
    }
    if ($sourceSkill.Name -ne 'relewise-agent-gateway' -and -not $content.Contains('relewise-execution-skill: relewise-agent-gateway')) {
        throw "Packaged domain skill '$($sourceSkill.Name)' does not delegate execution to the shared Agent Gateway skill."
    }
}

$expectedExecutable = if ($RuntimeIdentifier -eq 'win-x64') { 'relewise-agent.exe' } else { 'relewise-agent' }
$gatewayScripts = Join-Path $packageRoot 'skills\relewise-agent-gateway\scripts'
if (-not (Test-Path -LiteralPath (Join-Path $gatewayScripts "libexec\$RuntimeIdentifier\$expectedExecutable"))) { throw 'Shared Agent Gateway skill is missing its native executable.' }
$packagedRuntimes = @(Get-ChildItem -LiteralPath (Join-Path $gatewayScripts 'libexec') -Directory)
if ($packagedRuntimes.Count -ne 1 -or $packagedRuntimes[0].Name -ne $RuntimeIdentifier) { throw 'Platform package must contain exactly its requested runtime.' }
$launcher = Get-Content -Raw -LiteralPath (Join-Path $gatewayScripts 'relewise-agent')
if (-not $launcher.Contains('runtime_id="win-x64"') -or -not $launcher.Contains('runtime_id="osx-arm64"')) { throw 'Launcher does not select a native executable by platform.' }
$windowsLauncher = Join-Path $gatewayScripts 'relewise-agent.ps1'
if (-not (Test-Path -LiteralPath $windowsLauncher -PathType Leaf)) { throw 'Shared Agent Gateway skill is missing its Windows PowerShell launcher.' }
if (-not (Get-Content -Raw -LiteralPath $windowsLauncher).Contains('libexec\win-x64\relewise-agent.exe')) { throw 'Windows launcher does not select the native Windows executable.' }
if ((Test-Path -LiteralPath (Join-Path $packageRoot 'scripts')) -or (Test-Path -LiteralPath (Join-Path $packageRoot 'libexec'))) { throw 'CLI payload must be skill-local, not extension-level.' }

Write-Host "Google Gemini CLI package smoke tests passed for $RuntimeIdentifier"

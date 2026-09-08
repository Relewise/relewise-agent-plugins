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
if ($null -ne $manifest.settings) { throw 'Gemini must not request a PAT setting that cannot reach skill shell subprocesses.' }
$server = $manifest.mcpServers.'relewise-agent-gateway'
if ($server.httpUrl -ne 'https://my.relewise.com/agents/mcp') { throw 'Gemini package has the wrong Agent Gateway MCP endpoint.' }
if ($server.headers.Authorization -ne 'Bearer ${RELEWISE_AGENT_GATEWAY_TOKEN:-}') { throw 'Gemini package has the wrong Agent Gateway MCP authorization header.' }
if ($server.env.RELEWISE_AGENT_GATEWAY_TOKEN -ne '${RELEWISE_AGENT_GATEWAY_TOKEN:-}') { throw 'Gemini package does not explicitly expose the shared token to the MCP server.' }

$sourceSkills = Get-ChildItem -LiteralPath (Join-Path $repositoryRoot 'plugins\relewise\skills') -Directory
$packagedSkills = Get-ChildItem -LiteralPath (Join-Path $packageRoot 'skills') -Directory
if ($sourceSkills.Count -ne $packagedSkills.Count) { throw 'Package does not contain every canonical skill.' }
$canonicalLauncherInstruction = 'When `../../scripts/relewise-agent` exists relative to the calling `SKILL.md`, resolve it to an absolute path and use that executable. Otherwise, use `relewise-agent` from `PATH`.'
$windowsLauncherInstruction = 'On Windows, when `../../scripts/relewise-agent.ps1` exists relative to the calling `SKILL.md`, resolve it to an absolute path and use that PowerShell launcher. On other platforms, when `../../scripts/relewise-agent` exists relative to the calling `SKILL.md`, resolve it to an absolute path and use that launcher. Fall back to `relewise-agent` from `PATH` only when the platform-specific packaged launcher does not exist.'
foreach ($sourceSkill in $sourceSkills) {
    $packagedSkill = Join-Path $packageRoot "skills\$($sourceSkill.Name)\SKILL.md"
    if (-not (Test-Path -LiteralPath $packagedSkill)) { throw "Package is missing skill '$($sourceSkill.Name)'." }
    $content = Get-Content -Raw -LiteralPath $packagedSkill
    $sourceContent = Get-Content -Raw -LiteralPath (Join-Path $sourceSkill.FullName 'SKILL.md')
    if ($content -cne $sourceContent) {
        throw "Packaged skill '$($sourceSkill.Name)' differs from its expected vendor-specific content."
    }
}

$sourceTransportReference = Get-Content -Raw -LiteralPath (Join-Path $repositoryRoot 'plugins\relewise\references\agent-gateway-transports.md')
$packagedTransportReference = Get-Content -Raw -LiteralPath (Join-Path $packageRoot 'references\agent-gateway-transports.md')
$expectedTransportReference = if ($RuntimeIdentifier -eq 'win-x64') {
    $sourceTransportReference.Replace($canonicalLauncherInstruction, $windowsLauncherInstruction)
} else {
    $sourceTransportReference
}
if ($packagedTransportReference -cne $expectedTransportReference) {
    throw 'Packaged transport-selection reference differs from its expected platform-specific content.'
}

$expectedExecutable = if ($RuntimeIdentifier -eq 'win-x64') { 'relewise-agent.exe' } else { 'relewise-agent' }
if (-not (Test-Path -LiteralPath (Join-Path $packageRoot "libexec\$RuntimeIdentifier\$expectedExecutable"))) { throw 'Package is missing its native executable.' }
$launcher = Get-Content -Raw -LiteralPath (Join-Path $packageRoot 'scripts\relewise-agent')
if (-not $launcher.Contains('runtime_id="win-x64"') -or -not $launcher.Contains('runtime_id="osx-arm64"')) { throw 'Launcher does not select a native executable by platform.' }
if ($RuntimeIdentifier -eq 'win-x64') {
    $windowsLauncher = Join-Path $packageRoot 'scripts\relewise-agent.ps1'
    if (-not (Test-Path -LiteralPath $windowsLauncher -PathType Leaf)) { throw 'Package is missing its Windows PowerShell launcher.' }
    if (-not (Get-Content -Raw -LiteralPath $windowsLauncher).Contains('libexec\win-x64\relewise-agent.exe')) { throw 'Windows launcher does not select the native Windows executable.' }
}

Write-Host "Google Gemini CLI package smoke tests passed for $RuntimeIdentifier"

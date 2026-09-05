param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('claude', 'github-copilot', 'openai')]
    [string] $Vendor,

    [Parameter(Mandatory = $true)]
    [string] $PackagePath,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$')]
    [string] $Version
)

$ErrorActionPreference = 'Stop'
$packageRoot = (Resolve-Path -LiteralPath $PackagePath).Path
$manifestRelativePath = switch ($Vendor) {
    'claude' { '.claude-plugin\plugin.json' }
    'openai' { '.codex-plugin\plugin.json' }
    'github-copilot' { 'plugin.json' }
}
$manifest = Get-Content -Raw -LiteralPath (Join-Path $packageRoot $manifestRelativePath) | ConvertFrom-Json
if ($manifest.name -ne 'relewise-developer') { throw 'Package manifest has the wrong plugin name.' }
if ($manifest.version -ne $Version) { throw "Package manifest version is not $Version." }

$mcp = Get-Content -Raw -LiteralPath (Join-Path $packageRoot '.mcp.json') | ConvertFrom-Json
$server = $mcp.mcpServers.'relewise-developer'
if ($server.type -ne 'http' -or $server.url -ne 'https://mcp.relewise.com') {
    throw 'Package does not configure the Relewise Developer MCP over HTTP.'
}
foreach ($requiredPath in @('skills\relewise-development\SKILL.md', 'assets\logo.png', 'LICENSE')) {
    if (-not (Test-Path -LiteralPath (Join-Path $packageRoot $requiredPath) -PathType Leaf)) {
        throw "Package is missing $requiredPath."
    }
}
foreach ($forbiddenPath in @('libexec', 'scripts')) {
    if (Test-Path -LiteralPath (Join-Path $packageRoot $forbiddenPath)) {
        throw "Relewise Developer must not contain Agent Gateway $forbiddenPath."
    }
}
if ($Vendor -in @('claude', 'openai') -and $manifest.mcpServers -ne './.mcp.json') {
    throw "$Vendor manifest does not declare the packaged MCP configuration."
}

Write-Host "Relewise Developer $Vendor package tests passed."

param(
    [Parameter(Mandatory = $true)]
    [string] $PackagesRoot,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$')]
    [string] $Version
)

$ErrorActionPreference = 'Stop'
$resolvedPackagesRoot = (Resolve-Path -LiteralPath $PackagesRoot).Path
$runtimes = @('win-x64', 'linux-x64', 'linux-arm64', 'osx-x64', 'osx-arm64')
$manifestPaths = @{
    'claude' = '.claude-plugin\plugin.json'
    'github-copilot' = 'plugin.json'
    'openai' = '.codex-plugin\plugin.json'
    'google' = 'gemini-extension.json'
}

foreach ($vendor in $manifestPaths.Keys) {
    $packageRoot = Join-Path $resolvedPackagesRoot "$vendor\relewise"
    $gatewayScripts = Join-Path $packageRoot 'skills\relewise-agent-gateway\scripts'
    $manifest = Get-Content -Raw -LiteralPath (Join-Path $packageRoot $manifestPaths[$vendor]) | ConvertFrom-Json
    if ($manifest.version -ne $Version) { throw "$vendor manifest version is not $Version." }
    foreach ($runtime in $runtimes) {
        $executableName = if ($runtime -eq 'win-x64') { 'relewise-agent.exe' } else { 'relewise-agent' }
        if (-not (Test-Path -LiteralPath (Join-Path $gatewayScripts "libexec\$runtime\$executableName") -PathType Leaf)) {
            throw "$vendor package is missing its $runtime executable."
        }
    }
    $launcher = Get-Content -Raw -LiteralPath (Join-Path $gatewayScripts 'relewise-agent')
    foreach ($runtime in $runtimes) {
        if (-not $launcher.Contains("runtime_id=`"$runtime`"")) { throw "$vendor launcher does not select $runtime." }
    }
    if (-not (Test-Path -LiteralPath (Join-Path $gatewayScripts 'relewise-agent.ps1') -PathType Leaf)) {
        throw "$vendor package is missing its Windows PowerShell launcher."
    }
    if ($vendor -eq 'google') {
        $server = $manifest.mcpServers.'relewise-agent-gateway'
        if ($server.httpUrl -ne 'https://my.relewise.com/agents/mcp') { throw 'Universal Google package has the wrong Agent Gateway MCP endpoint.' }
    } elseif ($vendor -eq 'claude') {
        if ($manifest.mcpServers -ne './.claude-plugin/mcp.json') {
            throw 'Claude universal package does not reference its protected MCP configuration.'
        }
        $mcpPath = Join-Path $packageRoot '.claude-plugin\mcp.json'
        if (-not (Test-Path -LiteralPath $mcpPath -PathType Leaf)) {
            throw 'Claude universal package is missing its protected Agent Gateway MCP configuration.'
        }
        $mcp = Get-Content -Raw -LiteralPath $mcpPath | ConvertFrom-Json
        if ($mcp.mcpServers.'relewise-agent-gateway'.url -ne 'https://my.relewise.com/agents/mcp' -or
            $null -ne $mcp.mcpServers.'relewise-agent-gateway'.headers) {
            throw 'Claude universal package has the wrong OAuth Agent Gateway MCP configuration.'
        }
    } elseif ($vendor -eq 'openai') {
        $server = $manifest.mcpServers.'relewise-agent-gateway'
        if ($server.url -ne 'https://my.relewise.com/agents/mcp' -or $null -ne $server.bearer_token_env_var) {
            throw 'OpenAI universal package has the wrong OAuth MCP configuration.'
        }
    } else {
        if (-not (Test-Path -LiteralPath (Join-Path $packageRoot '.mcp.json') -PathType Leaf)) {
            throw "$vendor universal package is missing its Agent Gateway MCP configuration."
        }
        $mcp = Get-Content -Raw -LiteralPath (Join-Path $packageRoot '.mcp.json') | ConvertFrom-Json
        if ($mcp.mcpServers.'relewise-agent-gateway'.url -ne 'https://my.relewise.com/agents/mcp') {
            throw "$vendor universal package has the wrong Agent Gateway MCP endpoint."
        }
    }
    if ((Test-Path -LiteralPath (Join-Path $packageRoot 'scripts')) -or (Test-Path -LiteralPath (Join-Path $packageRoot 'libexec'))) {
        throw "$vendor universal package has a duplicated plugin-level CLI payload."
    }
}

Write-Host 'Universal package tests passed.'

param([string] $RepositoryRoot = (Resolve-Path "$PSScriptRoot/../..").Path)
$ErrorActionPreference = 'Stop'
$expectedRoot = Join-Path ([IO.Path]::GetTempPath()) "relewise-configuration-$([guid]::NewGuid())"
try {
    & "$PSScriptRoot/../../tools/package/sync-plugin-configuration.ps1" -OutputRoot $expectedRoot
    $paths = @('.agents/plugins/marketplace.json', 'gemini-extension.json')
    foreach ($name in @('relewise', 'relewise-developer')) {
        $paths += @("plugins/$name/.claude-plugin/plugin.json", "plugins/$name/.codex-plugin/plugin.json", "plugins/$name/mcp.json")
        $endpoint = if ($name -eq 'relewise') { 'https://my.relewise.com/agents/mcp' } else { 'https://mcp.relewise.com' }
        $serverName = if ($name -eq 'relewise') { 'relewise-agent-gateway' } else { 'relewise-developer' }
        $canonical = Get-Content -Raw "$RepositoryRoot/plugins/$name/.mcp.json" | ConvertFrom-Json -AsHashtable
        if ($canonical.Count -ne 1 -or $canonical.mcpServers.Count -ne 1) { throw "$name must define exactly one MCP server." }
        $server = $canonical.mcpServers[$serverName]
        if ($server.Count -ne 2 -or $server.type -ne 'http' -or $server.url -ne $endpoint) {
            throw "$name MCP must contain only its HTTP type and endpoint; credentials belong to the client."
        }
        $portablePath = "$RepositoryRoot/plugins/$name/mcp.json"
        if (-not (Test-Json -LiteralPath $portablePath -SchemaFile "$PSScriptRoot/../../contracts/agent-plugins-v1-mcp.schema.json")) {
            throw "$name has invalid Agent Plugins MCP configuration."
        }
    }
    foreach ($path in $paths) {
        $expected = Get-Content -Raw "$expectedRoot/$path" | ConvertFrom-Json -AsHashtable | ConvertTo-Json -Depth 100 -Compress
        $actual = Get-Content -Raw "$RepositoryRoot/$path" | ConvertFrom-Json -AsHashtable | ConvertTo-Json -Depth 100 -Compress
        if ($actual -cne $expected) { throw "Generated configuration is stale: $path. Run Refresh marketplace payload." }
    }
    foreach ($path in @('.github/plugin/marketplace.json', 'vendors/openai/marketplace.json')) {
        if (Test-Path "$RepositoryRoot/$path") { throw "Redundant marketplace catalog: $path" }
    }
    Write-Host 'Canonical and generated plugin configurations match; MCP uses no packaged credentials.'
} finally {
    $resolved = [IO.Path]::GetFullPath($expectedRoot)
    if ($resolved.StartsWith([IO.Path]::GetFullPath([IO.Path]::GetTempPath()), [StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $resolved)) {
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}

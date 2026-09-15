param(
    [Parameter(Mandatory)] [ValidateSet('relewise', 'relewise-developer')] [string] $PluginName,
    [Parameter(Mandatory)] [ValidateSet('claude', 'openai', 'github-copilot', 'google')] [string] $Vendor,
    [Parameter(Mandatory)] [string] $OutputRoot,
    [string] $Version
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = (Resolve-Path "$PSScriptRoot/../..").Path
$sourceRoot = Join-Path $repositoryRoot "plugins/$PluginName"
$source = Get-Content -Raw "$sourceRoot/plugin.json" | ConvertFrom-Json -AsHashtable
$mcp = Get-Content -Raw "$sourceRoot/.mcp.json" | ConvertFrom-Json -AsHashtable
if (-not $Version) { $Version = $source.version }
$manifest = [ordered]@{}
foreach ($field in @('name', 'description', 'author', 'homepage', 'repository', 'license', 'keywords')) {
    if ($source.ContainsKey($field)) { $manifest[$field] = $source[$field] }
}
$manifest.version = $Version
function Write-Json($relativePath, $value) {
    $path = Join-Path $OutputRoot $relativePath
    New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
    [IO.File]::WriteAllText($path, ($value | ConvertTo-Json -Depth 100) + "`n", [Text.UTF8Encoding]::new($false))
}
switch ($Vendor) {
    'github-copilot' {
        $manifest = $source
        $manifest.version = $Version
        $mcp['$schema'] = 'https://agent-plugins.org/schemas/1.0.0/mcp.schema.json'
        foreach ($server in $mcp.mcpServers.Values) {
            if ($server.type -ne 'http') { throw 'Only canonical HTTP MCP servers are supported.' }
            $server.type = 'streamable-http'
        }
        Write-Json 'plugin.json' $manifest
        Write-Json 'mcp.json' $mcp
    }
    'google' {
        if ($PluginName -ne 'relewise') { throw 'Only Relewise is distributed as a Gemini extension.' }
        $servers = [ordered]@{}
        foreach ($entry in $mcp.mcpServers.GetEnumerator()) {
            $servers[$entry.Key] = @{ httpUrl = $entry.Value.url }
        }
        Write-Json 'gemini-extension.json' ([ordered]@{
            name = $source.name; version = $Version; description = $source.description; mcpServers = $servers
        })
    }
    default {
        $overrides = Get-Content -Raw "$repositoryRoot/vendors/$Vendor/$PluginName.json" | ConvertFrom-Json -AsHashtable
        foreach ($field in $overrides.Keys) { $manifest[$field] = $overrides[$field] }
        $manifest.mcpServers = './.mcp.json'
        if ($Vendor -eq 'openai') {
            $manifest.skills = './skills/'
            $manifest.interface.longDescription = $source.description
            $manifest.interface.developerName = $source.author.name
            $manifest.interface.websiteURL = $source.homepage
        }
        $directory = if ($Vendor -eq 'claude') { '.claude-plugin' } else { '.codex-plugin' }
        Write-Json "$directory/plugin.json" $manifest
        $mcpDestination = [IO.Path]::GetFullPath((Join-Path $OutputRoot '.mcp.json'))
        if ($mcpDestination -ne [IO.Path]::GetFullPath("$sourceRoot/.mcp.json")) {
            Copy-Item -LiteralPath "$sourceRoot/.mcp.json" -Destination $mcpDestination -Force
        }
    }
}

param([string] $OutputRoot, [string] $Version)
$ErrorActionPreference = 'Stop'
$repositoryRoot = (Resolve-Path "$PSScriptRoot/../..").Path
if (-not $OutputRoot) { $OutputRoot = $repositoryRoot }
foreach ($name in @('relewise', 'relewise-developer')) {
    foreach ($vendor in @('claude', 'openai', 'github-copilot')) {
        & "$PSScriptRoot/write-plugin-configuration.ps1" -PluginName $name -Vendor $vendor -OutputRoot "$OutputRoot/plugins/$name" -Version $Version
    }
}
$plannedVersion = (Get-Content -Raw "$repositoryRoot/version.json" | ConvertFrom-Json).version
& "$PSScriptRoot/write-plugin-configuration.ps1" -PluginName relewise -Vendor google -OutputRoot $OutputRoot -Version $plannedVersion
$catalog = Get-Content -Raw "$repositoryRoot/.claude-plugin/marketplace.json" | ConvertFrom-Json
$entries = foreach ($entry in $catalog.plugins) {
    [ordered]@{
        name = $entry.name
        source = [ordered]@{ source = 'local'; path = $entry.source }
        policy = [ordered]@{ installation = 'AVAILABLE'; authentication = 'ON_INSTALL' }
        category = (Get-Content -Raw "$repositoryRoot/vendors/openai/$($entry.name).json" | ConvertFrom-Json).interface.category
    }
}
$codex = [ordered]@{ name = $catalog.name; interface = @{ displayName = $catalog.owner.name }; plugins = @($entries) }
$path = Join-Path $OutputRoot '.agents/plugins/marketplace.json'
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
[IO.File]::WriteAllText($path, ($codex | ConvertTo-Json -Depth 100) + "`n", [Text.UTF8Encoding]::new($false))

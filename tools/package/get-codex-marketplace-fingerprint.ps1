$ErrorActionPreference = 'Stop'
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$includedPaths = @(
    'version.json',
    '.agents/plugins/marketplace.json',
    '.github/workflows/refresh-marketplace.yml',
    'src/relewise-agent',
    'generated/operations.json',
    'plugins/relewise/plugin.json',
    'plugins/relewise/assets',
    'plugins/relewise/skills',
    'plugins/relewise-developer/.mcp.json',
    'plugins/relewise-developer/README.md',
    'plugins/relewise-developer/assets',
    'plugins/relewise-developer/plugin.json',
    'plugins/relewise-developer/skills',
    '.claude-plugin/marketplace.json',
    '.github/plugin/marketplace.json',
    'vendors/claude/relewise/.claude-plugin/plugin.json',
    'vendors/claude/relewise-developer/.claude-plugin/plugin.json',
    'vendors/openai/relewise/.codex-plugin/plugin.json',
    'vendors/openai/relewise-developer/.codex-plugin/plugin.json',
    'vendors/openai/relewise/scripts/relewise-agent',
    'vendors/openai/marketplace.json',
    'tools/package/openai.ps1',
    'tools/package/relewise-developer.ps1',
    'tools/package/get-runtime-fingerprint.ps1'
)

$files = @(& git -C $repositoryRoot ls-files -- @includedPaths | Sort-Object)
if ($LASTEXITCODE -ne 0 -or $files.Count -eq 0) {
    throw 'Unable to resolve Codex marketplace source files.'
}

$builder = [Text.StringBuilder]::new()
foreach ($file in $files) {
    if (@('plugins/relewise/plugin.json', 'plugins/relewise-developer/plugin.json') -contains $file.Replace('\', '/')) {
        # Version is generated output. Hash every other manifest field so metadata
        # changes invalidate the payload without making the fingerprint circular.
        $manifest = Get-Content -Raw -LiteralPath (Join-Path $repositoryRoot $file) | ConvertFrom-Json
        $manifest.PSObject.Properties.Remove('version')
        $normalized = $manifest | ConvertTo-Json -Depth 100 -Compress
        $normalizedBytes = [Text.Encoding]::UTF8.GetBytes($normalized)
        $hash = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($normalizedBytes)).ToLowerInvariant()
    } else {
        $hash = (& git -C $repositoryRoot hash-object -- $file | Out-String).Trim()
        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($hash)) {
            throw "Unable to hash '$file'."
        }
    }
    [void] $builder.Append($file.Replace('\', '/')).Append("`n").Append($hash).Append("`n")
}

$bytes = [Text.Encoding]::UTF8.GetBytes($builder.ToString())
$fingerprint = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($bytes)).ToLowerInvariant()
Write-Output $fingerprint

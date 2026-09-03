$ErrorActionPreference = 'Stop'
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$expectedPath = Join-Path $repositoryRoot 'plugins\relewise\.codex-plugin\source.sha256'
$expected = (Get-Content -Raw -LiteralPath $expectedPath).Trim()
$actual = (& (Join-Path $repositoryRoot 'tools\package\get-codex-marketplace-fingerprint.ps1') | Out-String).Trim()

if ($actual -ne $expected) {
    throw "The committed marketplace payload is stale. Expected fingerprint '$expected', calculated '$actual'. Ask a maintainer to run the Refresh marketplace payload workflow on this branch."
}

Write-Host "Marketplace source fingerprint is current: $actual"

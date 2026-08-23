param(
    [string] $PluginsRoot
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
if ([string]::IsNullOrWhiteSpace($PluginsRoot)) {
    $PluginsRoot = Join-Path $repositoryRoot 'plugins'
}
$resolvedPluginsRoot = (Resolve-Path -LiteralPath $PluginsRoot).Path
$validator = Get-Command agentskills -ErrorAction Stop
$skillFiles = Get-ChildItem -LiteralPath $resolvedPluginsRoot -Recurse -Filter 'SKILL.md' -File
if ($skillFiles.Count -eq 0) {
    throw "No Agent Skills found under '$resolvedPluginsRoot'."
}

foreach ($skillFile in $skillFiles) {
    & $validator.Source validate $skillFile.Directory.FullName
    if ($LASTEXITCODE -ne 0) {
        throw "Agent Skills validation failed for '$($skillFile.Directory.FullName)'."
    }
}

Write-Host "Validated $($skillFiles.Count) skill(s) against the Agent Skills specification."

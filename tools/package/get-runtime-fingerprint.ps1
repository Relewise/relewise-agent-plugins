$ErrorActionPreference = 'Stop'
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$includedPaths = @(
    'version.json',
    'src/relewise-agent',
    'generated/operations.json',
    'tools/package/get-runtime-fingerprint.ps1'
)

$files = @(& git -C $repositoryRoot ls-files -- @includedPaths | Sort-Object)
if ($LASTEXITCODE -ne 0 -or $files.Count -eq 0) {
    throw 'Unable to resolve runtime source files.'
}

$builder = [Text.StringBuilder]::new()
foreach ($file in $files) {
    $hash = (& git -C $repositoryRoot hash-object -- $file | Out-String).Trim()
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($hash)) {
        throw "Unable to hash '$file'."
    }
    [void] $builder.Append($file.Replace('\', '/')).Append("`n").Append($hash).Append("`n")
}

$bytes = [Text.Encoding]::UTF8.GetBytes($builder.ToString())
$fingerprint = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($bytes)).ToLowerInvariant()
Write-Output $fingerprint

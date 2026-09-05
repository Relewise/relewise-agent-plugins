param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-z0-9]+(?:-[a-z0-9]+)*$')]
    [string] $PluginName,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$')]
    [string] $Version,

    [Parameter(Mandatory = $true)]
    [string] $PluginRoot,

    [string] $OutputDirectory
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$resolvedPluginRoot = (Resolve-Path -LiteralPath $PluginRoot).Path
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $repositoryRoot 'artifacts\release-plugin'
}
$resolvedOutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $resolvedOutputDirectory | Out-Null
$archivePath = Join-Path $resolvedOutputDirectory "$PluginName-claude-plugin-v$Version.zip"
if (Test-Path -LiteralPath $archivePath) { Remove-Item -LiteralPath $archivePath -Force }

Add-Type -AssemblyName System.IO.Compression
$stream = [IO.File]::Open($archivePath, [IO.FileMode]::CreateNew)
try {
    $archive = [IO.Compression.ZipArchive]::new(
        $stream,
        [IO.Compression.ZipArchiveMode]::Create,
        $false,
        [Text.Encoding]::UTF8)
    try {
        foreach ($file in Get-ChildItem -LiteralPath $resolvedPluginRoot -Recurse -Force -File) {
            $relative = [IO.Path]::GetRelativePath($resolvedPluginRoot, $file.FullName).Replace('\', '/')
            $entry = $archive.CreateEntry($relative, [IO.Compression.CompressionLevel]::Optimal)
            $isExecutable =
                $relative -eq 'scripts/relewise-agent' -or
                $relative -like 'libexec/*/relewise-agent' -or
                $relative -like 'libexec/*/relewise-agent.exe'
            $unixMode = if ($isExecutable) { 0x81ED } else { 0x81A4 }
            $entry.ExternalAttributes = $unixMode -shl 16

            $input = [IO.File]::OpenRead($file.FullName)
            try {
                $output = $entry.Open()
                try { $input.CopyTo($output) }
                finally { $output.Dispose() }
            }
            finally { $input.Dispose() }
        }
    }
    finally { $archive.Dispose() }
}
finally { $stream.Dispose() }

Write-Host "Created Claude plugin archive $archivePath"

$ErrorActionPreference = 'Stop'
$executable = Join-Path $PSScriptRoot 'libexec\win-x64\relewise-agent.exe'

if (-not (Test-Path -LiteralPath $executable -PathType Leaf)) {
    throw "Relewise Agent executable not found: $executable"
}

& $executable @args
exit $LASTEXITCODE

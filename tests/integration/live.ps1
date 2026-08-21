param(
    [Parameter(Mandatory = $true)]
    [string] $ExecutablePath
)

$ErrorActionPreference = 'Stop'
$resolvedExecutable = (Resolve-Path -LiteralPath $ExecutablePath).Path
$token = $env:RELEWISE_AGENT_GATEWAY_TOKEN
$primaryDatasetId = $env:RELEWISE_AGENT_GATEWAY_TEST_DATASET_ID_PRIMARY
$secondaryDatasetId = $env:RELEWISE_AGENT_GATEWAY_TEST_DATASET_ID_SECONDARY

if ([string]::IsNullOrWhiteSpace($token)) {
    throw 'RELEWISE_AGENT_GATEWAY_TOKEN is not configured.'
}

foreach ($datasetId in @($primaryDatasetId, $secondaryDatasetId)) {
    if (-not [Guid]::TryParse($datasetId, [ref]([Guid]::Empty))) {
        throw 'Both integration test Dataset variables must contain valid UUIDs.'
    }
}

function Invoke-Agent {
    param([string[]] $Arguments)

    $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $resolvedExecutable
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    foreach ($argument in $Arguments) {
        $startInfo.ArgumentList.Add($argument)
    }

    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    $process.Start() | Out-Null
    $stdout = $process.StandardOutput.ReadToEndAsync()
    $stderr = $process.StandardError.ReadToEndAsync()
    $process.WaitForExit()

    if ($process.ExitCode -ne 0) {
        $safeOutput = $stdout.Result.Replace($token, '[REDACTED]', [StringComparison]::Ordinal).Trim()
        throw "relewise-agent failed with exit code $($process.ExitCode): $safeOutput"
    }

    if ($stderr.Result.Trim()) {
        throw 'relewise-agent wrote unexpected stderr output.'
    }

    try {
        return $stdout.Result | ConvertFrom-Json
    }
    catch {
        throw 'relewise-agent did not emit one valid JSON document.'
    }
}

function Assert-Success {
    param($Response, [string] $Command)

    if ($Response.success -ne $true) {
        throw "$Command did not return success."
    }
}

$me = Invoke-Agent @('me')
Assert-Success $me 'me'
$meDatasetIds = @($me.data.licenses | ForEach-Object { $_.datasets } | ForEach-Object { $_.id })
foreach ($datasetId in @($primaryDatasetId, $secondaryDatasetId)) {
    if ($meDatasetIds -notcontains $datasetId) {
        throw 'The test PAT does not expose both configured integration Datasets through /me.'
    }
}
Write-Host 'Authenticated identity and PAT Dataset scope verified.'

$datasets = Invoke-Agent @('datasets')
Assert-Success $datasets 'datasets'
foreach ($datasetId in @($primaryDatasetId, $secondaryDatasetId)) {
    if ($datasets.data.datasets.id -notcontains $datasetId) {
        throw 'Dataset discovery did not return both configured integration Datasets.'
    }
}
Write-Host 'Dataset discovery verified.'

foreach ($datasetId in @($primaryDatasetId, $secondaryDatasetId)) {
    $dataset = Invoke-Agent @('dataset', $datasetId)
    Assert-Success $dataset 'dataset'
    if ($dataset.data.agentGatewayPolicy.restApiEnabled -ne $true -or
        $dataset.data.agentGatewayPolicy.areas -notcontains 'Core') {
        throw 'An integration Dataset does not allow the Core REST Area.'
    }
}
Write-Host 'Dataset access and effective Agent Gateway policies verified.'

$toDate = [DateOnly]::FromDateTime([DateTime]::UtcNow)
$fromDate = $toDate.AddDays(-6)
$inputPath = Join-Path ([System.IO.Path]::GetTempPath()) "relewise-agent-integration-$([Guid]::NewGuid().ToString('N')).json"
try {
    @{
        parameters = @{
            fromDate = $fromDate.ToString('yyyy-MM-dd')
            toDate = $toDate.ToString('yyyy-MM-dd')
        }
    } | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath $inputPath -Encoding utf8NoBOM

    foreach ($datasetId in @($primaryDatasetId, $secondaryDatasetId)) {
        $metadata = Invoke-Agent @(
            'call',
            'CoreGetDatasetMetadata',
            '--dataset',
            $datasetId,
            '--input',
            $inputPath)
        Assert-Success $metadata 'call CoreGetDatasetMetadata'
        if ($metadata.data.statusCode -ne 200 -or $null -eq $metadata.data.response.metadata) {
            throw 'CoreGetDatasetMetadata did not return its expected response contract.'
        }
    }
}
finally {
    Remove-Item -LiteralPath $inputPath -Force -ErrorAction SilentlyContinue
}
Write-Host 'Generic operation execution verified for both integration Datasets.'


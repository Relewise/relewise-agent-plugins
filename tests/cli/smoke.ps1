param(
    [Parameter(Mandatory = $true)]
    [string] $ExecutablePath
)

$ErrorActionPreference = 'Stop'
$resolvedExecutable = (Resolve-Path -LiteralPath $ExecutablePath).Path

function Invoke-Agent {
    param([string[]] $Arguments)

    $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $resolvedExecutable
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.Environment.Remove('RELEWISE_AGENT_GATEWAY_TOKEN') | Out-Null
    foreach ($argument in $Arguments) {
        $startInfo.ArgumentList.Add($argument)
    }

    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    $process.Start() | Out-Null
    $stdout = $process.StandardOutput.ReadToEndAsync()
    $stderr = $process.StandardError.ReadToEndAsync()
    $process.WaitForExit()

    [pscustomobject]@{
        ExitCode = $process.ExitCode
        Stdout = $stdout.Result.Trim()
        Stderr = $stderr.Result.Trim()
    }
}

function Assert-Equal {
    param($Actual, $Expected, [string] $Message)

    if ($Actual -ne $Expected) {
        throw "$Message Expected '$Expected', got '$Actual'."
    }
}

function Read-JsonResult {
    param($Result)

    if ($Result.Stderr) {
        throw "The CLI wrote unexpected stderr output: $($Result.Stderr)"
    }

    try {
        return $Result.Stdout | ConvertFrom-Json
    }
    catch {
        throw "The CLI did not emit one valid JSON document. Output: $($Result.Stdout)"
    }
}

$versionResult = Invoke-Agent @('--version')
$version = Read-JsonResult $versionResult
Assert-Equal $versionResult.ExitCode 0 '--version exit code.'
Assert-Equal $version.success $true '--version success field.'
Assert-Equal $version.data.name 'relewise-agent' '--version application name.'

$helpResult = Invoke-Agent @('--help')
$help = Read-JsonResult $helpResult
Assert-Equal $helpResult.ExitCode 0 '--help exit code.'
Assert-Equal $help.success $true '--help success field.'
if ($help.data.commands -notcontains 'call <operation-id> --dataset <dataset-id> [--input <path>]') {
    throw '--help does not advertise the generic call command.'
}

$operationsResult = Invoke-Agent @('operations')
$operations = Read-JsonResult $operationsResult
Assert-Equal $operationsResult.ExitCode 0 'operations exit code.'
Assert-Equal $operations.success $true 'operations success field.'
if ($operations.data.count -lt 1 -or $operations.data.operations.Count -ne $operations.data.count) {
    throw 'operations returned an invalid catalog count.'
}

$schemaResult = Invoke-Agent @('schema', 'CoreGetDataset')
$schema = Read-JsonResult $schemaResult
Assert-Equal $schemaResult.ExitCode 0 'schema exit code.'
Assert-Equal $schema.data.operation.operationId 'CoreGetDataset' 'schema operation ID.'

$missingOperationResult = Invoke-Agent @('schema', 'OperationThatDoesNotExist')
$missingOperation = Read-JsonResult $missingOperationResult
Assert-Equal $missingOperationResult.ExitCode 3 'Unknown operation exit code.'
Assert-Equal $missingOperation.error.type 'operation_not_found' 'Unknown operation error type.'

$validationResult = Invoke-Agent @('call', 'CoreGetDataset', '--dataset', 'not-a-uuid')
$validation = Read-JsonResult $validationResult
Assert-Equal $validationResult.ExitCode 8 'Validation failure exit code.'
Assert-Equal $validation.error.type 'validation_error' 'Validation failure error type.'

$authenticationResult = Invoke-Agent @('me')
$authentication = Read-JsonResult $authenticationResult
Assert-Equal $authenticationResult.ExitCode 4 'Missing authentication exit code.'
Assert-Equal $authentication.error.type 'authentication_error' 'Missing authentication error type.'

Write-Host "CLI smoke tests passed for $resolvedExecutable"

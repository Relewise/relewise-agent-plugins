$ErrorActionPreference = 'Stop'

$sourceUri = 'https://my.relewise.com/agents/openapi/v1.json'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$outputPath = Join-Path $repositoryRoot 'contracts/agent-gateway-v1.json'

$httpClient = [System.Net.Http.HttpClient]::new()
$httpClient.DefaultRequestHeaders.UserAgent.ParseAdd('relewise-agent-plugins-contract-updater/1.0')

try {
    $response = $httpClient.GetAsync($sourceUri).GetAwaiter().GetResult()
    [void]$response.EnsureSuccessStatusCode()
    $content = $response.Content.ReadAsByteArrayAsync().GetAwaiter().GetResult()

    $document = [System.Text.Json.JsonDocument]::Parse(
        [System.Text.Encoding]::UTF8.GetString($content)
    )
    $document.Dispose()

    [System.IO.File]::WriteAllBytes($outputPath, $content)
    Write-Output "Updated $outputPath ($($content.Length) bytes)."
}
finally {
    $httpClient.Dispose()
}

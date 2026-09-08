param(
    [uri] $OpenApiSourceUri = 'https://my.relewise.com/agents/openapi/v1.json',

    # TODO: Change this default to https://my.relewise.com/agents/mcp/v1.json
    # as soon as the public MCP catalog endpoint is deployed.
    [uri] $McpCatalogSourceUri = 'https://localhost:5100/agents/mcp/v1.json'
)

$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$sources = @(
    @{
        Name = 'OpenAPI contract'
        Uri = $OpenApiSourceUri
        OutputPath = Join-Path $repositoryRoot 'contracts/agent-gateway-v1.json'
    },
    @{
        Name = 'MCP tool catalog'
        Uri = $McpCatalogSourceUri
        OutputPath = Join-Path $repositoryRoot 'contracts/agent-gateway-mcp-v1.json'
    }
)

function Get-JsonContent([uri] $uri) {
    $handler = [System.Net.Http.HttpClientHandler]::new()
    if ($uri.IsLoopback) {
        # ASP.NET's local development certificate may not be trusted by every
        # PowerShell host. Never disable certificate checks for remote sources.
        $handler.ServerCertificateCustomValidationCallback =
            [System.Net.Http.HttpClientHandler]::DangerousAcceptAnyServerCertificateValidator
    }
    $httpClient = [System.Net.Http.HttpClient]::new($handler)
    $httpClient.DefaultRequestHeaders.UserAgent.ParseAdd('relewise-agent-plugins-contract-updater/1.0')
    try {
        $response = $httpClient.GetAsync($uri).GetAwaiter().GetResult()
        try {
            [void]$response.EnsureSuccessStatusCode()
            $content = $response.Content.ReadAsByteArrayAsync().GetAwaiter().GetResult()
        }
        finally {
            $response.Dispose()
        }

        $document = [System.Text.Json.JsonDocument]::Parse(
            [System.Text.Encoding]::UTF8.GetString($content)
        )
        $document.Dispose()
        return $content
    }
    finally {
        $httpClient.Dispose()
        $handler.Dispose()
    }
}

$downloads = foreach ($source in $sources) {
    @{
        Name = $source.Name
        OutputPath = $source.OutputPath
        Content = Get-JsonContent $source.Uri
    }
}

# Write only after both downloads have succeeded and parsed as JSON so a
# failed refresh cannot leave the two public contracts out of sync.
foreach ($download in $downloads) {
    [System.IO.File]::WriteAllBytes($download.OutputPath, $download.Content)
    Write-Output "Updated $($download.OutputPath) from $($download.Name) ($($download.Content.Length) bytes)."
}

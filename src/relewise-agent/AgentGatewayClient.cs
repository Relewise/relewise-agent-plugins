using System.Net;
using System.Net.Http.Headers;
using System.Text.Json;

internal sealed class AgentGatewayClient : IDisposable
{
    private static readonly Uri BaseAddress = new("https://my.relewise.com/agents/");
    private readonly HttpClient httpClient;

    public AgentGatewayClient()
    {
        httpClient = new HttpClient
        {
            BaseAddress = BaseAddress,
            Timeout = TimeSpan.FromSeconds(30)
        };
        httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
        httpClient.DefaultRequestHeaders.UserAgent.ParseAdd("relewise-agent/0.1.0");
    }

    public async Task<GatewayCallResult> GetCurrentUserAsync(string token)
    {
        using var request = new HttpRequestMessage(HttpMethod.Get, "api/v1/me");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);

        using var response = await httpClient.SendAsync(
            request,
            HttpCompletionOption.ResponseHeadersRead);

        if (response.IsSuccessStatusCode)
        {
            try
            {
                await using var stream = await response.Content.ReadAsStreamAsync();
                using var document = await JsonDocument.ParseAsync(stream);
                return GatewayCallResult.Succeeded(document.RootElement.Clone());
            }
            catch (JsonException)
            {
                return GatewayCallResult.Failed(
                    "api_error",
                    "The Agent Gateway returned an invalid JSON response.",
                    6,
                    (int)response.StatusCode);
            }
        }

        return response.StatusCode switch
        {
            HttpStatusCode.Unauthorized or HttpStatusCode.Forbidden => GatewayCallResult.Failed(
                "authentication_error",
                "The Agent Gateway rejected the configured Personal Access Token.",
                4,
                (int)response.StatusCode),
            _ => GatewayCallResult.Failed(
                "api_error",
                $"The Agent Gateway returned HTTP {(int)response.StatusCode}.",
                6,
                (int)response.StatusCode)
        };
    }

    public void Dispose()
    {
        httpClient.Dispose();
    }
}

internal sealed record GatewayCallResult(
    bool Success,
    JsonElement? Data,
    string? ErrorType,
    string? ErrorMessage,
    int ExitCode,
    int? StatusCode)
{
    public static GatewayCallResult Succeeded(JsonElement data) =>
        new(true, data, null, null, 0, null);

    public static GatewayCallResult Failed(
        string errorType,
        string errorMessage,
        int exitCode,
        int? statusCode) =>
        new(false, null, errorType, errorMessage, exitCode, statusCode);
}

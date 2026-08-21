using System.Net;
using System.Net.Http.Headers;
using System.Text;
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
        return await GetJsonAsync(
            token,
            "api/v1/me",
            forbiddenErrorType: "authentication_error",
            forbiddenExitCode: 4);
    }

    public async Task<GatewayCallResult> GetDatasetAsync(string token, Guid datasetId)
    {
        return await GetJsonAsync(
            token,
            $"api/v1/datasets/{datasetId:D}/core/dataset",
            forbiddenErrorType: "dataset_access_error",
            forbiddenExitCode: 7,
            notFoundErrorType: "dataset_access_error",
            notFoundExitCode: 7);
    }

    public async Task<GatewayCallResult> ExecuteAsync(
        string token,
        string method,
        string requestUri,
        JsonElement? body)
    {
        using var request = new HttpRequestMessage(new HttpMethod(method), requestUri);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
        if (body is not null)
        {
            request.Content = new StringContent(
                body.Value.GetRawText(),
                Encoding.UTF8,
                "application/json");
        }

        using var response = await httpClient.SendAsync(
            request,
            HttpCompletionOption.ResponseHeadersRead);

        if (response.IsSuccessStatusCode)
        {
            return await ReadSuccessResponseAsync(response);
        }

        return response.StatusCode switch
        {
            HttpStatusCode.Unauthorized => GatewayCallResult.Failed(
                "authentication_error",
                "The Agent Gateway rejected the configured Personal Access Token.",
                4,
                (int)response.StatusCode),
            HttpStatusCode.Forbidden => GatewayCallResult.Failed(
                "dataset_access_error",
                "The Dataset policy does not allow the requested Agent Gateway operation.",
                7,
                (int)response.StatusCode),
            _ => GatewayCallResult.Failed(
                "api_error",
                $"The Agent Gateway returned HTTP {(int)response.StatusCode}.",
                6,
                (int)response.StatusCode)
        };
    }

    private async Task<GatewayCallResult> GetJsonAsync(
        string token,
        string requestUri,
        string forbiddenErrorType,
        int forbiddenExitCode,
        string? notFoundErrorType = null,
        int? notFoundExitCode = null)
    {
        using var request = new HttpRequestMessage(HttpMethod.Get, requestUri);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);

        using var response = await httpClient.SendAsync(
            request,
            HttpCompletionOption.ResponseHeadersRead);

        if (response.IsSuccessStatusCode)
        {
            return await ReadSuccessResponseAsync(response);
        }

        return response.StatusCode switch
        {
            HttpStatusCode.Unauthorized => GatewayCallResult.Failed(
                "authentication_error",
                "The Agent Gateway rejected the configured Personal Access Token.",
                4,
                (int)response.StatusCode),
            HttpStatusCode.Forbidden => GatewayCallResult.Failed(
                forbiddenErrorType,
                forbiddenErrorType == "dataset_access_error"
                    ? "The configured Personal Access Token cannot access the requested Dataset operation."
                    : "The Agent Gateway rejected the configured Personal Access Token.",
                forbiddenExitCode,
                (int)response.StatusCode),
            HttpStatusCode.NotFound when notFoundErrorType is not null => GatewayCallResult.Failed(
                notFoundErrorType,
                "The requested Dataset is not accessible or no longer exists.",
                notFoundExitCode!.Value,
                (int)response.StatusCode),
            _ => GatewayCallResult.Failed(
                "api_error",
                $"The Agent Gateway returned HTTP {(int)response.StatusCode}.",
                6,
                (int)response.StatusCode)
        };
    }

    private static async Task<GatewayCallResult> ReadSuccessResponseAsync(HttpResponseMessage response)
    {
        try
        {
            await using var stream = await response.Content.ReadAsStreamAsync();
            using var document = await JsonDocument.ParseAsync(stream);
            return GatewayCallResult.Succeeded(
                document.RootElement.Clone(),
                (int)response.StatusCode);
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
    public static GatewayCallResult Succeeded(JsonElement data, int statusCode) =>
        new(true, data, null, null, 0, statusCode);

    public static GatewayCallResult Failed(
        string errorType,
        string errorMessage,
        int exitCode,
        int? statusCode) =>
        new(false, null, errorType, errorMessage, exitCode, statusCode);
}

using System.Net;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;

internal sealed class AgentGatewayClient : IDisposable
{
    private static readonly Uri BaseAddress = new("https://my.relewise.com/agents/");
    private const int MaximumErrorBodyBytes = 64 * 1024;
    private readonly HttpClient httpClient;

    public AgentGatewayClient()
    {
        httpClient = new HttpClient
        {
            BaseAddress = BaseAddress,
            Timeout = TimeSpan.FromSeconds(30)
        };
        httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
        httpClient.DefaultRequestHeaders.UserAgent.ParseAdd($"relewise-agent/{CliApplication.ApplicationVersion}");
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

        return await CreateFailureResultAsync(
            response,
            forbiddenErrorType: "dataset_access_error",
            forbiddenExitCode: 7);
    }

    private static async Task<GatewayCallResult> CreateFailureResultAsync(
        HttpResponseMessage response,
        string forbiddenErrorType,
        int forbiddenExitCode,
        string? notFoundErrorType = null,
        int? notFoundExitCode = null)
    {
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
                await ReadApiErrorMessageAsync(response),
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

        return await CreateFailureResultAsync(
            response,
            forbiddenErrorType,
            forbiddenExitCode,
            notFoundErrorType,
            notFoundExitCode);
    }

    private static async Task<string> ReadApiErrorMessageAsync(HttpResponseMessage response)
    {
        var fallback = $"The Agent Gateway returned HTTP {(int)response.StatusCode}.";
        if (response.Content.Headers.ContentLength > MaximumErrorBodyBytes)
        {
            return fallback;
        }

        try
        {
            await using var stream = await response.Content.ReadAsStreamAsync();
            using var buffer = new MemoryStream();
            var bytes = new byte[4096];
            while (buffer.Length <= MaximumErrorBodyBytes)
            {
                var remaining = MaximumErrorBodyBytes + 1 - (int)buffer.Length;
                var read = await stream.ReadAsync(bytes.AsMemory(0, Math.Min(bytes.Length, remaining)));
                if (read == 0)
                {
                    break;
                }

                await buffer.WriteAsync(bytes.AsMemory(0, read));
            }

            if (buffer.Length > MaximumErrorBodyBytes)
            {
                return fallback;
            }

            buffer.Position = 0;
            using var document = await JsonDocument.ParseAsync(buffer);
            var detail = FindErrorDetail(document.RootElement);
            return detail is null ? fallback : $"Agent Gateway: {detail}";
        }
        catch (JsonException)
        {
            return fallback;
        }
        catch (IOException)
        {
            return fallback;
        }
    }

    private static string? FindErrorDetail(JsonElement root)
    {
        if (root.ValueKind != JsonValueKind.Object)
        {
            return null;
        }

        foreach (var propertyName in new[] { "detail", "message", "title" })
        {
            if (root.TryGetProperty(propertyName, out var value) &&
                value.ValueKind == JsonValueKind.String)
            {
                var text = value.GetString()?.Trim();
                if (!string.IsNullOrEmpty(text))
                {
                    return text.Length <= 500 ? text : $"{text[..497]}...";
                }
            }
        }

        return null;
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

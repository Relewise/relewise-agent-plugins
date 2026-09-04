using System.Reflection;
using System.Text.Json;
using System.Text.Json.Serialization.Metadata;

internal static class CliApplication
{
    private const string ApplicationName = "relewise-agent";
    private const string AuthenticationSetupSkill = "relewise-setup";
    private const string AuthenticationSetupUrl = "https://docs.relewise.com/docs/myrelewise/agent-gateway/personal-access-tokens.html";
    private const string TokenEnvironmentVariable = "RELEWISE_AGENT_GATEWAY_TOKEN";
    internal static readonly string ApplicationVersion =
        typeof(CliApplication).Assembly
            .GetCustomAttribute<AssemblyInformationalVersionAttribute>()?
            .InformationalVersion.Split('+', 2)[0]
        ?? "0.0.0";

    public static async Task<int> RunAsync(string[] args)
    {
        try
        {
            return await RunCommandAsync(args);
        }
        catch (FormatException)
        {
            return WriteError(
                "authentication_error",
                $"{TokenEnvironmentVariable} is not a valid bearer token value.",
                4,
                code: "token_invalid");
        }
        catch (RequestValidationException exception)
        {
            return WriteError(
                "validation_error",
                exception.Message,
                8,
                operationId: exception.OperationId);
        }
        catch (TaskCanceledException)
        {
            return WriteError(
                "network_error",
                "The Agent Gateway request timed out.",
                5);
        }
        catch (HttpRequestException)
        {
            return WriteError(
                "network_error",
                "The Agent Gateway could not be reached.",
                5);
        }
        catch (AgentGatewayResponseException)
        {
            return WriteError(
                "api_error",
                "The Agent Gateway response did not match the versioned API contract.",
                6);
        }
        catch (Exception)
        {
            return WriteError(
                "internal_error",
                "The command could not be completed because the embedded operation catalog is unavailable.",
                1);
        }
    }

    private static async Task<int> RunCommandAsync(string[] args)
    {
        if (args.Length == 0 || args is ["--help"] or ["-h"])
        {
            WriteJson(new HelpResponse(
                Success: true,
                Data: new HelpData(
                    Name: ApplicationName,
                    Version: ApplicationVersion,
                    Commands: ["me", "datasets", "dataset <dataset-id>", "operations", "schema <operation-id>", "call <operation-id> --dataset <dataset-id> [--input <path>]", "--help", "--version"])),
                AgentJsonContext.Default.HelpResponse);
            return 0;
        }

        if (args is ["--version"])
        {
            WriteJson(new VersionResponse(
                Success: true,
                Data: new VersionData(ApplicationName, ApplicationVersion)),
                AgentJsonContext.Default.VersionResponse);
            return 0;
        }

        if (args is ["me"])
        {
            return await RunMeAsync();
        }

        if (args.Length > 0 && string.Equals(args[0], "me", StringComparison.Ordinal))
        {
            return WriteError("invalid_arguments", "Usage: relewise-agent me", 2);
        }

        if (args is ["datasets"])
        {
            return await RunDatasetsAsync();
        }

        if (args.Length > 0 && string.Equals(args[0], "datasets", StringComparison.Ordinal))
        {
            return WriteError("invalid_arguments", "Usage: relewise-agent datasets", 2);
        }

        if (args is ["dataset", var datasetId])
        {
            return await RunDatasetAsync(datasetId);
        }

        if (args.Length > 0 && string.Equals(args[0], "dataset", StringComparison.Ordinal))
        {
            return WriteError("invalid_arguments", "Usage: relewise-agent dataset <dataset-id>", 2);
        }

        if (args.Length > 0 && string.Equals(args[0], "call", StringComparison.Ordinal))
        {
            return await RunCallAsync(args);
        }

        if (args is ["operations"])
        {
            var operations = OperationCatalog.Load().GetSummaries();
            WriteJson(new OperationsResponse(
                Success: true,
                Data: new OperationsData(operations.Length, operations)),
                AgentJsonContext.Default.OperationsResponse);
            return 0;
        }

        if (args.Length > 0 && string.Equals(args[0], "operations", StringComparison.Ordinal))
        {
            return WriteError("invalid_arguments", "Usage: relewise-agent operations", 2);
        }

        if (args is ["schema", var operationId])
        {
            var operation = OperationCatalog.Load().Find(operationId);
            if (operation is null)
            {
                return WriteError(
                    "operation_not_found",
                    $"Operation '{operationId}' does not exist in the embedded Agent Gateway contract.",
                    3);
            }

            WriteJson(new SchemaResponse(
                Success: true,
                Data: new SchemaData(operation.Value)),
                AgentJsonContext.Default.SchemaResponse);
            return 0;
        }

        if (args.Length > 0 && string.Equals(args[0], "schema", StringComparison.Ordinal))
        {
            return WriteError("invalid_arguments", "Usage: relewise-agent schema <operation-id>", 2);
        }

        return WriteError("command_not_found", $"Unknown command '{args[0]}'.", 2);
    }

    private static async Task<int> RunMeAsync()
    {
        var token = ReadToken();
        if (token is null)
        {
            return WriteError(
                "authentication_error",
                $"Relewise is not connected. Follow the '{AuthenticationSetupSkill}' skill to securely configure a Personal Access Token.",
                4,
                code: "token_not_configured");
        }

        using var client = new AgentGatewayClient();
        var result = await client.GetCurrentUserAsync(token);
        if (!result.Success)
        {
            return WriteGatewayError(result, "IdentityGetCurrentUser");
        }

        WriteJson(new MeResponse(
            Success: true,
            Data: result.Data!.Value),
            AgentJsonContext.Default.MeResponse);
        return 0;
    }

    private static async Task<int> RunDatasetsAsync()
    {
        var token = ReadToken();
        if (token is null)
        {
            return WriteError(
                "authentication_error",
                $"Relewise is not connected. Follow the '{AuthenticationSetupSkill}' skill to securely configure a Personal Access Token.",
                4,
                code: "token_not_configured");
        }

        using var client = new AgentGatewayClient();
        var result = await client.GetCurrentUserAsync(token);
        if (!result.Success)
        {
            return WriteGatewayError(result, "IdentityGetCurrentUser");
        }

        var datasets = DatasetCatalog.FromCurrentUser(result.Data!.Value);
        WriteJson(new DatasetsResponse(
            Success: true,
            Data: new DatasetsData(datasets.Length, datasets)),
            AgentJsonContext.Default.DatasetsResponse);
        return 0;
    }

    private static async Task<int> RunDatasetAsync(string datasetIdValue)
    {
        if (!Guid.TryParse(datasetIdValue, out var datasetId))
        {
            return WriteError(
                "dataset_access_error",
                $"Dataset ID '{datasetIdValue}' is not a valid UUID.",
                7,
                operationId: "CoreGetDataset");
        }

        var token = ReadToken();
        if (token is null)
        {
            return WriteError(
                "authentication_error",
                $"Relewise is not connected. Follow the '{AuthenticationSetupSkill}' skill to securely configure a Personal Access Token.",
                4,
                code: "token_not_configured");
        }

        using var client = new AgentGatewayClient();
        var currentUser = await client.GetCurrentUserAsync(token);
        if (!currentUser.Success)
        {
            return WriteGatewayError(currentUser, "IdentityGetCurrentUser");
        }

        var datasets = DatasetCatalog.FromCurrentUser(currentUser.Data!.Value);
        if (!datasets.Any(dataset => Guid.TryParse(dataset.Id, out var accessibleId) && accessibleId == datasetId))
        {
            return WriteError(
                "dataset_access_error",
                $"Dataset '{datasetId:D}' is not accessible to the configured Personal Access Token.",
                7,
                operationId: "CoreGetDataset");
        }

        var result = await client.GetDatasetAsync(token, datasetId);
        if (!result.Success)
        {
            return WriteGatewayError(result, "CoreGetDataset");
        }

        WriteJson(new DatasetResponse(
            Success: true,
            Data: result.Data!.Value),
            AgentJsonContext.Default.DatasetResponse);
        return 0;
    }

    private static async Task<int> RunCallAsync(string[] args)
    {
        var options = CallOptions.Parse(args);
        var operation = OperationCatalog.Load().Find(options.OperationId);
        if (operation is null)
        {
            return WriteError(
                "operation_not_found",
                $"Operation '{options.OperationId}' does not exist in the embedded Agent Gateway contract.",
                3,
                operationId: options.OperationId);
        }

        var request = OperationRequestBuilder.Build(
            operation.Value,
            options.DatasetId,
            options.InputPath);
        var token = ReadToken();
        if (token is null)
        {
            return WriteError(
                "authentication_error",
                $"Relewise is not connected. Follow the '{AuthenticationSetupSkill}' skill to securely configure a Personal Access Token.",
                4,
                operationId: options.OperationId,
                code: "token_not_configured");
        }

        using var client = new AgentGatewayClient();
        var currentUser = await client.GetCurrentUserAsync(token);
        if (!currentUser.Success)
        {
            return WriteGatewayError(currentUser, "IdentityGetCurrentUser");
        }

        var datasets = DatasetCatalog.FromCurrentUser(currentUser.Data!.Value);
        if (!datasets.Any(dataset =>
            Guid.TryParse(dataset.Id, out var accessibleId) &&
            accessibleId == options.DatasetId))
        {
            return WriteError(
                "dataset_access_error",
                $"Dataset '{options.DatasetId:D}' is not accessible to the configured Personal Access Token.",
                7,
                operationId: options.OperationId);
        }

        var datasetDetails = await client.GetDatasetAsync(token, options.DatasetId);
        if (!datasetDetails.Success)
        {
            return WriteGatewayError(datasetDetails, "CoreGetDataset");
        }

        var policy = DatasetCatalog.FromDatasetDetails(datasetDetails.Data!.Value);
        if (!policy.RestApiEnabled)
        {
            return WriteError(
                "dataset_access_error",
                "Agent Gateway REST access is disabled for the requested Dataset.",
                7,
                operationId: options.OperationId);
        }

        if (!policy.Allows(request.Area))
        {
            return WriteError(
                "dataset_access_error",
                $"Dataset policy does not enable Agent Gateway Area '{request.Area}'.",
                7,
                operationId: options.OperationId);
        }

        var result = await client.ExecuteAsync(
            token,
            request.Method,
            request.RequestUri,
            request.Body);
        if (!result.Success)
        {
            return WriteGatewayError(result, options.OperationId);
        }

        WriteJson(new CallResponse(
            Success: true,
            Data: new CallData(
                OperationId: options.OperationId,
                DatasetId: options.DatasetId.ToString("D"),
                StatusCode: result.StatusCode!.Value,
                Response: result.Data!.Value)),
            AgentJsonContext.Default.CallResponse);
        return 0;
    }

    private static string? ReadToken()
    {
        var token = Environment.GetEnvironmentVariable(TokenEnvironmentVariable);
        return string.IsNullOrWhiteSpace(token) ? null : token;
    }

    private static int WriteGatewayError(GatewayCallResult result, string operationId)
    {
        return WriteError(
            result.ErrorType!,
            result.ErrorMessage!,
            result.ExitCode,
            operationId,
            result.StatusCode,
            code: result.ErrorType == "authentication_error" ? "token_rejected" : null);
    }

    private static int WriteError(
        string type,
        string message,
        int exitCode,
        string? operationId = null,
        int? statusCode = null,
        string? code = null)
    {
        var token = ReadToken();
        if (token is not null)
        {
            message = message.Replace(token, "[REDACTED]", StringComparison.Ordinal);
        }

        var help = type == "authentication_error"
            ? new ErrorHelp(
                AuthenticationSetupSkill,
                "authentication-setup",
                TokenEnvironmentVariable,
                AuthenticationSetupUrl)
            : null;

        WriteJson(new ErrorResponse(
            Success: false,
            Error: new ErrorDetails(type, code, message, operationId, statusCode, help)),
            AgentJsonContext.Default.ErrorResponse);
        return exitCode;
    }

    private static void WriteJson<T>(T value, JsonTypeInfo<T> typeInfo)
    {
        Console.WriteLine(JsonSerializer.Serialize(value, typeInfo));
    }
}

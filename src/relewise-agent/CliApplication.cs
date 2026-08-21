using System.Text.Json;
using System.Text.Json.Serialization.Metadata;

internal static class CliApplication
{
    private const string ApplicationName = "relewise-agent";
    private const string ApplicationVersion = "0.1.0";

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
                "RELEWISE_AGENT_GATEWAY_TOKEN is not a valid bearer token value.",
                4);
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
                    Commands: ["me", "operations", "schema <operation-id>", "--help", "--version"])),
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
        var token = Environment.GetEnvironmentVariable("RELEWISE_AGENT_GATEWAY_TOKEN");
        if (string.IsNullOrWhiteSpace(token))
        {
            return WriteError(
                "authentication_error",
                "RELEWISE_AGENT_GATEWAY_TOKEN is not configured.",
                4);
        }

        using var client = new AgentGatewayClient();
        var result = await client.GetCurrentUserAsync(token);
        if (!result.Success)
        {
            return WriteError(
                result.ErrorType!,
                result.ErrorMessage!,
                result.ExitCode,
                operationId: "IdentityGetCurrentUser",
                statusCode: result.StatusCode);
        }

        WriteJson(new MeResponse(
            Success: true,
            Data: result.Data!.Value),
            AgentJsonContext.Default.MeResponse);
        return 0;
    }

    private static int WriteError(
        string type,
        string message,
        int exitCode,
        string? operationId = null,
        int? statusCode = null)
    {
        WriteJson(new ErrorResponse(
            Success: false,
            Error: new ErrorDetails(type, message, operationId, statusCode)),
            AgentJsonContext.Default.ErrorResponse);
        return exitCode;
    }

    private static void WriteJson<T>(T value, JsonTypeInfo<T> typeInfo)
    {
        Console.WriteLine(JsonSerializer.Serialize(value, typeInfo));
    }
}

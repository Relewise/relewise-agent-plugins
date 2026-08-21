using System.Reflection;
using System.Text.Json;

internal sealed class OperationCatalog
{
    private const string ResourceName = "Relewise.Agent.operations.json";
    private readonly JsonElement[] operations;

    private OperationCatalog(JsonElement[] operations)
    {
        this.operations = operations;
    }

    public static OperationCatalog Load()
    {
        using var stream = Assembly.GetExecutingAssembly().GetManifestResourceStream(ResourceName)
            ?? throw new InvalidDataException($"Embedded resource '{ResourceName}' was not found.");
        using var document = JsonDocument.Parse(stream);
        var operations = document.RootElement.GetProperty("operations")
            .EnumerateArray()
            .Select(operation => operation.Clone())
            .ToArray();
        return new OperationCatalog(operations);
    }

    public OperationSummary[] GetSummaries()
    {
        return operations.Select(operation => new OperationSummary(
            OperationId: operation.GetProperty("operationId").GetString()!,
            Method: operation.GetProperty("method").GetString()!,
            Path: operation.GetProperty("path").GetString()!,
            Tags: operation.GetProperty("tags")
                .EnumerateArray()
                .Select(tag => tag.GetString()!)
                .ToArray(),
            Summary: operation.GetProperty("summary").GetString()))
            .ToArray();
    }

    public JsonElement? Find(string operationId)
    {
        foreach (var operation in operations)
        {
            if (string.Equals(
                operation.GetProperty("operationId").GetString(),
                operationId,
                StringComparison.Ordinal))
            {
                return operation;
            }
        }

        return null;
    }
}

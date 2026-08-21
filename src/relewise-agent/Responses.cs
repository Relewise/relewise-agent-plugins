using System.Text.Json;
using System.Text.Json.Serialization;

internal sealed record HelpResponse(bool Success, HelpData Data);
internal sealed record HelpData(string Name, string Version, string[] Commands);
internal sealed record VersionResponse(bool Success, VersionData Data);
internal sealed record VersionData(string Name, string Version);
internal sealed record MeResponse(bool Success, JsonElement Data);
internal sealed record OperationsResponse(bool Success, OperationsData Data);
internal sealed record OperationsData(int Count, OperationSummary[] Operations);
internal sealed record OperationSummary(string OperationId, string Method, string Path, string[] Tags, string? Summary);
internal sealed record SchemaResponse(bool Success, SchemaData Data);
internal sealed record SchemaData(JsonElement Operation);
internal sealed record ErrorResponse(bool Success, ErrorDetails Error);
internal sealed record ErrorDetails(string Type, string Message, string? OperationId, int? StatusCode);

[JsonSourceGenerationOptions(
    PropertyNamingPolicy = JsonKnownNamingPolicy.CamelCase,
    DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull)]
[JsonSerializable(typeof(HelpResponse))]
[JsonSerializable(typeof(VersionResponse))]
[JsonSerializable(typeof(MeResponse))]
[JsonSerializable(typeof(OperationsResponse))]
[JsonSerializable(typeof(SchemaResponse))]
[JsonSerializable(typeof(ErrorResponse))]
internal partial class AgentJsonContext : JsonSerializerContext;

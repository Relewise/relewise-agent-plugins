using System.Text.Json;
using System.Text.Json.Serialization;

internal sealed record HelpResponse(bool Success, HelpData Data);
internal sealed record HelpData(string Name, string Version, string[] Commands);
internal sealed record VersionResponse(bool Success, VersionData Data);
internal sealed record VersionData(string Name, string Version);
internal sealed record MeResponse(bool Success, JsonElement Data);
internal sealed record DatasetsResponse(bool Success, DatasetsData Data);
internal sealed record DatasetsData(int Count, DatasetSummary[] Datasets);
internal sealed record DatasetSummary(
    string Id,
    string DisplayName,
    string Type,
    string LicenseId,
    string LicenseDisplayName);
internal sealed record DatasetResponse(bool Success, JsonElement Data);
internal sealed record OperationsResponse(bool Success, OperationsData Data);
internal sealed record OperationsData(int Count, OperationSummary[] Operations);
internal sealed record OperationSummary(string OperationId, string Method, string Path, string[] Tags, string? Summary);
internal sealed record SchemaResponse(bool Success, SchemaData Data);
internal sealed record SchemaData(JsonElement Operation);
internal sealed record ErrorResponse(bool Success, ErrorDetails Error);
internal sealed record ErrorDetails(string Type, string Message, string? OperationId, int? StatusCode);

internal sealed record CurrentUserContract(LicenseContract[] Licenses);
internal sealed record LicenseContract(string Id, string DisplayName, DatasetContract[]? Datasets);
internal sealed record DatasetContract(string Id, string DisplayName, string Type);

[JsonSourceGenerationOptions(
    PropertyNamingPolicy = JsonKnownNamingPolicy.CamelCase,
    DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull)]
[JsonSerializable(typeof(HelpResponse))]
[JsonSerializable(typeof(VersionResponse))]
[JsonSerializable(typeof(MeResponse))]
[JsonSerializable(typeof(DatasetsResponse))]
[JsonSerializable(typeof(DatasetResponse))]
[JsonSerializable(typeof(CurrentUserContract))]
[JsonSerializable(typeof(OperationsResponse))]
[JsonSerializable(typeof(SchemaResponse))]
[JsonSerializable(typeof(ErrorResponse))]
internal partial class AgentJsonContext : JsonSerializerContext;

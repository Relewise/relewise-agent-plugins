using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.Json.Serialization.Metadata;

const string applicationName = "relewise-agent";
const string applicationVersion = "0.1.0";

if (args.Length == 0 || args is ["--help"] or ["-h"])
{
    WriteJson(new HelpResponse(
        Success: true,
        Data: new HelpData(
            Name: applicationName,
            Version: applicationVersion,
            Commands: ["--help", "--version"])),
        AgentJsonContext.Default.HelpResponse);
    return 0;
}

if (args is ["--version"])
{
    WriteJson(new VersionResponse(
        Success: true,
        Data: new VersionData(applicationName, applicationVersion)),
        AgentJsonContext.Default.VersionResponse);
    return 0;
}

WriteJson(new ErrorResponse(
    Success: false,
    Error: new ErrorDetails(
        Type: "command_not_found",
        Message: $"Unknown command '{args[0]}'.")),
    AgentJsonContext.Default.ErrorResponse);
return 2;

static void WriteJson<T>(T value, JsonTypeInfo<T> typeInfo)
{
    Console.WriteLine(JsonSerializer.Serialize(value, typeInfo));
}

internal sealed record HelpResponse(bool Success, HelpData Data);
internal sealed record HelpData(string Name, string Version, string[] Commands);
internal sealed record VersionResponse(bool Success, VersionData Data);
internal sealed record VersionData(string Name, string Version);
internal sealed record ErrorResponse(bool Success, ErrorDetails Error);
internal sealed record ErrorDetails(string Type, string Message);

[JsonSourceGenerationOptions(PropertyNamingPolicy = JsonKnownNamingPolicy.CamelCase)]
[JsonSerializable(typeof(HelpResponse))]
[JsonSerializable(typeof(VersionResponse))]
[JsonSerializable(typeof(ErrorResponse))]
internal partial class AgentJsonContext : JsonSerializerContext;

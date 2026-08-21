using System.Security.Cryptography;
using System.Text;
using System.Text.Encodings.Web;
using System.Text.Json;
using System.Text.Json.Nodes;

return GenerateContract.Run(args);

internal static class GenerateContract
{
    private static readonly HashSet<string> HttpMethods = new(StringComparer.OrdinalIgnoreCase)
    {
        "get", "put", "post", "delete", "options", "head", "patch", "trace"
    };

    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        WriteIndented = true,
        Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping
    };

    public static int Run(string[] args)
    {
        try
        {
            var repositoryRoot = FindRepositoryRoot();
            var contractPath = Path.Combine(repositoryRoot, "contracts", "agent-gateway-v1.json");
            var generatedRoot = Path.Combine(repositoryRoot, "generated");

            ParseArguments(args, ref contractPath, ref generatedRoot);
            Generate(Path.GetFullPath(contractPath), Path.GetFullPath(generatedRoot));
            return 0;
        }
        catch (Exception exception)
        {
            Console.Error.WriteLine($"Contract generation failed: {exception.Message}");
            return 1;
        }
    }

    private static void Generate(string contractPath, string generatedRoot)
    {
        var sourceBytes = File.ReadAllBytes(contractPath);
        var document = JsonNode.Parse(sourceBytes)?.AsObject()
            ?? throw new InvalidDataException("The OpenAPI contract is empty.");

        RequireObject(document, "paths");
        var schemas = RequireObject(RequireObject(document, "components"), "schemas");
        var operations = ExtractOperations(document);

        Directory.CreateDirectory(generatedRoot);
        var schemasDirectory = Path.Combine(generatedRoot, "schemas");
        Directory.CreateDirectory(schemasDirectory);

        foreach (var existingFile in Directory.EnumerateFiles(schemasDirectory, "*.json"))
        {
            File.Delete(existingFile);
        }

        var schemaIndex = GenerateSchemas(schemas, schemasDirectory);
        var normalizedSource = Encoding.UTF8.GetBytes(
            Encoding.UTF8.GetString(sourceBytes).Replace("\r\n", "\n").Replace("\r", "\n"));
        var sourceHash = Convert.ToHexString(SHA256.HashData(normalizedSource)).ToLowerInvariant();
        var catalog = new JsonObject
        {
            ["source"] = "contracts/agent-gateway-v1.json",
            ["sourceSha256"] = sourceHash,
            ["openapi"] = document["openapi"]?.GetValue<string>(),
            ["apiVersion"] = document["info"]?["version"]?.GetValue<string>(),
            ["operationCount"] = operations.Count,
            ["operations"] = operations
        };

        WriteJson(Path.Combine(generatedRoot, "operations.json"), catalog);
        WriteJson(Path.Combine(schemasDirectory, "index.json"), new JsonObject
        {
            ["schemaCount"] = schemaIndex.Count,
            ["schemas"] = schemaIndex
        });

        Console.WriteLine($"Generated {operations.Count} operations and {schemaIndex.Count} schemas.");
    }

    private static JsonArray ExtractOperations(JsonObject document)
    {
        var paths = RequireObject(document, "paths");
        var operationIds = new HashSet<string>(StringComparer.Ordinal);
        var operations = new List<JsonObject>();

        foreach (var pathEntry in paths.OrderBy(entry => entry.Key, StringComparer.Ordinal))
        {
            var pathItem = pathEntry.Value?.AsObject()
                ?? throw new InvalidDataException($"Path '{pathEntry.Key}' is not an object.");

            foreach (var methodEntry in pathItem
                .Where(entry => HttpMethods.Contains(entry.Key))
                .OrderBy(entry => entry.Key, StringComparer.Ordinal))
            {
                var operation = methodEntry.Value?.AsObject()
                    ?? throw new InvalidDataException($"Operation '{methodEntry.Key} {pathEntry.Key}' is not an object.");
                var operationId = operation["operationId"]?.GetValue<string>();

                if (string.IsNullOrWhiteSpace(operationId))
                {
                    throw new InvalidDataException($"Operation '{methodEntry.Key.ToUpperInvariant()} {pathEntry.Key}' has no operationId.");
                }

                if (!operationIds.Add(operationId))
                {
                    throw new InvalidDataException($"Duplicate operationId '{operationId}'.");
                }

                var parameters = CombineParameters(pathItem["parameters"], operation["parameters"]);
                operations.Add(new JsonObject
                {
                    ["operationId"] = operationId,
                    ["method"] = methodEntry.Key.ToUpperInvariant(),
                    ["path"] = pathEntry.Key,
                    ["tags"] = CloneOrDefault(operation["tags"], new JsonArray()),
                    ["summary"] = CloneOrNull(operation["summary"]),
                    ["description"] = CloneOrNull(operation["description"]),
                    ["pathParameters"] = ExtractParameters(parameters, "path"),
                    ["queryParameters"] = ExtractParameters(parameters, "query"),
                    ["requestBody"] = ExtractRequestBody(operation["requestBody"]),
                    ["responses"] = ExtractResponses(operation["responses"])
                });
            }
        }

        var result = new JsonArray();
        foreach (var operation in operations.OrderBy(item => item["operationId"]!.GetValue<string>(), StringComparer.Ordinal))
        {
            result.Add(operation);
        }

        return result;
    }

    private static JsonArray CombineParameters(JsonNode? pathParameters, JsonNode? operationParameters)
    {
        var result = new JsonArray();
        AddParameters(pathParameters, result);
        AddParameters(operationParameters, result);
        return result;
    }

    private static void AddParameters(JsonNode? parameters, JsonArray destination)
    {
        if (parameters is null)
        {
            return;
        }

        foreach (var parameter in parameters.AsArray())
        {
            destination.Add(parameter?.DeepClone());
        }
    }

    private static JsonArray ExtractParameters(JsonArray parameters, string location)
    {
        var result = new JsonArray();

        foreach (var parameterNode in parameters)
        {
            var parameter = parameterNode?.AsObject()
                ?? throw new InvalidDataException("An operation parameter is not an object.");
            if (!string.Equals(parameter["in"]?.GetValue<string>(), location, StringComparison.Ordinal))
            {
                continue;
            }

            result.Add(new JsonObject
            {
                ["name"] = parameter["name"]?.GetValue<string>(),
                ["required"] = parameter["required"]?.GetValue<bool>() ?? false,
                ["description"] = CloneOrNull(parameter["description"]),
                ["schema"] = CloneOrNull(parameter["schema"])
            });
        }

        return result;
    }

    private static JsonNode? ExtractRequestBody(JsonNode? requestBodyNode)
    {
        if (requestBodyNode is null)
        {
            return null;
        }

        var requestBody = requestBodyNode.AsObject();
        return new JsonObject
        {
            ["required"] = requestBody["required"]?.GetValue<bool>() ?? false,
            ["description"] = CloneOrNull(requestBody["description"]),
            ["content"] = ExtractContentSchemas(requestBody["content"])
        };
    }

    private static JsonObject ExtractResponses(JsonNode? responsesNode)
    {
        var result = new JsonObject();
        if (responsesNode is null)
        {
            return result;
        }

        foreach (var responseEntry in responsesNode.AsObject().OrderBy(entry => entry.Key, StringComparer.Ordinal))
        {
            var response = responseEntry.Value?.AsObject()
                ?? throw new InvalidDataException($"Response '{responseEntry.Key}' is not an object.");
            result[responseEntry.Key] = new JsonObject
            {
                ["description"] = CloneOrNull(response["description"]),
                ["content"] = ExtractContentSchemas(response["content"])
            };
        }

        return result;
    }

    private static JsonObject ExtractContentSchemas(JsonNode? contentNode)
    {
        var result = new JsonObject();
        if (contentNode is null)
        {
            return result;
        }

        foreach (var contentEntry in contentNode.AsObject().OrderBy(entry => entry.Key, StringComparer.Ordinal))
        {
            result[contentEntry.Key] = CloneOrNull(contentEntry.Value?["schema"]);
        }

        return result;
    }

    private static JsonArray GenerateSchemas(JsonObject schemas, string schemasDirectory)
    {
        var index = new JsonArray();
        var fileNames = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        foreach (var schemaEntry in schemas.OrderBy(entry => entry.Key, StringComparer.Ordinal))
        {
            var fileName = $"{ToSafeFileName(schemaEntry.Key)}.json";
            if (!fileNames.Add(fileName))
            {
                throw new InvalidDataException($"Schema file name collision for '{schemaEntry.Key}'.");
            }

            WriteJson(Path.Combine(schemasDirectory, fileName), schemaEntry.Value);
            index.Add(new JsonObject
            {
                ["name"] = schemaEntry.Key,
                ["file"] = fileName
            });
        }

        return index;
    }

    private static string ToSafeFileName(string value)
    {
        return new string(value.Select(character =>
            char.IsAsciiLetterOrDigit(character) || character is '.' or '_' or '-'
                ? character
                : '_').ToArray());
    }

    private static void WriteJson(string path, JsonNode? value)
    {
        var json = value?.ToJsonString(JsonOptions)
            ?? throw new InvalidDataException($"Cannot write an empty JSON document to '{path}'.");
        File.WriteAllText(path, json + "\n", new UTF8Encoding(encoderShouldEmitUTF8Identifier: false));
    }

    private static JsonObject RequireObject(JsonObject parent, string propertyName)
    {
        return parent[propertyName]?.AsObject()
            ?? throw new InvalidDataException($"The OpenAPI contract has no '{propertyName}' object.");
    }

    private static JsonNode? CloneOrNull(JsonNode? node) => node?.DeepClone();

    private static JsonNode CloneOrDefault(JsonNode? node, JsonNode defaultValue) => node?.DeepClone() ?? defaultValue;

    private static void ParseArguments(string[] args, ref string contractPath, ref string generatedRoot)
    {
        for (var index = 0; index < args.Length; index++)
        {
            switch (args[index])
            {
                case "--contract" when index + 1 < args.Length:
                    contractPath = args[++index];
                    break;
                case "--output" when index + 1 < args.Length:
                    generatedRoot = args[++index];
                    break;
                default:
                    throw new ArgumentException($"Unknown or incomplete argument '{args[index]}'. Use --contract <path> or --output <directory>.");
            }
        }
    }

    private static string FindRepositoryRoot()
    {
        foreach (var startingPath in new[] { Directory.GetCurrentDirectory(), AppContext.BaseDirectory })
        {
            var directory = new DirectoryInfo(startingPath);
            while (directory is not null)
            {
                if (File.Exists(Path.Combine(directory.FullName, "contracts", "agent-gateway-v1.json")))
                {
                    return directory.FullName;
                }

                directory = directory.Parent;
            }
        }

        throw new DirectoryNotFoundException("Could not locate the repository root containing contracts/agent-gateway-v1.json.");
    }
}

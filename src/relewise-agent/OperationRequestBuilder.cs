using System.Globalization;
using System.Text.Json;

internal static class OperationRequestBuilder
{
    private const int MaximumInputBytes = 1024 * 1024;

    public static PreparedOperationRequest Build(
        JsonElement operation,
        Guid datasetId,
        string? inputPath)
    {
        var operationId = operation.GetProperty("operationId").GetString()!;
        var path = operation.GetProperty("path").GetString()!;
        if (!path.Contains("{datasetId}", StringComparison.Ordinal))
        {
            throw new RequestValidationException(
                $"Operation '{operationId}' is not Dataset-scoped and cannot be used with call.",
                operationId);
        }

        using var inputDocument = ReadInput(inputPath, operationId);
        var input = inputDocument.RootElement;
        ValidateInputEnvelope(input, operationId);
        var parameters = input.TryGetProperty("parameters", out var parametersElement)
            ? parametersElement
            : default;

        path = path.Replace("{datasetId}", datasetId.ToString("D"), StringComparison.Ordinal);
        var knownParameters = new HashSet<string>(StringComparer.Ordinal);

        foreach (var parameter in operation.GetProperty("pathParameters").EnumerateArray())
        {
            var name = parameter.GetProperty("name").GetString()!;
            if (name == "datasetId")
            {
                continue;
            }

            knownParameters.Add(name);
            var value = GetParameterValue(parameters, parameter, operationId);
            path = path.Replace(
                $"{{{name}}}",
                Uri.EscapeDataString(FormatParameter(value!.Value, parameter, operationId)),
                StringComparison.Ordinal);
        }

        var query = new List<string>();
        foreach (var parameter in operation.GetProperty("queryParameters").EnumerateArray())
        {
            var name = parameter.GetProperty("name").GetString()!;
            knownParameters.Add(name);
            var value = GetParameterValue(parameters, parameter, operationId, allowMissing: true);
            if (value is null)
            {
                continue;
            }

            query.Add($"{Uri.EscapeDataString(name)}={Uri.EscapeDataString(FormatParameter(value.Value, parameter, operationId))}");
        }

        ValidateUnknownParameters(parameters, knownParameters, operationId);
        if (query.Count > 0)
        {
            path += "?" + string.Join("&", query);
        }

        var body = ExtractBody(input, operation.GetProperty("requestBody"), operationId);
        return new PreparedOperationRequest(
            Method: operation.GetProperty("method").GetString()!,
            RequestUri: path.TrimStart('/'),
            Body: body,
            Area: operation.GetProperty("tags").EnumerateArray().FirstOrDefault().GetString());
    }

    private static JsonDocument ReadInput(string? inputPath, string operationId)
    {
        if (inputPath is null)
        {
            return JsonDocument.Parse("{}");
        }

        try
        {
            var file = new FileInfo(inputPath);
            if (!file.Exists)
            {
                throw new RequestValidationException("The input file does not exist.", operationId);
            }

            if (file.Length > MaximumInputBytes)
            {
                throw new RequestValidationException("The input file exceeds the 1 MiB limit.", operationId);
            }

            return JsonDocument.Parse(
                File.ReadAllBytes(file.FullName),
                new JsonDocumentOptions { MaxDepth = 64 });
        }
        catch (RequestValidationException)
        {
            throw;
        }
        catch (JsonException)
        {
            throw new RequestValidationException("The input file is not valid JSON.", operationId);
        }
        catch (IOException)
        {
            throw new RequestValidationException("The input file could not be read.", operationId);
        }
        catch (UnauthorizedAccessException)
        {
            throw new RequestValidationException("The input file could not be read.", operationId);
        }
    }

    private static void ValidateInputEnvelope(JsonElement input, string operationId)
    {
        if (input.ValueKind != JsonValueKind.Object)
        {
            throw new RequestValidationException("The input JSON root must be an object.", operationId);
        }

        foreach (var property in input.EnumerateObject())
        {
            if (property.Name is not ("parameters" or "body"))
            {
                throw new RequestValidationException(
                    $"Unknown input property '{property.Name}'. Expected 'parameters' or 'body'.",
                    operationId);
            }
        }

        if (input.TryGetProperty("parameters", out var parameters) && parameters.ValueKind != JsonValueKind.Object)
        {
            throw new RequestValidationException("Input property 'parameters' must be an object.", operationId);
        }
    }

    private static JsonElement? GetParameterValue(
        JsonElement parameters,
        JsonElement parameter,
        string operationId,
        bool allowMissing = false)
    {
        var name = parameter.GetProperty("name").GetString()!;
        if (parameters.ValueKind == JsonValueKind.Object && parameters.TryGetProperty(name, out var value))
        {
            return value;
        }

        var required = parameter.GetProperty("required").GetBoolean();
        if (required && !allowMissing)
        {
            throw new RequestValidationException($"Required parameter '{name}' is missing.", operationId);
        }

        if (required && allowMissing)
        {
            throw new RequestValidationException($"Required parameter '{name}' is missing.", operationId);
        }

        return null;
    }

    private static string FormatParameter(
        JsonElement value,
        JsonElement parameter,
        string operationId)
    {
        var name = parameter.GetProperty("name").GetString()!;
        var type = parameter.GetProperty("schema").GetProperty("type").GetString();
        return type switch
        {
            "string" when value.ValueKind == JsonValueKind.String => value.GetString()!,
            "boolean" when value.ValueKind is JsonValueKind.True or JsonValueKind.False =>
                value.GetBoolean().ToString().ToLowerInvariant(),
            "integer" when value.ValueKind == JsonValueKind.Number && value.TryGetInt64(out var integer) =>
                integer.ToString(CultureInfo.InvariantCulture),
            "number" when value.ValueKind == JsonValueKind.Number => value.GetRawText(),
            _ => throw new RequestValidationException(
                $"Parameter '{name}' must be a JSON {type}.",
                operationId)
        };
    }

    private static void ValidateUnknownParameters(
        JsonElement parameters,
        HashSet<string> knownParameters,
        string operationId)
    {
        if (parameters.ValueKind != JsonValueKind.Object)
        {
            return;
        }

        foreach (var property in parameters.EnumerateObject())
        {
            if (!knownParameters.Contains(property.Name))
            {
                throw new RequestValidationException(
                    $"Parameter '{property.Name}' is not defined for operation '{operationId}'.",
                    operationId);
            }
        }
    }

    private static JsonElement? ExtractBody(
        JsonElement input,
        JsonElement requestBodyDefinition,
        string operationId)
    {
        var operationAcceptsBody = requestBodyDefinition.ValueKind == JsonValueKind.Object;
        var hasBody = input.TryGetProperty("body", out var body);

        if (!operationAcceptsBody && hasBody)
        {
            throw new RequestValidationException(
                $"Operation '{operationId}' does not accept a request body.",
                operationId);
        }

        if (operationAcceptsBody && requestBodyDefinition.GetProperty("required").GetBoolean() && !hasBody)
        {
            throw new RequestValidationException("Required input property 'body' is missing.", operationId);
        }

        return hasBody ? body.Clone() : null;
    }
}

internal sealed record PreparedOperationRequest(
    string Method,
    string RequestUri,
    JsonElement? Body,
    string? Area);

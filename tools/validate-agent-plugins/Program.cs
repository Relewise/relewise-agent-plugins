using System.Text.Json;
using System.Text.RegularExpressions;

var repositoryRoot = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..", ".."));
var schemaPath = Path.Combine(repositoryRoot, "contracts", "agent-plugins-v1-plugin.schema.json");
using var schemaDocument = JsonDocument.Parse(File.ReadAllText(schemaPath));
var schema = schemaDocument.RootElement;
var manifests = Directory.GetDirectories(Path.Combine(repositoryRoot, "plugins"))
    .Select(pluginRoot => Path.Combine(pluginRoot, "plugin.json"))
    .Where(File.Exists)
    .ToArray();
var errors = new List<string>();

foreach (var manifestPath in manifests)
{
    using var manifestDocument = JsonDocument.Parse(File.ReadAllText(manifestPath));
    Validate(manifestDocument.RootElement, schema, Path.GetRelativePath(repositoryRoot, manifestPath), errors);

    var pluginRoot = Path.GetDirectoryName(manifestPath)!;
    var expectedName = Path.GetFileName(pluginRoot);
    if (!manifestDocument.RootElement.TryGetProperty("name", out var name) || name.GetString() != expectedName)
        errors.Add($"{Path.GetRelativePath(repositoryRoot, manifestPath)}: name must match directory '{expectedName}'.");

    var skillsRoot = Path.Combine(pluginRoot, "skills");
    if (!Directory.Exists(skillsRoot) || !Directory.EnumerateDirectories(skillsRoot).Any())
        errors.Add($"{Path.GetRelativePath(repositoryRoot, manifestPath)}: plugin must contain at least one skill.");
    else
        foreach (var skillRoot in Directory.EnumerateDirectories(skillsRoot))
            if (!File.Exists(Path.Combine(skillRoot, "SKILL.md")))
                errors.Add($"{Path.GetRelativePath(repositoryRoot, skillRoot)}: missing SKILL.md.");
}

if (manifests.Length == 0)
    errors.Add("No canonical plugin manifests found.");

if (errors.Count > 0)
{
    foreach (var error in errors) Console.Error.WriteLine(error);
    return 1;
}

Console.WriteLine($"Validated {manifests.Length} canonical Agent Plugins manifests.");
return 0;

static void Validate(JsonElement instance, JsonElement schema, string path, List<string> errors)
{
    if (schema.TryGetProperty("type", out var type) && !HasType(instance, type.GetString()!))
    {
        errors.Add($"{path}: expected {type.GetString()}, found {instance.ValueKind}.");
        return;
    }

    if (schema.TryGetProperty("const", out var constant) && instance.GetRawText() != constant.GetRawText())
        errors.Add($"{path}: value does not match schema constant.");

    if (instance.ValueKind == JsonValueKind.String)
    {
        var value = instance.GetString()!;
        if (schema.TryGetProperty("minLength", out var min) && value.Length < min.GetInt32()) errors.Add($"{path}: value is too short.");
        if (schema.TryGetProperty("maxLength", out var max) && value.Length > max.GetInt32()) errors.Add($"{path}: value is too long.");
        if (schema.TryGetProperty("pattern", out var pattern) && !Regex.IsMatch(value, pattern.GetString()!)) errors.Add($"{path}: value does not match required pattern.");
    }

    if (instance.ValueKind == JsonValueKind.Array && schema.TryGetProperty("items", out var items))
    {
        var index = 0;
        foreach (var item in instance.EnumerateArray()) Validate(item, items, $"{path}[{index++}]", errors);
    }

    if (instance.ValueKind != JsonValueKind.Object) return;
    var properties = schema.TryGetProperty("properties", out var propertySchemas) ? propertySchemas : default;
    if (schema.TryGetProperty("required", out var required))
        foreach (var property in required.EnumerateArray())
            if (!instance.TryGetProperty(property.GetString()!, out _)) errors.Add($"{path}: missing required property '{property.GetString()}'.");

    foreach (var property in instance.EnumerateObject())
    {
        if (properties.ValueKind == JsonValueKind.Object && properties.TryGetProperty(property.Name, out var propertySchema))
            Validate(property.Value, propertySchema, $"{path}.{property.Name}", errors);
        else if (schema.TryGetProperty("additionalProperties", out var additional))
        {
            if (additional.ValueKind == JsonValueKind.False) errors.Add($"{path}: unsupported property '{property.Name}'.");
            else if (additional.ValueKind == JsonValueKind.Object) Validate(property.Value, additional, $"{path}.{property.Name}", errors);
        }
    }
}

static bool HasType(JsonElement value, string type) => type switch
{
    "object" => value.ValueKind == JsonValueKind.Object,
    "array" => value.ValueKind == JsonValueKind.Array,
    "string" => value.ValueKind == JsonValueKind.String,
    "boolean" => value.ValueKind is JsonValueKind.True or JsonValueKind.False,
    "number" => value.ValueKind == JsonValueKind.Number,
    "integer" => value.ValueKind == JsonValueKind.Number && value.TryGetInt64(out _),
    "null" => value.ValueKind == JsonValueKind.Null,
    _ => false
};

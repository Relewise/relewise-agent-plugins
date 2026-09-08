using System.Text;
using System.Text.Json;

try
{
    var root = FindRepositoryRoot();
    using var restCatalog = JsonDocument.Parse(File.ReadAllBytes(Path.Combine(root, "generated", "operations.json")));
    using var mcpCatalog = JsonDocument.Parse(File.ReadAllBytes(Path.Combine(root, "generated", "mcp-tools.json")));

    var operations = restCatalog.RootElement.GetProperty("operations").EnumerateArray()
        .Select(value => value.GetProperty("operationId").GetString()!)
        .Order(StringComparer.Ordinal)
        .ToArray();
    var mcpTools = mcpCatalog.RootElement.GetProperty("tools").EnumerateArray()
        .Select(value => new McpTool(
            value.GetProperty("name").GetString()!,
            value.GetProperty("area").GetString()!,
            value.GetProperty("relatedRestOperationIds").EnumerateArray()
                .Select(operation => operation.GetString()!)
                .Order(StringComparer.Ordinal)
                .ToArray()))
        .OrderBy(tool => tool.Name, StringComparer.Ordinal)
        .ToArray();

    var skillsByOperation = operations.ToDictionary(id => id, _ => new HashSet<string>(StringComparer.Ordinal), StringComparer.Ordinal);
    var explicitlyAssignedSkillsByMcpTool = mcpTools.ToDictionary(
        tool => tool.Name,
        _ => new HashSet<string>(StringComparer.Ordinal),
        StringComparer.Ordinal);

    foreach (var manifestPath in Directory.EnumerateFiles(Path.Combine(root, "plugins"), "operations.json", SearchOption.AllDirectories).Order(StringComparer.Ordinal))
    {
        var skill = Path.GetRelativePath(Path.Combine(root, "plugins"), Path.GetDirectoryName(manifestPath)!)
            .Replace('\\', '/');
        using var manifest = JsonDocument.Parse(File.ReadAllBytes(manifestPath));
        foreach (var value in manifest.RootElement.GetProperty("operationIds").EnumerateArray())
        {
            var operationId = value.GetString() ?? throw new InvalidDataException($"Operation IDs in '{manifestPath}' must be strings.");
            if (!skillsByOperation.TryGetValue(operationId, out var skills))
            {
                throw new InvalidDataException($"Skill '{skill}' references unknown operation '{operationId}'.");
            }
            skills.Add(skill);
        }

        if (manifest.RootElement.TryGetProperty("mcpToolNames", out var mcpToolNames))
        {
            foreach (var value in mcpToolNames.EnumerateArray())
            {
                var toolName = value.GetString() ?? throw new InvalidDataException($"MCP tool names in '{manifestPath}' must be strings.");
                if (!explicitlyAssignedSkillsByMcpTool.TryGetValue(toolName, out var skills))
                {
                    throw new InvalidDataException($"Skill '{skill}' references unknown MCP tool '{toolName}'.");
                }
                skills.Add(skill);
            }
        }
    }

    var skillsByMcpTool = new Dictionary<string, HashSet<string>>(StringComparer.Ordinal);
    foreach (var tool in mcpTools)
    {
        var skills = new HashSet<string>(explicitlyAssignedSkillsByMcpTool[tool.Name], StringComparer.Ordinal);
        foreach (var operationId in tool.RelatedRestOperationIds)
        {
            if (!skillsByOperation.TryGetValue(operationId, out var operationSkills))
            {
                throw new InvalidDataException($"MCP tool '{tool.Name}' references unknown REST operation '{operationId}'.");
            }
            skills.UnionWith(operationSkills);
        }
        skillsByMcpTool[tool.Name] = skills;
    }

    var jsonOptions = new JsonSerializerOptions { WriteIndented = true };
    var restCovered = skillsByOperation.Count(pair => pair.Value.Count > 0);
    var restOutput = new
    {
        operationCount = operations.Length,
        coveredOperationCount = restCovered,
        uncoveredOperationCount = operations.Length - restCovered,
        coveragePercent = Percentage(restCovered, operations.Length),
        operations = skillsByOperation.Select(pair => new
        {
            operationId = pair.Key,
            skills = pair.Value.Order(StringComparer.Ordinal).ToArray()
        })
    };
    File.WriteAllText(
        Path.Combine(root, "generated", "operation-coverage.json"),
        JsonSerializer.Serialize(restOutput, jsonOptions) + Environment.NewLine);

    var mcpCovered = skillsByMcpTool.Count(pair => pair.Value.Count > 0);
    var mcpOutput = new
    {
        toolCount = mcpTools.Length,
        coveredToolCount = mcpCovered,
        uncoveredToolCount = mcpTools.Length - mcpCovered,
        coveragePercent = Percentage(mcpCovered, mcpTools.Length),
        tools = mcpTools.Select(tool => new
        {
            name = tool.Name,
            area = tool.Area,
            relatedRestOperationIds = tool.RelatedRestOperationIds,
            skills = skillsByMcpTool[tool.Name].Order(StringComparer.Ordinal).ToArray()
        })
    };
    File.WriteAllText(
        Path.Combine(root, "generated", "mcp-tool-coverage.json"),
        JsonSerializer.Serialize(mcpOutput, jsonOptions) + Environment.NewLine);

    WriteRestMarkdown(root, skillsByOperation, restCovered, operations.Length);
    WriteMcpMarkdown(root, mcpTools, skillsByMcpTool, mcpCovered);

    Console.WriteLine($"Agent Gateway REST coverage: {restCovered} of {operations.Length} operations ({Percentage(restCovered, operations.Length):0.##}%).");
    Console.WriteLine($"Agent Gateway MCP coverage: {mcpCovered} of {mcpTools.Length} tools ({Percentage(mcpCovered, mcpTools.Length):0.##}%).");

    foreach (var operation in skillsByOperation.Where(pair => pair.Value.Count == 0).Select(pair => pair.Key))
        Console.Error.WriteLine($"Uncovered REST operation: {operation}");
    foreach (var tool in skillsByMcpTool.Where(pair => pair.Value.Count == 0).Select(pair => pair.Key))
        Console.Error.WriteLine($"Uncovered MCP tool: {tool}");

    return restCovered == operations.Length && mcpCovered == mcpTools.Length ? 0 : 1;
}
catch (Exception exception)
{
    Console.Error.WriteLine($"Coverage generation failed: {exception.Message}");
    return 1;
}

static decimal Percentage(int covered, int total) => total == 0 ? 100 : Math.Round(covered * 100m / total, 2);

static void WriteRestMarkdown(
    string root,
    IReadOnlyDictionary<string, HashSet<string>> skillsByOperation,
    int covered,
    int total)
{
    var markdown = new StringBuilder()
        .AppendLine("# Agent Gateway REST API coverage")
        .AppendLine()
        .AppendLine("This file is generated by `dotnet run --project tools/generate-coverage`. Do not edit it manually.")
        .AppendLine()
        .AppendLine($"**Coverage: {covered} of {total} operations ({Percentage(covered, total):0.##}%).**")
        .AppendLine()
        .AppendLine("| Operation | Capability skill(s) |")
        .AppendLine("| --- | --- |");
    foreach (var (operationId, skills) in skillsByOperation)
    {
        markdown.Append("| `").Append(operationId).Append("` | ")
            .Append(skills.Count == 0 ? "—" : string.Join(", ", skills.Order(StringComparer.Ordinal).Select(skill => $"`{skill}`")))
            .AppendLine(" |");
    }
    File.WriteAllText(Path.Combine(root, "docs", "api-coverage.md"), markdown.ToString());
}

static void WriteMcpMarkdown(
    string root,
    IReadOnlyList<McpTool> tools,
    IReadOnlyDictionary<string, HashSet<string>> skillsByTool,
    int covered)
{
    var markdown = new StringBuilder()
        .AppendLine("# Agent Gateway MCP tool coverage")
        .AppendLine()
        .AppendLine("This file is generated by `dotnet run --project tools/generate-coverage`. Do not edit it manually.")
        .AppendLine()
        .AppendLine("MCP tools inherit capability-skill coverage from their related REST operations. A skill can declare `mcpToolNames` in `operations.json` only when a tool has no REST relationship or needs an explicit additional assignment.")
        .AppendLine()
        .AppendLine($"**Coverage: {covered} of {tools.Count} tools ({Percentage(covered, tools.Count):0.##}%).**")
        .AppendLine()
        .AppendLine("| MCP tool | Area | Related REST operation(s) | Capability skill(s) |")
        .AppendLine("| --- | --- | --- | --- |");
    foreach (var tool in tools)
    {
        var skills = skillsByTool[tool.Name];
        markdown.Append("| `").Append(tool.Name).Append("` | ").Append(tool.Area).Append(" | ")
            .Append(tool.RelatedRestOperationIds.Length == 0
                ? "—"
                : string.Join(", ", tool.RelatedRestOperationIds.Select(operation => $"`{operation}`")))
            .Append(" | ")
            .Append(skills.Count == 0 ? "—" : string.Join(", ", skills.Order(StringComparer.Ordinal).Select(skill => $"`{skill}`")))
            .AppendLine(" |");
    }
    File.WriteAllText(Path.Combine(root, "docs", "mcp-tool-coverage.md"), markdown.ToString());
}

static string FindRepositoryRoot()
{
    foreach (var startingPath in new[] { Directory.GetCurrentDirectory(), AppContext.BaseDirectory })
    {
        for (var directory = new DirectoryInfo(startingPath); directory is not null; directory = directory.Parent)
        {
            if (File.Exists(Path.Combine(directory.FullName, "generated", "operations.json")))
                return directory.FullName;
        }
    }
    throw new DirectoryNotFoundException("Could not locate the repository root containing generated/operations.json.");
}

internal sealed record McpTool(string Name, string Area, string[] RelatedRestOperationIds);

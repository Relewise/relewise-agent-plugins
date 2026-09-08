using System.Text.Json;

try
{
    var repositoryRoot = FindRepositoryRoot();
    var catalogPath = Path.Combine(repositoryRoot, "generated", "operations.json");
    using var catalog = JsonDocument.Parse(File.ReadAllBytes(catalogPath));
    var availableOperationIds = catalog.RootElement
        .GetProperty("operations")
        .EnumerateArray()
        .Select(operation => operation.GetProperty("operationId").GetString()!)
        .ToHashSet(StringComparer.Ordinal);
    using var mcpCatalog = JsonDocument.Parse(File.ReadAllBytes(Path.Combine(repositoryRoot, "generated", "mcp-tools.json")));
    var availableMcpToolNames = mcpCatalog.RootElement
        .GetProperty("tools")
        .EnumerateArray()
        .Select(tool => tool.GetProperty("name").GetString()!)
        .ToHashSet(StringComparer.Ordinal);

    var skillFiles = Directory.EnumerateFiles(
        Path.Combine(repositoryRoot, "plugins"),
        "SKILL.md",
        SearchOption.AllDirectories).Order(StringComparer.Ordinal).ToArray();
    var skillNames = new HashSet<string>(StringComparer.Ordinal);
    foreach (var skillPath in skillFiles)
    {
        var content = File.ReadAllText(skillPath);
        var lines = content.Replace("\r\n", "\n").Split('\n');
        if (lines.Length < 4 || lines[0] != "---")
        {
            throw new InvalidDataException($"'{Relative(skillPath)}' must start with YAML frontmatter.");
        }

        var frontmatterEnd = Array.IndexOf(lines, "---", 1);
        if (frontmatterEnd < 1)
        {
            throw new InvalidDataException($"'{Relative(skillPath)}' has unterminated YAML frontmatter.");
        }

        var frontmatter = lines[1..frontmatterEnd];
        var name = Field(frontmatter, "name");
        var description = Field(frontmatter, "description");
        if (string.IsNullOrWhiteSpace(name) || string.IsNullOrWhiteSpace(description))
        {
            throw new InvalidDataException($"'{Relative(skillPath)}' must declare non-empty name and description fields.");
        }
        if (content.Contains("[TODO:", StringComparison.Ordinal))
        {
            throw new InvalidDataException($"'{Relative(skillPath)}' contains an unfinished placeholder.");
        }
        if (!skillNames.Add(name))
        {
            throw new InvalidDataException($"Skill name '{name}' is declared more than once.");
        }
    }

    var relewiseSkillsRoot = Path.Combine(repositoryRoot, "plugins", "relewise", "skills");
    var gatewaySkillRoot = Path.Combine(relewiseSkillsRoot, "relewise-agent-gateway");
    var gatewaySkillPath = Path.Combine(gatewaySkillRoot, "SKILL.md");
    if (!File.Exists(gatewaySkillPath))
    {
        throw new InvalidDataException("The Relewise plugin must contain the shared relewise-agent-gateway skill.");
    }

    foreach (var requiredResource in new[]
    {
        Path.Combine("references", "transport-selection.md"),
        Path.Combine("references", "cli.md"),
        Path.Combine("scripts", "relewise-agent"),
        Path.Combine("scripts", "relewise-agent.ps1")
    })
    {
        if (!File.Exists(Path.Combine(gatewaySkillRoot, requiredResource)))
        {
            throw new InvalidDataException($"The shared relewise-agent-gateway skill is missing '{requiredResource.Replace('\\', '/')}'.");
        }
    }

    foreach (var domainSkillPath in Directory.EnumerateFiles(relewiseSkillsRoot, "SKILL.md", SearchOption.AllDirectories)
                 .Where(path => !string.Equals(path, gatewaySkillPath, StringComparison.OrdinalIgnoreCase)))
    {
        var content = File.ReadAllText(domainSkillPath);
        if (!content.Contains("relewise-execution-skill: relewise-agent-gateway", StringComparison.Ordinal))
        {
            throw new InvalidDataException($"'{Relative(domainSkillPath)}' must delegate Agent Gateway execution to the shared skill.");
        }
        if (content.Contains("../../references/agent-gateway-transports.md", StringComparison.Ordinal) ||
            content.Contains("../../scripts/relewise-agent", StringComparison.Ordinal))
        {
            throw new InvalidDataException($"'{Relative(domainSkillPath)}' contains obsolete plugin-relative transport paths.");
        }
    }

    var manifests = Directory.EnumerateFiles(
        Path.Combine(repositoryRoot, "plugins"),
        "operations.json",
        SearchOption.AllDirectories).Order(StringComparer.Ordinal).ToArray();

    foreach (var manifestPath in manifests)
    {
        using var manifest = JsonDocument.Parse(File.ReadAllBytes(manifestPath));
        var operationIds = manifest.RootElement.GetProperty("operationIds").EnumerateArray()
            .Select(value => value.GetString() ?? throw new InvalidDataException("Operation IDs must be strings."))
            .ToArray();

        if (operationIds.Length == 0)
        {
            throw new InvalidDataException($"'{Relative(manifestPath)}' must reference at least one operation.");
        }

        var duplicate = operationIds.GroupBy(value => value, StringComparer.Ordinal)
            .FirstOrDefault(group => group.Count() > 1)?.Key;
        if (duplicate is not null)
        {
            throw new InvalidDataException($"'{Relative(manifestPath)}' references '{duplicate}' more than once.");
        }

        foreach (var operationId in operationIds)
        {
            if (!availableOperationIds.Contains(operationId))
            {
                throw new InvalidDataException($"'{Relative(manifestPath)}' references unknown operation '{operationId}'.");
            }
        }

        var mcpToolNames = manifest.RootElement.TryGetProperty("mcpToolNames", out var mcpToolNamesElement)
            ? mcpToolNamesElement.EnumerateArray()
                .Select(value => value.GetString() ?? throw new InvalidDataException("MCP tool names must be strings."))
                .ToArray()
            : [];
        var duplicateMcpToolName = mcpToolNames.GroupBy(value => value, StringComparer.Ordinal)
            .FirstOrDefault(group => group.Count() > 1)?.Key;
        if (duplicateMcpToolName is not null)
        {
            throw new InvalidDataException($"'{Relative(manifestPath)}' references MCP tool '{duplicateMcpToolName}' more than once.");
        }
        foreach (var mcpToolName in mcpToolNames)
        {
            if (!availableMcpToolNames.Contains(mcpToolName))
            {
                throw new InvalidDataException($"'{Relative(manifestPath)}' references unknown MCP tool '{mcpToolName}'.");
            }
        }
    }

    Console.WriteLine($"Validated {skillFiles.Length} skill definition(s) and {manifests.Length} REST/MCP capability manifest(s).");
    return 0;

    string Relative(string path) => Path.GetRelativePath(repositoryRoot, path).Replace('\\', '/');
    static string? Field(string[] lines, string name)
    {
        var prefix = name + ":";
        var line = lines.FirstOrDefault(value => value.StartsWith(prefix, StringComparison.Ordinal));
        return line?[prefix.Length..].Trim().Trim('"', '\'');
    }
}
catch (Exception exception)
{
    Console.Error.WriteLine($"Skill validation failed: {exception.Message}");
    return 1;
}

static string FindRepositoryRoot()
{
    foreach (var startingPath in new[] { Directory.GetCurrentDirectory(), AppContext.BaseDirectory })
    {
        var directory = new DirectoryInfo(startingPath);
        while (directory is not null)
        {
            if (File.Exists(Path.Combine(directory.FullName, "generated", "operations.json")))
            {
                return directory.FullName;
            }

            directory = directory.Parent;
        }
    }

    throw new DirectoryNotFoundException("Could not locate the repository root containing generated/operations.json.");
}

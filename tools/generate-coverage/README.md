# API coverage generator

This internal build-time tool maps every REST operation and MCP tool in the generated Agent Gateway catalogs to the canonical capability skills that reference them. It is used by contributors and CI and is not distributed as part of a plugin.

Run it from anywhere inside the repository:

```shell
dotnet run --project tools/generate-coverage
```

It reads `generated/operations.json`, `generated/mcp-tools.json`, and `plugins/**/operations.json`, then writes:

- `generated/operation-coverage.json` for machine-readable coverage data;
- `generated/mcp-tool-coverage.json` for machine-readable MCP coverage data;
- `docs/api-coverage.md` and `docs/mcp-tool-coverage.md` for the human-readable matrices.

REST coverage comes from each skill's operation manifest. MCP coverage is inferred through catalog relationships, with optional explicit `mcpToolNames` for MCP-only capabilities. The command reports both totals and fails when a catalog capability is not represented by at least one skill.

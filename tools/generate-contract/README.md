# Agent Gateway contract generator

The generator converts the complete Agent Gateway REST and MCP snapshots into smaller files that are easier for skills and tooling to discover and consume.

## Default input and output

The generator locates the repository root automatically, so it can be run from any directory inside the repository. By default it uses:

| Purpose | Default location |
| --- | --- |
| OpenAPI input | `contracts/agent-gateway-v1.json` |
| MCP catalog input | `contracts/agent-gateway-mcp-v1.json` |
| Operation catalog | `generated/operations.json` |
| MCP tool catalog | `generated/mcp-tools.json` |
| Component schemas | `generated/schemas/*.json` |
| Schema index | `generated/schemas/index.json` |

Run it with:

```shell
dotnet run --project tools/generate-contract
```

Optional arguments override the defaults:

```shell
dotnet run --project tools/generate-contract -- --contract path/to/openapi.json --mcp-contract path/to/mcp-catalog.json --output path/to/generated
```

Relative override paths are resolved from the current working directory.

## Generated artifacts

`generated/operations.json` is a deterministic lookup catalog containing every OpenAPI operation. Each entry includes:

- OpenAPI `operationId`
- HTTP method and path
- tags, summary, and description
- path and query parameters
- request-body schemas by content type
- response schemas by status code and content type

The catalog also records the OpenAPI version, Agent Gateway API version, operation count, source-contract path, and source-contract SHA-256 hash.

`generated/mcp-tools.json` is a deterministic catalog of every MCP tool. It retains each tool's schemas, annotations, Agent Gateway area, and related REST operation IDs. Generation fails if names or relationships are invalid or a related REST operation does not exist.

`generated/schemas/` contains one JSON file for each schema under `components.schemas` in the OpenAPI contract. These files preserve the schema definitions used by operation requests and responses.

`generated/schemas/index.json` maps each original OpenAPI schema name to its generated filename.

Before generating schemas, the tool removes existing JSON files from `generated/schemas/` so schemas removed from the OpenAPI contract do not remain as stale output. Given the same input contract, repeated runs produce byte-identical generated files.

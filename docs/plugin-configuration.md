# Plugin configuration

One `relewise` marketplace exposes `relewise` and `relewise-developer`.

## Sources and generated files

| Maintained source | Generated output |
| --- | --- |
| `plugins/<name>/plugin.json` | Shared fields in Claude and Codex manifests |
| `plugins/<name>/.mcp.json` | Agent Plugins `mcp.json`; Relewise's Gemini MCP block |
| `vendors/claude/<name>.json` | Claude display name override |
| `vendors/openai/<name>.json` | Codex interface metadata |
| `.claude-plugin/marketplace.json` | `.agents/plugins/marketplace.json`, with Codex policy and category metadata |
| `version.json` | Planned Gemini version and workflow-generated package versions |

Claude and Copilot share the Claude marketplace catalog. Codex needs its own catalog shape. Both plugin directories include generated manifests because repository installation reads committed files directly. Vendor directories contain only overrides and documentation, never copies of skills or full manifests.

The portable manifest is a source except for its workflow-managed version. `.mcp.json` is the sole maintained MCP definition for each plugin. Claude and Codex reference it directly. Agent Plugins 1.0 needs `mcp.json`, a schema declaration, and `streamable-http` instead of `http`; the generator performs that translation for both plugins. Gemini needs `httpUrl` in its extension manifest.

`write-plugin-configuration.ps1` writes a vendor's package metadata. `sync-plugin-configuration.ps1` assembles the committed adapters and Codex catalog. Run **Refresh marketplace payload** on the feature branch to synchronize versions and fingerprints. Do not edit generated files or fingerprints manually. The workflow reuses all five binaries unless runtime inputs changed, then dispatches checks on the generated commit.

## Authentication

Relewise uses `https://my.relewise.com/agents/mcp` with client-managed OAuth. A standards-compliant authentication challenge and discovery metadata let an OAuth-capable client discover the authorization server and start sign-in. No PAT, authorization header, or token environment variable is configured in MCP packaging.

Relewise Developer uses `https://mcp.relewise.com` without authentication.

The Relewise CLI and direct REST fallback still accept a PAT through `RELEWISE_AGENT_GATEWAY_TOKEN`. This is separate process configuration, not an MCP installation requirement. Package smoke-test tokens exercise CLI behavior and are not packaged credentials.

## Requirements and validation limits

- [Claude plugin reference](https://code.claude.com/docs/en/plugins-reference): `.mcp.json`, optional `displayName`, and plugin-relative configuration paths.
- [Copilot plugin reference](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-plugin-reference): Agent Plugins `mcp.json` and discovery of the Claude marketplace catalog.
- [Agent Plugins MCP schema](https://agent-plugins.org/schemas/1.0.0/mcp.schema.json): pinned under `contracts/` for offline schema validation.
- [Copilot OAuth](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-command-reference) and [Gemini OAuth](https://geminicli.com/docs/tools/mcp-server/): client-managed sign-in; Gemini uses `httpUrl` for streamable HTTP.

CI checks generated consistency, endpoint/authentication invariants, portable MCP schemas, package contents, native launchers, and Claude Code marketplace installation. These checks do not reproduce Claude's online GitHub importer or prove live OAuth interoperability for every host.

The partial online import at `9fe20ba` remains unexplained. Neither optional display names nor binary presence establish its cause. Keep the testing order: alignment/review/authorized merge; GitHub integration retry; separately authorized release and Relewise ZIP upload test; only then a reversible binary-free experiment if needed.

# Agent Gateway transport selection

Resolve the packaged CLI relative to the calling skill. When `../../scripts/relewise-agent` exists relative to the calling `SKILL.md`, resolve it to an absolute path and use that executable. Otherwise, use `relewise-agent` from `PATH`.

Use the first available transport that the selected Dataset's effective Agent Gateway policy permits:

1. **Bundled CLI over REST.** Prefer the resolved launcher when it is available and `restApiEnabled` is true. Inspect unfamiliar operations with `schema`; execute them with `call`.
2. **Agent Gateway MCP.** When the CLI cannot be resolved or REST is disabled, use tools from the registered `relewise-agent-gateway` MCP server when it is connected and `mcpEnabled` is true.
3. **Direct REST.** When the CLI cannot be resolved and MCP is unavailable, use the host's authenticated HTTP capability when `restApiEnabled` is true. Resolve HTTP mechanics from `https://my.relewise.com/agents/openapi/v1.json` and use the base URL `https://my.relewise.com/agents/api/v1`.

Use whichever available transport can call identity discovery first, then retrieve the selected Dataset's details before making Dataset-scoped calls. The policy reports `restApiEnabled`, `mcpEnabled`, and enabled `areas`. Switching transport must not bypass a disabled area or missing user permission.

The skill's `operations.json` lists its REST capabilities. The generated MCP catalog maps MCP tools to related REST operation IDs. A relationship identifies the same product capability; it does not make the tool and REST request or response schemas interchangeable. Use the schema exposed by the selected transport.

Every transport authenticates with the same Personal Access Token. Keep it in a secure credential provider or the `RELEWISE_AGENT_GATEWAY_TOKEN` environment variable. For direct REST, send it as `Authorization: Bearer <token>` without printing or interpolating the secret into visible command text. Never request or expose the token in chat, logs, source files, URLs, or output.

Fall back only when a transport is unavailable or disabled. An authentication, validation, permission, or policy error requires correcting the underlying issue; do not retry the same call through another transport to evade it. Preserve every read-only or mutation safeguard from the capability skill regardless of transport.

# Architecture

This repository provides vendor-neutral Relewise capabilities for AI agents. Canonical behavior belongs in Agent Skills and shared tooling; vendor adapters only package those capabilities for a specific platform.

## Decisions

- Agent Skills are the reusable instruction format.
- `Relewise` is the business-facing plugin.
- `Relewise Developer` is the developer-facing plugin.
- Business skills are transport-neutral and may use the bundled REST CLI, the unified Agent Gateway MCP server, or authenticated direct REST.
- Developer MCP belongs primarily to `Relewise Developer`.
- Personal Access Token (PAT) authentication is the supported authentication method.
- PATs must never be passed as command-line arguments.
- Multi-Dataset workflows must be supported; the architecture must not rely on one globally configured Dataset.
- Dataset IDs must be discovered and validated, never invented by an LLM.
- The versioned Agent Gateway OpenAPI specification and MCP tool catalog are the checked-in API contracts.
- A shared `relewise-agent-gateway` skill owns bootstrap discovery, transport selection, authentication handling, diagnostics, and the skill-local cross-platform `relewise-agent` helper.
- Focused domain skills retain operation selection, business rules, interpretation, and mutation safeguards; they delegate execution to `relewise-agent-gateway` rather than implementing transport mechanics.
- Shared transport rules choose only transports enabled by the selected Dataset policy after bootstrap discovery; an unavailable transport must not be treated as authorization to bypass that policy.
- MCP tools and REST operations are related capabilities, not interchangeable wire schemas.
- Domain skills describe intent, workflow, and interpretation—not HTTP mechanics.
- Canonical Relewise content lives under `plugins/`; vendor-specific packaging lives under `vendors/`.
- Repository-maintainer skills live under `.agents/skills/`. They assist contributors working in this repository but are not packaged or installed with a Relewise product.
- Each canonical product is a portable Agent Plugin: `plugins/<name>/plugin.json` and `plugins/<name>/skills/` follow the Agent Plugins 1.0.0 specification.
- Each directory below `skills/` follows the Agent Skills specification, including matching directory and frontmatter names, and is checked with the pinned reference validator.
- The checked-in Agent Plugins schema snapshot makes manifest validation deterministic and independent of the network.
- Vendor packages reuse the canonical manifest when their format supports it; client-specific manifests remain thin adapters where required.
- Plugin discovery, installation, and upgrades are client responsibilities outside the portable Agent Plugins specification.
- Vendor-specific code must remain as small as possible, with no manually duplicated skills.
- The repository is public, so maintainer skills may not contain secrets or confidential operating procedures even though they are outside the distributed plugins.

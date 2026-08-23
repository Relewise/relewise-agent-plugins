# Architecture

This repository provides vendor-neutral Relewise capabilities for AI agents. Canonical behavior belongs in Agent Skills and shared tooling; vendor adapters only package those capabilities for a specific platform.

## Decisions

- Agent Skills are the reusable instruction format.
- `Relewise` is the business-facing plugin.
- `Relewise Developer` is the developer-facing plugin.
- Business functionality is REST-first and does not require Agent Gateway MCP.
- Developer MCP belongs primarily to `Relewise Developer`.
- Personal Access Token (PAT) authentication is the supported authentication method.
- PATs must never be passed as command-line arguments.
- Multi-Dataset workflows must be supported; the architecture must not rely on one globally configured Dataset.
- Dataset IDs must be discovered and validated, never invented by an LLM.
- The versioned Agent Gateway OpenAPI specification is the API contract.
- A small cross-platform `relewise-agent` helper handles HTTP execution.
- Skills describe intent, workflow, and interpretation—not HTTP mechanics.
- Canonical Relewise content lives under `plugins/`; vendor-specific packaging lives under `vendors/`.
- Each canonical product is a portable Agent Plugin: `plugins/<name>/plugin.json` and `plugins/<name>/skills/` follow the Agent Plugins 1.0.0 specification.
- The checked-in Agent Plugins schema snapshot makes manifest validation deterministic and independent of the network.
- Vendor packages reuse the canonical manifest when their format supports it; client-specific manifests remain thin adapters where required.
- Plugin discovery, installation, and upgrades are client responsibilities outside the portable Agent Plugins specification.
- Vendor-specific code must remain as small as possible, with no manually duplicated skills.

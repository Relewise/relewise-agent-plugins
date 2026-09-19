# Relewise Agent Plugins

Use Relewise with AI assistants and coding agents through two open-source plugins.

## Choose a Plugin

| Plugin | Use It For | Connection |
| --- | --- | --- |
| **Relewise** | Working with your Relewise Datasets, configuration, analytics, merchandising, and optimization. | Connects securely through [Agent Gateway](https://docs.relewise.com/docs/myrelewise/agent-gateway/). |
| **Relewise Developer** | Building and troubleshooting Search, Recommendations, behavioral tracking, and data integrations in C#, TypeScript/JavaScript, PHP, or Java. | Connects to the public Relewise Developer MCP Server; no Relewise credential is required. |

Install either plugin or both. The products are intentionally separate so each agent receives only the tools and instructions relevant to its task.

## Get Started

The documentation guides you through the recommended installation and connection flow for your AI client:

- [Install the Relewise plugin](https://docs.relewise.com/docs/myrelewise/agent-gateway/agent-plugin.html)
- [Install the Relewise Developer plugin](https://docs.relewise.com/docs/developer/mcp.html)

After installing **Relewise**, ask your assistant:

> Help me connect Relewise.

The plugin checks whether authentication already works and guides you through any remaining setup. Once connected, try prompts such as:

- _What Relewise Datasets do I have access to?_
- _Review search performance for my Relewise Dataset._
- _Audit my merchandising rules for conflicts or gaps._

After installing **Relewise Developer**, ask your coding agent for help implementing or troubleshooting a Relewise integration in your preferred supported language.

## Install from This Marketplace

### ChatGPT and OpenAI Codex

In **Settings** > **Plugins**, add this repository as a plugin marketplace:

```text
https://github.com/Relewise/relewise-agent-plugins.git
```

Use `main` as the Git ref, leave **Sparse paths** empty, and install **Relewise**, **Relewise Developer**, or both.

### Claude Code

```text
claude plugin marketplace add Relewise/relewise-agent-plugins
claude plugin install relewise@relewise
claude plugin install relewise-developer@relewise
```

Run only the install command for each plugin you want.

### GitHub Copilot CLI

```text
copilot plugin marketplace add Relewise/relewise-agent-plugins
copilot plugin install relewise@relewise
copilot plugin install relewise-developer@relewise
```

Run only the install command for each plugin you want.

### Other Supported Clients

- **Gemini CLI:** Run `gemini extensions install https://github.com/Relewise/relewise-agent-plugins`. Gemini selects the matching Relewise extension for your platform.
- **Claude Desktop and Cowork:** Download the appropriate Claude plugin ZIP from [GitHub Releases](https://github.com/Relewise/relewise-agent-plugins/releases) and upload it as a custom plugin.
- Explore other clients that support the [Agent Plugins format](https://agent-plugins.org/compatible-clients).

Installation interfaces can change. Use the linked Relewise documentation above when it differs from this overview.

## Authentication and Security

The **Relewise** plugin uses OAuth when supported by the AI client. Other transports can use a Relewise Agent Gateway Personal Access Token through `RELEWISE_AGENT_GATEWAY_TOKEN`.

Never put a Personal Access Token in a prompt, command argument, repository file, log, or transcript. See the documentation for [Personal Access Tokens](https://docs.relewise.com/docs/myrelewise/agent-gateway/personal-access-tokens.html) and [Agent Gateway security and permissions](https://docs.relewise.com/docs/myrelewise/agent-gateway/security-and-permissions.html).

The **Relewise Developer** plugin connects to the public Developer MCP Server and does not require a Relewise credential.

## Repository Structure

The plugins use the portable [Agent Plugins](https://agent-plugins.org/) structure and [Agent Skills](https://agentskills.io/):

- `plugins/` contains the canonical plugin manifests, skills, and runtime configuration.
- `vendors/` contains platform-specific adapters.
- `marketplace/` contains marketplace-ready copy and publication material.
- `src/`, `tools/`, and `tests/` contain the Agent Gateway helper, build tooling, and validation.

See [plugin configuration](docs/plugin-configuration.md) and [architecture](docs/architecture.md) for implementation details.

## Contributing and Releasing

Read [CONTRIBUTING.md](CONTRIBUTING.md) before proposing changes. Maintainers should follow [RELEASING.md](RELEASING.md) for versioning, packaging, and publication.

Report vulnerabilities privately as described in [SECURITY.md](SECURITY.md). This repository is licensed under the [MIT License](LICENSE).

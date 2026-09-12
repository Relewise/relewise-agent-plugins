# Relewise

Work with your Relewise configuration, analytics and optimization using AI.

Use this product to inspect configuration, understand performance and consumption, and run guided optimization workflows across the Relewise Datasets you can access.

The plugin registers the unified Relewise Agent Gateway MCP server. OAuth-capable clients can authenticate through the server's interactive sign-in flow. Its focused domain skills retain their Relewise knowledge and delegate execution to the shared `relewise-agent-gateway` skill, which bundles the cross-platform `relewise-agent` REST helper, chooses a transport allowed by the selected Dataset policy, and can use authenticated direct REST when neither integration is available.

OAuth-capable MCP clients use Connected Apps and do not need a PAT. For the bundled CLI, direct REST, or MCP clients without OAuth, make `RELEWISE_AGENT_GATEWAY_TOKEN` available to the AI client through a secret provider or a system environment variable; never paste it into a conversation. Start with the `relewise-setup` skill to verify or repair the connection.

See the [Agent Gateway plugin documentation](https://docs.relewise.com/docs/myrelewise/agent-gateway/agent-plugin.html) for installation and Personal Access Token guidance.

Its canonical skills live in `skills/`. Vendor adapters package those skills with the required runtime for each supported AI agent.

For implementing or troubleshooting application integrations, use the separate `Relewise Developer` product.

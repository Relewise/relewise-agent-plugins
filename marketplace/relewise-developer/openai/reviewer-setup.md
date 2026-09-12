# OpenAI reviewer setup: Relewise Developer

## Prerequisites

- A clean sample project in C#, TypeScript/JavaScript, PHP, or Java.
- Agent mode enabled in the OpenAI client.
- The submitted plugin installed with its remote MCP server connected.
- No Agent Gateway PAT or customer credentials are required.

## Reviewer flow

1. Install or open the Relewise Developer plugin.
2. Confirm the MCP server is `https://mcp.relewise.com`.
3. Run the positive and negative cases in `test-cases.md`.
4. Verify that answers and code are grounded in current Relewise documentation and that secrets are not reproduced.

## Scope

The plugin provides developer documentation and implementation guidance. It does not access customer Datasets, Agent Gateway analytics, merchandising configuration, or production credentials.

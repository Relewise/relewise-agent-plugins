---
name: relewise-development
description: Build, review, and troubleshoot Relewise integrations using the Relewise Developer MCP. Use for implementation work involving Relewise Search, Recommendations, behavioral tracking, data integration, SDKs, or API usage in C#, TypeScript/JavaScript, PHP, or Java. Do not use for business analytics or My Relewise configuration tasks.
---

# Relewise Development

Use the Relewise Developer MCP as the source of truth for Relewise API and SDK behavior. Do not rely on remembered Relewise APIs or invent classes, methods, parameters, or request shapes.

## Start with MCP context

1. Confirm the Relewise Developer MCP tools are available.
2. Call `code_getting_started` before any other Relewise Developer MCP tool. Use its returned guidance to select and sequence later tools.
3. Inspect the repository's language, framework, installed Relewise packages, and existing implementation before requesting code guidance.
4. Ask the MCP for guidance that matches the detected language and the user's concrete task.

If the MCP is unavailable, explain that the remote server must be configured at `https://mcp.relewise.com` and point to [the setup guide](https://docs.relewise.com/docs/developer/mcp.html). Do not substitute speculative implementation code.

## Implement in the user's repository

Use MCP output as implementation guidance, then adapt it to the repository's established structure, conventions, dependency versions, and authorization boundaries. Keep changes scoped to the user's request and verify them with the repository's relevant build or tests.

Never expose or commit Dataset API keys, server URLs containing credentials, customer data, or other secrets. Reuse the project's existing secret/configuration mechanism. If credentials are missing, identify the required configuration without asking the user to paste secrets into chat.

Work on code under source control. Treat generated MCP guidance as input that still requires normal review, compilation, and testing.

## Route tasks correctly

This skill covers building and troubleshooting integrations that call Relewise from application code.

Use the business-facing `Relewise` skills instead for Dataset discovery, analytics, consumption, merchandising, Search Tools configuration, or comparisons performed through Agent Gateway. Developer MCP and Agent Gateway are separate execution surfaces; do not interchange their endpoints, credentials, or tools.

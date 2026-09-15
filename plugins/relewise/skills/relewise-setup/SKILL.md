---
name: relewise-setup
metadata:
  relewise-execution-skill: relewise-agent-gateway
description: Set up, verify, or repair Relewise Agent Gateway authentication. Use when a user wants to connect Relewise, sign in or reconnect with OAuth, diagnose MCP connectivity, configure a Personal Access Token, or check whether Relewise is already connected.
---

# Relewise Setup

Never ask the user to paste a Personal Access Token into the conversation. Do not print, repeat, inspect, or place a token in command text, command arguments, output, logs, or repository files.

Before any Agent Gateway call, activate and follow the installed `relewise-agent-gateway` skill from this plugin. Pass it the identity operation or MCP tool; do not resolve the CLI, choose a transport, or handle transport mechanics in this setup skill. This setup is idempotent: verify existing authentication before changing anything, and stop as soon as a reusable route works within the user's requested authentication method. An explicit OAuth-only requirement excludes PAT-backed CLI and REST fallbacks.

## Set up or repair authentication

1. Verify identity using the registered MCP tool `get_me` first. If the tool is missing or fails, have the Agent Gateway skill perform its [MCP connection preflight](../relewise-agent-gateway/references/transport-selection.md#mcp-connection-preflight). Missing tools alone do not establish that MCP or OAuth is unsupported.
2. If identity succeeds through a reusable route allowed by the user, explain that Relewise is already connected and make no changes. Include accessible Dataset display names only when useful.
3. For new connections or repairs, follow [authentication setup](references/authentication-setup.md), starting with the client's OAuth sign-in or reconnect flow when supported. Start the supported flow when available; do not merely tell the user OAuth is preferred. Let the user complete browser sign-in and consent.
4. If OAuth cannot start, report the observed connection or discovery failure and the next corrective action. A missing CLI token, missing MCP tools, or a failed OAuth discovery request is not evidence that OAuth is unsupported. Preserve an explicit OAuth-only requirement; leave setup pending on the actual blocker rather than recommending PAT.
5. Use PAT setup only when the user explicitly chooses it or the client/server is confirmed not to support OAuth. Existing authenticated fallbacks may be verified under the Agent Gateway skill's transport rules when the user has not restricted the authentication method. Let the user create, store, or replace any PAT outside the conversation. Use current official documentation for concrete client configuration steps.
6. After sign-in, refresh the client's MCP connection or tool discovery as supported, then verify `get_me`. If a client restart is needed, state that verification is pending until it restarts. Do not claim success from a login command alone. For PAT routes, verify identity after configuration; a changed environment variable may require restarting the client. If verification fails, explain the specific next corrective action without repeating unchanged steps.

The workflow is idempotent: every invocation starts by verifying the current configuration, and a working setup is never replaced merely because the skill was invoked again. A setup is complete only when future Relewise commands can use a reusable authenticated route without the user reconnecting or re-entering credentials each time.

Do not create, regenerate, revoke, or change the scope of a Personal Access Token on the user's behalf. Explain those actions and their consequences, then let the user perform them in My Relewise.

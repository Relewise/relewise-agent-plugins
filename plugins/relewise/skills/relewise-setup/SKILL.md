---
name: relewise-setup
description: Set up, verify, or repair Relewise Agent Gateway authentication. Use when a user wants to connect Relewise, configure a Personal Access Token, resolve a missing or rejected token, or check whether Relewise is already connected.
---

# Relewise Setup

Never ask the user to paste a Personal Access Token into the conversation. Do not print, repeat, inspect, or place a token in command text, command arguments, output, logs, or repository files.

Read [the shared transport-selection rules](../../references/agent-gateway-transports.md). This setup is idempotent: verify existing authentication before changing anything, and stop as soon as a reusable route works.

## Set up or repair authentication

1. Verify identity without changing configuration. Prefer `relewise-agent me` when the CLI resolves; otherwise call the registered MCP server's `get_me` tool, or use direct REST `IdentityGetCurrentUser` when authenticated HTTP is available.
2. If identity discovery succeeds, explain that Relewise is already connected and make no changes. Include accessible Dataset display names only when useful.
3. If authentication fails, distinguish a missing token from a rejected, expired, revoked, or regenerated token using the returned error. Do not inspect or print the environment variable itself.
4. Follow [authentication setup](references/authentication-setup.md). Prefer a reusable secure credential-provider route; otherwise guide the user to a persistent user or system environment variable named `RELEWISE_AGENT_GATEWAY_TOKEN`.
5. Let the user create, store, or replace the token outside the conversation and wait for confirmation when their action is required. If they ask for concrete configuration steps, use current official documentation for their environment rather than relying on fixed vendor UI navigation stored in this skill.
6. Verify identity again through an available transport. For MCP, the AI client may need to restart after its environment changes before the registered server can authenticate. Confirm success without exposing token metadata that is not needed. If authentication still fails, explain the specific next corrective action; do not repeatedly ask the user to redo unchanged steps.

The workflow is idempotent: every invocation starts by verifying the current configuration, and a working setup is never replaced merely because the skill was invoked again. A setup is complete only when future Relewise commands can receive the PAT without the user re-entering or re-exporting it each time.

Do not create, regenerate, revoke, or change the scope of a Personal Access Token on the user's behalf. Explain those actions and their consequences, then let the user perform them in My Relewise.

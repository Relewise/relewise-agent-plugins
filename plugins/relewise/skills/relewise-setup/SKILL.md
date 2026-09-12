---
name: relewise-setup
metadata:
  relewise-execution-skill: relewise-agent-gateway
description: Set up, verify, or repair Relewise Agent Gateway authentication. Use when a user wants to connect Relewise, configure a Personal Access Token, resolve a missing or rejected token, or check whether Relewise is already connected.
---

# Relewise Setup

Never ask the user to paste a Personal Access Token into the conversation. Do not print, repeat, inspect, or place a token in command text, command arguments, output, logs, or repository files.

Before any Agent Gateway call, activate and follow the installed `relewise-agent-gateway` skill from this plugin. Pass it the identity operation or MCP tool; do not resolve the CLI, choose a transport, or handle transport mechanics in this setup skill. This setup is idempotent: verify existing authentication before changing anything, and stop as soon as a reusable route works.

## Set up or repair authentication

1. Verify identity without changing configuration using the registered MCP tool `get_me` first. If MCP is unavailable, let the Agent Gateway skill apply its fallback order: bundled CLI, then direct REST operation `IdentityGetCurrentUser`. Use the Agent Gateway skill for all transport mechanics.
2. If identity discovery succeeds, explain that Relewise is already connected and make no changes. Include accessible Dataset display names only when useful.
3. If authentication fails, distinguish an unavailable or expired OAuth connection from a missing, rejected, expired, revoked, or regenerated PAT using the returned error. Do not inspect or print credentials or environment variables.
4. Follow [authentication setup](references/authentication-setup.md). Prefer reconnecting OAuth for MCP when supported. Only guide the user through PAT setup when no usable OAuth route exists.
5. Let the user create, store, or replace the token outside the conversation and wait for confirmation when their action is required. If they ask for concrete configuration steps, use current official documentation for their environment rather than relying on fixed vendor UI navigation stored in this skill.
6. Verify identity again through an available transport. After changing a PAT environment variable, the relevant client process may need to restart. For OAuth, use the client's normal reconnect/sign-in flow when reauthentication is required. Confirm success without exposing credential metadata that is not needed. If authentication still fails, explain the specific next corrective action; do not repeatedly ask the user to redo unchanged steps.

The workflow is idempotent: every invocation starts by verifying the current configuration, and a working setup is never replaced merely because the skill was invoked again. A setup is complete only when future Relewise commands can use a reusable authenticated route without the user reconnecting or re-entering credentials each time.

Do not create, regenerate, revoke, or change the scope of a Personal Access Token on the user's behalf. Explain those actions and their consequences, then let the user perform them in My Relewise.

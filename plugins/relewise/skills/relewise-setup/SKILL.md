---
name: relewise-setup
description: Set up, verify, or repair Relewise Agent Gateway authentication. Use when a user wants to connect Relewise, configure a Personal Access Token, resolve a missing or rejected token, or check whether Relewise is already connected.
---

# Relewise Setup

When `../../bin/relewise-agent` exists relative to this file, resolve it to an absolute path and use that executable. Otherwise, use `relewise-agent` from `PATH`.

Never ask the user to paste a Personal Access Token into the conversation. Do not print, repeat, inspect, or place a token in command text, command arguments, output, logs, or repository files.

## Set up or repair authentication

1. Run `relewise-agent me` without changing the current configuration.
2. If it succeeds, explain that Relewise is already connected and make no changes. Include the accessible Dataset display names only when useful.
3. If it returns `authentication_error`, distinguish a missing token from a rejected, expired, or regenerated token using the error code and message.
4. Treat the initial ordinary invocation as the check for an existing `RELEWISE_AGENT_GATEWAY_TOKEN`; do not inspect or print the variable. If the token is missing, use this order:
   1. If the AI client has access to a secure credential provider containing the user's Relewise Agent Gateway PAT, retrieve it and inject it only into the `relewise-agent` child process as `RELEWISE_AGENT_GATEWAY_TOKEN`. Use this route only when it can be repeated automatically for future Relewise invocations.
   2. If no reusable credential-provider route is available, explain the two supported setup choices from [authentication setup](references/authentication-setup.md): configure such a provider, or configure a persistent user or system environment variable named `RELEWISE_AGENT_GATEWAY_TOKEN`.
5. Let the user create, store, or replace the token outside the conversation and wait for confirmation when their action is required. If they ask for concrete configuration steps, use current official documentation for their environment rather than relying on fixed vendor UI navigation stored in this skill.
6. Run `relewise-agent me` again using the configured authentication route. Confirm success without exposing token metadata that is not needed. If authentication still fails, explain the specific next corrective action; do not repeatedly ask the user to redo unchanged steps.

The workflow is idempotent: every invocation starts by verifying the current configuration, and a working setup is never replaced merely because the skill was invoked again. A setup is complete only when future Relewise commands can receive the PAT without the user re-entering or re-exporting it each time.

Do not create, regenerate, revoke, or change the scope of a Personal Access Token on the user's behalf. Explain those actions and their consequences, then let the user perform them in My Relewise.

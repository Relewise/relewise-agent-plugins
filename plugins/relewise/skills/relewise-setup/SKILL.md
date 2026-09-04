---
name: relewise-setup
description: Set up, verify, or repair Relewise Agent Gateway authentication. Use when a user wants to connect Relewise, configure a Personal Access Token, resolve a missing or rejected token, or check whether Relewise is already connected.
---

# Relewise Setup

When `../../bin/relewise-agent` exists relative to this file, resolve it to an absolute path and use that executable. Otherwise, use `relewise-agent` from `PATH`.

Never ask the user to paste a Personal Access Token into the conversation. Do not print, repeat, inspect, or pass a token as a command argument. The user must enter it only through the client or operating-system configuration described in [authentication setup](references/authentication-setup.md).

## Set up or repair authentication

1. Run `relewise-agent me` without changing the current configuration.
2. If it succeeds, explain that Relewise is already connected and make no changes. Include the accessible Dataset display names only when useful.
3. If it returns `authentication_error`, distinguish a missing token from a rejected, expired, or regenerated token using the error code and message.
4. Determine the current client and operating system from available context. Ask one concise question only when either materially affects the instructions and cannot be determined.
5. Read [authentication setup](references/authentication-setup.md), then give only the relevant client and operating-system instructions. Let the user handle the token outside the conversation and wait for them to confirm completion.
6. Run `relewise-agent me` again. Confirm success without exposing token metadata that is not needed. If authentication still fails, explain the specific next corrective action; do not repeatedly ask the user to redo unchanged steps.

The workflow is idempotent: every invocation starts by verifying the current configuration, and a working setup is never replaced merely because the skill was invoked again.

Do not create, regenerate, revoke, or change the scope of a Personal Access Token on the user's behalf. Explain those actions and their consequences, then let the user perform them in My Relewise.

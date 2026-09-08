---
name: relewise-agent-gateway
description: Provides the shared execution layer for Relewise Agent Gateway. Use whenever another Relewise skill needs to discover Datasets or execute an operation through the bundled CLI, MCP, or direct REST, and when diagnosing transport or authentication failures.
---

# Relewise Agent Gateway

Use this skill as the technical execution capability behind the Relewise domain skill that matched the user's request. The domain skill owns operation selection, business rules, interpretation, and mutation safeguards. This skill owns connection bootstrap, transport selection, authentication handling, and invocation mechanics.

Do not replace or weaken instructions from the calling domain skill.

## Resolve the bundled CLI

Resolve paths from this skill's directory, which is the directory containing this `SKILL.md`.

1. On Windows, try `scripts/relewise-agent.ps1` with PowerShell.
2. On macOS or Linux, try `scripts/relewise-agent`.
3. If the platform launcher is absent, try `relewise-agent` and then `relewise-agent.exe` from `PATH` as appropriate for the host.
4. Validate the candidate once with `--version`, retain its absolute path for the current task, and do not repeat discovery before every call.

Do not recursively search the filesystem, home directory, temporary directories, plugin caches, or other skills. A missing, incompatible, or non-executable launcher means the CLI is locally unavailable; it does not mean Agent Gateway or the requested Dataset capability is unavailable.

## Execute an Agent Gateway operation

Read [transport selection](references/transport-selection.md) before the first Agent Gateway call in a task. It defines bootstrap discovery, task-, Dataset-, and operation-scoped state, post-bootstrap policy selection, authentication boundaries, fallbacks, and failure classification. Retain Dataset policies independently: one workflow may require different transports for different Datasets.

When the bundled CLI is selected, read [CLI usage](references/cli.md). Use the exact REST operation ID provided by the domain skill's `operations.json`, inspect unfamiliar schemas, and preserve the domain skill's safeguards.

When MCP is selected, use the related tool named by the domain skill's `operations.json`. A mapping to a REST operation identifies the same product capability but does not make their input or output schemas interchangeable; use the schema exposed by MCP.

When direct REST is selected, resolve current HTTP mechanics from `https://my.relewise.com/agents/openapi/v1.json` and use base URL `https://my.relewise.com/agents/api/v1`. Use the exact operation ID provided by the domain skill and the schema exposed by OpenAPI.

## Protect credentials

All transports use a Relewise Agent Gateway Personal Access Token. Prefer an already configured vendor-protected credential or secure credential provider. The portable fallback for the CLI and direct REST is `RELEWISE_AGENT_GATEWAY_TOKEN`.

Never request, print, inspect, log, or persist the token. Never place it in conversation text, command arguments, visible command text, input files, source files, URLs, or output. If user action is required to establish authentication, preserve the calling setup skill's instructions and wait for confirmation.

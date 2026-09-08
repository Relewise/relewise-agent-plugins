---
name: relewise-triggers
metadata:
  relewise-execution-skill: relewise-agent-gateway
description: Inspect Relewise Trigger configurations. Use when a user wants to list Triggers, inspect their criteria, or understand whether Trigger evaluation is enabled.
---

# Relewise Triggers

Before any Agent Gateway call, activate and follow the installed `relewise-agent-gateway` skill from this plugin. Pass it the selected REST operation ID and/or MCP tool plus validated parameters; do not resolve the CLI, choose a transport, or handle authentication in this domain skill. Discover and validate the intended Dataset before making a Triggers call. These operations are read-only and never evaluate a Trigger or send a webhook.

## Inspect configurations

1. List configurations with bounded pagination. Record the Dataset-wide `globallyEnabled` value before interpreting any individual configuration.
2. When the intended configuration is ambiguous, identify it by name, type, group, and ID rather than guessing.
3. Retrieve the selected configuration by ID to inspect its complete typed criteria and user conditions.
4. Inspect unfamiliar operations with `schema` before calling them.

A Trigger can run only when Dataset-wide evaluation and the individual configuration are both enabled. Distinguish the human-readable `within` value from `withinMinutes`; neither should be described as an inactivity delay unless the type-specific configuration says so.

## Interpret configuration

Use the `type` discriminator to interpret the matching type-specific configuration. Parse fields ending in `Json` only when their contents are needed, preserve Relewise `$type` metadata, and do not invent omitted conditions or delivery behavior. Delivery settings and credentials are intentionally unavailable through these operations.

State the Dataset, configuration name, type, ID, enabled state, evaluation window, and relevant criteria. Separate observed configuration from conclusions about whether or when the Trigger has executed.

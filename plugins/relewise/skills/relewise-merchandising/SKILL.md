---
name: relewise-merchandising
metadata:
  relewise-execution-skill: relewise-agent-gateway
description: Inspect and update existing Relewise merchandising rules. Use for listing rules, reviewing rule configuration, or explicitly requested enabled-state and activation-schedule changes.
---

# Relewise Merchandising

Before any Agent Gateway call, activate and follow the installed `relewise-agent-gateway` skill from this plugin. Pass it the selected REST operation ID and/or MCP tool plus validated parameters; do not resolve the CLI, choose a transport, or handle authentication in this domain skill. Discover and validate the intended Dataset before reading or changing rules. Do not infer a rule ID. Inspect the selected transport's schema before using an unfamiliar operation or related MCP tool.

## Inspect rules

Use `MerchandisingListRules` when the rule ID is unknown, then `MerchandisingGetRule` for the selected rule's full current configuration. Keep similarly named candidates visible when the intended rule is ambiguous.

## Update a rule

`MerchandisingUpdateRule` modifies live Dataset behavior. Use it only when the user explicitly requests a change; an audit, explanation, or recommendation request does not authorize mutation.

Before updating:

1. Retrieve the current rule with `MerchandisingGetRule`.
2. Inspect the selected transport's current update schema. With the CLI or direct REST, use `MerchandisingUpdateRule`; MCP exposes separate enabled-state and schedule tools related to that REST operation.
3. Resolve ambiguity about the Dataset, rule, enabled state, or schedule.
4. Send only the properties the user intends to change. Omitted or `null` top-level properties preserve that part of the rule; within a supplied schedule object, a `null` bound removes that bound.

After updating, report the exact Dataset, rule, and changed fields from the returned result. Do not claim unrelated configuration changed.

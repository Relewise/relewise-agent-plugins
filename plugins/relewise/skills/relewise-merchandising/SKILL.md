---
name: relewise-merchandising
description: Inspect and update existing Relewise merchandising rules through the relewise-agent CLI. Use for listing rules, reviewing rule configuration, or explicitly requested enabled-state and activation-schedule changes.
---

# Relewise Merchandising

When `../../scripts/relewise-agent` exists relative to this file, resolve it to an absolute path and use that executable. Otherwise, use `relewise-agent` from `PATH`.

Use `relewise-agent` for execution. Do not construct Agent Gateway URLs, send HTTP directly, or ask for a PAT in chat. Discover and validate the intended Dataset before reading or changing rules. Do not infer a rule ID. Inspect unfamiliar operations with `schema` and execute them with `call`.

## Inspect rules

Use `MerchandisingListRules` when the rule ID is unknown, then `MerchandisingGetRule` for the selected rule's full current configuration. Keep similarly named candidates visible when the intended rule is ambiguous.

## Update a rule

`MerchandisingUpdateRule` modifies live Dataset behavior. Use it only when the user explicitly requests a change; an audit, explanation, or recommendation request does not authorize mutation.

Before updating:

1. Retrieve the current rule with `MerchandisingGetRule`.
2. Inspect `MerchandisingUpdateRule` with `schema`.
3. Resolve ambiguity about the Dataset, rule, enabled state, or schedule.
4. Send only the properties the user intends to change. Omitted or `null` top-level properties preserve that part of the rule; within a supplied schedule object, a `null` bound removes that bound.

After updating, report the exact Dataset, rule, and changed fields from the returned result. Do not claim unrelated configuration changed.

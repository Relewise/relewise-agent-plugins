---
name: relewise-search-tools
description: Inspect and update Relewise Search Tools configuration through the relewise-agent CLI. Use for Search Indexes and decompounding, redirect, result-modifier, search-term-modifier, stemming, or synonym rules.
---

# Relewise Search Tools

Use `relewise-agent` for execution. Do not construct Agent Gateway URLs, send HTTP directly, or ask for a PAT in chat. Discover and validate the intended Dataset first. Dataset-specific Data Keys and values are case-sensitive; retrieve metadata when they are unknown rather than guessing. Inspect unfamiliar operations with `schema` and execute them with `call`.

Read [references/rule-workflows.md](references/rule-workflows.md) to select the correct rule family and operation sequence.

## Inspect configuration

When an ID is unknown, use the relevant list operation and then the matching get operation for complete configuration. Search Index operations and Synonym operations are currently read-only.

## Modify configuration

Patch operations change live search behavior. Use them only for an explicit user request; audits and recommendations authorize reads, not writes.

Before patching:

1. Resolve the exact Dataset, rule family, and rule ID.
2. Retrieve the rule's complete current configuration.
3. Inspect the patch operation with `schema`.
4. Send only intended changes. An omitted or `null` property preserves its current value unless the schema explicitly states otherwise.

Do not translate a request into a different rule family merely because it has a similar name. After mutation, identify the Dataset, rule, and fields changed, and surface any API warning or validation error without identical retries.

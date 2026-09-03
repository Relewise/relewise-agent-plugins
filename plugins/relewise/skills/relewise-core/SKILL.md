---
name: relewise-core
description: Discover, identify, inspect, and compare Relewise Datasets through the relewise-agent CLI. Use when a user asks which Datasets they can access, wants details or Agent Gateway capabilities for a Dataset, or needs Dataset context resolved before another Relewise task.
---

# Relewise Core

When `../../bin/relewise-agent` exists relative to this file, resolve it to an absolute path and use that executable. Otherwise, use `relewise-agent` from `PATH`.

Use `relewise-agent` as the execution boundary. Do not construct Agent Gateway URLs, send HTTP requests directly, or ask the user to provide a Personal Access Token in chat.

## Resolve Dataset context

1. Run `relewise-agent datasets` to discover the Datasets available to the configured PAT.
2. Match the user's wording against returned Dataset and License display names. Never invent or infer a Dataset ID that was not returned.
3. If multiple Datasets plausibly match and the intended one changes the answer, present the concise candidates and ask the user to choose.
4. Run `relewise-agent dataset <dataset-id>` for each selected Dataset before relying on its details or Agent Gateway policy.

Keep Dataset selection local to the current request. Do not establish one global Dataset. Resolve and validate each Dataset independently for comparisons.

## Work with Dataset capabilities

Use the effective policy returned by `dataset` to explain whether REST is enabled and which Agent Gateway Areas are available. Do not claim a capability that its policy disables.

When Dataset-specific vocabulary such as languages, currencies, Data Keys, or Classification Values is needed, inspect `CoreGetDatasetMetadata` with `schema`, then execute it with `call`. Treat Data Key names as case-sensitive.

For exact CLI syntax, input envelopes, and error recovery, read [references/relewise-agent.md](references/relewise-agent.md) before invoking an unfamiliar command.

## Respond

Use Dataset display names in the answer and include IDs only when they help disambiguate or the user requests them. For comparisons, preserve the association between each result and its Dataset. Explain access or policy limitations plainly; do not silently substitute another Dataset.

---
name: relewise-compare-datasets
description: Compare two or more Relewise Datasets using consistent metadata, analytics, or consumption measures. Use when a user asks to compare stores, markets, environments, or other Dataset-backed properties.
---

# Compare Relewise Datasets

Use `relewise-agent` for execution. Never invent Dataset IDs, construct Agent Gateway URLs, send HTTP directly, or ask for a PAT in chat. This workflow is read-only.

## Establish a fair comparison

1. Discover accessible Datasets and resolve every requested name independently. If a name is ambiguous, ask the user to choose from concise candidates.
2. Validate each selected Dataset and its effective Agent Gateway policy. Explain and omit a Dataset when the required area is unavailable; do not silently replace it.
3. Identify the smallest common set of measures that answers the question. Use Dataset metadata for configuration context, analytics for performance, and consumption summaries for usage.
4. Keep inputs equivalent across Datasets: the same inclusive period, currency, filters, pagination, and measurement definition. Surface unavoidable differences before interpreting results.
5. Inspect each unfamiliar operation with `schema`, then execute it once per Dataset with `call`.

Do not compare formatted strings. Calculate from numeric values and preserve units. Do not infer that a configuration difference caused a performance difference without supporting evidence.

## Present the result

Lead with the material similarities and differences, followed by a compact Dataset-by-Dataset comparison. State the period, filters, units, and missing or incomparable data. Use display names by default and IDs only for disambiguation. Separate observed facts from interpretations and suggested follow-up analysis.

---
name: relewise-analytics
description: Analyze Relewise revenue and product-search performance. Use for KPI summaries, popular or trending searches, low-click searches, searches without results, and comparisons across periods or Datasets.
---

# Relewise Analytics

Before calling Agent Gateway, read and follow [the shared transport-selection rules](../../references/agent-gateway-transports.md). Discover and validate each requested Dataset before analysis; never invent a Dataset ID or silently substitute another Dataset.

## Plan the analysis

Clarify or choose a defensible inclusive date range and state it in the answer. Preserve the same period, currency, and filters when comparing Datasets unless the user asks otherwise.

Select the narrowest operation that answers the question. Read [references/operation-selection.md](references/operation-selection.md) when choosing among search-analytics operations.

Before a call:

1. Inspect the selected transport's exact operation or tool schema. With the CLI, use `relewise-agent schema <operation-id>`.
2. Use `CoreGetDatasetMetadata` when language, currency, Data Keys, or Classification Values are unknown.
3. For Search Analytics, use `AnalyticsGetSearchFilterOptions` to discover conditional filter values rather than guessing them.
4. Put validated parameters and body values in the selected transport's documented input shape, then call the operation or related MCP tool for each Dataset. With the CLI, use `relewise-agent call <operation-id> --dataset <dataset-id> [--input <path>]`.

All analytics operations are read-only. Avoid identical retries after `validation_error` or `api_error`; correct the request from the schema or error message first.

## Interpret results

Use numeric values for calculations and formatted values for presentation. Distinguish volume, trend, no-result, and low-click signals; they describe different opportunities. State filters and periods, keep Dataset attribution explicit, and do not imply causation from aggregate metrics alone.

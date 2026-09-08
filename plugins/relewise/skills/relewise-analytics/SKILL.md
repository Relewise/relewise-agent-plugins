---
name: relewise-analytics
metadata:
  relewise-execution-skill: relewise-agent-gateway
description: Analyze Relewise revenue and product-search performance. Use for KPI summaries, popular or trending searches, low-click searches, searches without results, and comparisons across periods or Datasets.
---

# Relewise Analytics

Before any Agent Gateway call, activate and follow the installed `relewise-agent-gateway` skill from this plugin. Pass it the selected REST operation ID and/or MCP tool plus validated parameters; do not resolve the CLI, choose a transport, or handle authentication in this domain skill. Discover and validate each requested Dataset before analysis; never invent a Dataset ID or silently substitute another Dataset.

## Plan the analysis

Clarify or choose a defensible inclusive date range and state it in the answer. Preserve the same period, currency, and filters when comparing Datasets unless the user asks otherwise.

Select the narrowest operation that answers the question. Read [references/operation-selection.md](references/operation-selection.md) when choosing among search-analytics operations.

Before a call:

1. Inspect the selected transport's exact operation or tool schema through the Agent Gateway skill.
2. Use `CoreGetDatasetMetadata` when language, currency, Data Keys, or Classification Values are unknown.
3. For Search Analytics, use `AnalyticsGetSearchFilterOptions` to discover conditional filter values rather than guessing them.
4. Put validated parameters and body values in the selected transport's documented input shape, then pass the operation or related MCP tool to the Agent Gateway skill for each Dataset.

All analytics operations are read-only. Avoid identical retries after `validation_error` or `api_error`; correct the request from the schema or error message first.

## Interpret results

Use numeric values for calculations and formatted values for presentation. Distinguish volume, trend, no-result, and low-click signals; they describe different opportunities. State filters and periods, keep Dataset attribution explicit, and do not imply causation from aggregate metrics alone.

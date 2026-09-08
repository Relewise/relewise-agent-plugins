---
name: relewise-consumption
description: Review and compare Relewise API consumption. Use for Analyzer, Behavioral Tracking, Content Delivery, Integrations, Marketing Automation, Recommendations, Retail Media, Search, or Shoppertainment consumption summaries and trends.
---

# Relewise Consumption

Before calling Agent Gateway, read and follow [the shared transport-selection rules](../../references/agent-gateway-transports.md). Discover and validate every requested Dataset before retrieving consumption; never invent a Dataset ID.

Choose the operation matching the product area named by the user. Read [references/operation-selection.md](references/operation-selection.md) for the exact mapping. If the area is unclear, present the relevant available areas rather than combining unrelated measurements automatically.

Inspect the selected transport's operation or tool schema, provide the required inclusive date range, then execute it. With the CLI, use `relewise-agent schema <operation-id>` followed by `relewise-agent call <operation-id> --dataset <dataset-id> --input <path>`. Use the same capability and period for each Dataset in a comparison.

Consumption operations are read-only and return aggregate measurements, comparison-period changes, and daily trends. Keep these distinct:

- measurements describe usage in the selected period;
- comparison changes describe movement relative to the API-defined comparison period;
- daily trends show when usage occurred.

State the Dataset, product area, and inclusive period with the result. Do not treat different product-area units as interchangeable or sum them unless the response contract establishes compatible units.

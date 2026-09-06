---
name: relewise-consumption
description: Review and compare Relewise API consumption through the relewise-agent CLI. Use for Analyzer, Behavioral Tracking, Content Delivery, Integrations, Marketing Automation, Recommendations, Retail Media, Search, or Shoppertainment consumption summaries and trends.
---

# Relewise Consumption

When `../../scripts/relewise-agent` exists relative to this file, resolve it to an absolute path and use that executable. Otherwise, use `relewise-agent` from `PATH`.

Use `relewise-agent` for execution. Do not construct Agent Gateway URLs, send HTTP directly, or ask for a PAT in chat. Discover and validate every requested Dataset before retrieving consumption; never invent a Dataset ID.

Choose the operation matching the product area named by the user. Read [references/operation-selection.md](references/operation-selection.md) for the exact mapping. If the area is unclear, present the relevant available areas rather than combining unrelated measurements automatically.

Inspect the operation with `relewise-agent schema <operation-id>`, provide the required inclusive date range, then execute `relewise-agent call <operation-id> --dataset <dataset-id> --input <path>`. Use the same operation and period for each Dataset in a comparison.

Consumption operations are read-only and return aggregate measurements, comparison-period changes, and daily trends. Keep these distinct:

- measurements describe usage in the selected period;
- comparison changes describe movement relative to the API-defined comparison period;
- daily trends show when usage occurred.

State the Dataset, product area, and inclusive period with the result. Do not treat different product-area units as interchangeable or sum them unless the response contract establishes compatible units.

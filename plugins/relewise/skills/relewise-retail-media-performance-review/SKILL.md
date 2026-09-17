---
name: relewise-retail-media-performance-review
metadata:
  relewise-execution-skill: relewise-agent-gateway
description: Review and compare Relewise Retail Media campaign performance. Use for campaign or advertiser reporting, period comparisons, Sponsored Product and Display Ad analysis, and evidence-based performance summaries.
---

# Relewise Retail Media Performance Review

Before any Agent Gateway call, activate and follow the installed `relewise-agent-gateway` skill from this plugin. Pass it the selected REST operation ID and/or related MCP tool plus validated parameters; do not resolve the CLI, choose a transport, or handle authentication in this domain skill. This workflow is read-only; a performance review or recommendation never authorizes a campaign or advertiser update.

## Verify Dataset and Retail Media access

Discover the requested Dataset with `IdentityGetCurrentUser`, then retrieve it with `CoreGetDataset`. Never invent a Dataset ID. Confirm that the effective Agent Gateway policy enables the selected transport and the `RetailMedia` Area.

If Retail Media or its Agent Gateway Area is unavailable, follow the operational Retail Media skill's access guidance in [Relewise Retail Media](../relewise-retail-media/SKILL.md#verify-dataset-access). Let the user or an administrator make changes in My Relewise, then retrieve the Dataset details again before continuing.

## Define the review

Resolve the intended campaign, advertiser scope, and UTC interval. Use `RetailMediaListAdvertisers` when an advertiser ID is unknown and `RetailMediaListCampaigns` to discover campaigns; never infer identifiers. Retrieve each selected campaign with `RetailMediaGetCampaign` so its advertiser, state, schedule, budget, and monetary context remain attached to the results.

For paginated discovery, keep filters stable and request subsequent one-based pages while `pageNumber` is below `pagination.totalPages`. When multiple campaigns plausibly match and the choice changes the answer, present the concise candidates and ask the user to choose.

Use `RetailMediaGetCampaignPerformance` for each campaign and interval. An interval may be at most 366 days, and a future end time is capped at now. State the exact interval in the answer. For period comparisons, use explicit non-overlapping intervals of comparable length unless the user requests another basis; do not imply that the operation supplies a My Relewise comparison window.

## Interpret the metrics

Preserve the source time buckets and entity breakdowns. Separate Sponsored Product and Display Ad results rather than blending unlike measures.

- Sponsored Product views, sales quantity, and revenue include all sales channels. Do not describe them as ad-attributed conversions or incremental impact.
- Keep revenue separated by currency. Never add, rank, or compare monetary totals across currencies without an explicit user-provided conversion method.
- Display Ads supply promotion and click metrics. Preserve the source terminology; do not rename promotions as impressions, views, or another metric.
- The capability does not supply spend or ROAS. Do not derive either from CPM, views, or other fields, and do not characterize budget pacing without actual spend.
- Do not infer causation from aggregate changes. Distinguish an observed change from a diagnosis or recommendation.

When comparing campaigns, keep Dataset, interval, currency, promotion type, and entity attribution visible. Calculate percentage changes only when the denominator is meaningful; label a zero or missing baseline instead of manufacturing a percentage.

## Report for a business user

Lead with the decision-relevant outcome, then provide the evidence and limitations. A useful review should include:

1. Scope: Dataset, advertiser or campaigns, and exact UTC period.
2. Results: the most relevant source metrics, separated by promotion type and currency.
3. Comparison: changes across campaigns, entities, or periods on a like-for-like basis.
4. Interpretation: observations supported by the returned data, with attribution limitations stated where relevant.
5. Follow-up: configuration questions or investigations that the data makes worthwhile.

If the user subsequently requests an operational change, activate `relewise-retail-media`, retrieve the current entity again, and follow that skill's mutation safeguards. Do not carry review-time configuration forward as authority to write.

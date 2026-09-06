---
name: relewise-search-performance-review
description: Review Relewise product-search performance and prioritize optimization opportunities. Use when a user asks why search is underperforming, what should be optimized, or for a recurring search health review.
---

# Review Relewise Search Performance

When `../../scripts/relewise-agent` exists relative to this file, resolve it to an absolute path and use that executable. Otherwise, use `relewise-agent` from `PATH`.

Use `relewise-agent` for execution. Never invent Dataset IDs or filter values, construct Agent Gateway URLs, send HTTP directly, or ask for a PAT in chat. This workflow is read-only and does not authorize configuration changes.

## Build the review

1. Resolve and validate the requested Dataset. Choose or clarify an inclusive comparison period and state it.
2. Retrieve Dataset metadata when language or other Dataset vocabulary is unknown.
3. Use `AnalyticsGetSearchFilterOptions` to discover valid language, currency, channel, subchannel, and classification filters. Preserve the same filters across all calls.
4. Use `AnalyticsGetSearchOverview` for baseline volume, click, conversion, and no-result signals.
5. Select only the diagnostic lists relevant to the observed signal:
   - no results for unmet demand;
   - low click rate for weak result relevance;
   - popular terms for high-impact prioritization;
   - trending up or down for changing demand.
6. Inspect each operation with `schema` before forming its input. Use bounded pages and avoid repeated calls that cannot change the conclusion.

## Prioritize findings

Rank opportunities by evidence and likely impact, considering search volume together with no-result, click, conversion, or trend signals. Do not describe aggregate correlation as causation. Distinguish observations from hypotheses that require configuration inspection or further analysis.

Report the review period and filters, a concise health summary, prioritized findings with supporting measurements, and actionable next investigations. Recommend configuration changes when warranted, but do not apply them without a separate explicit request.

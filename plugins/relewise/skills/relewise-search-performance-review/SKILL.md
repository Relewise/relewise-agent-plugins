---
name: relewise-search-performance-review
metadata:
  relewise-execution-skill: relewise-agent-gateway
description: Review Relewise product-search performance and prioritize optimization opportunities. Use when a user asks why search is underperforming, what should be optimized, or for a recurring search health review.
---

# Review Relewise Search Performance

Before any Agent Gateway call, activate and follow the installed `relewise-agent-gateway` skill from this plugin. Pass it the selected REST operation ID and/or MCP tool plus validated parameters; do not resolve the CLI, choose a transport, or handle authentication in this domain skill. Never invent Dataset IDs or filter values. This workflow is read-only and does not authorize configuration changes.

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
6. Inspect the selected transport's current schema before forming each input. Use bounded pages and avoid repeated calls that cannot change the conclusion.

## Prioritize findings

Rank opportunities by evidence and likely impact, considering search volume together with no-result, click, conversion, or trend signals. Do not describe aggregate correlation as causation. Distinguish observations from hypotheses that require configuration inspection or further analysis.

Report the review period and filters, a concise health summary, prioritized findings with supporting measurements, and actionable next investigations. Recommend configuration changes when warranted, but do not apply them without a separate explicit request.

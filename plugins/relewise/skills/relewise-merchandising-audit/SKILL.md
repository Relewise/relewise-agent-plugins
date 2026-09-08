---
name: relewise-merchandising-audit
metadata:
  relewise-execution-skill: relewise-agent-gateway
description: Audit Relewise merchandising and Search Tools configuration without changing it. Use for configuration health checks, overlapping-rule reviews, stale-rule identification, or investigating configuration behind search behavior.
---

# Audit Relewise Merchandising

Before any Agent Gateway call, activate and follow the installed `relewise-agent-gateway` skill from this plugin. Pass it the selected REST operation ID and/or MCP tool plus validated parameters; do not resolve the CLI, choose a transport, or handle authentication in this domain skill. Never invent Dataset or rule IDs. An audit authorizes reads only; do not update or patch rules.

## Scope the audit

Resolve and validate the Dataset and its available Agent Gateway areas. Clarify whether the user wants merchandising rules, Search Tools, or both. Retrieve Dataset metadata when Data Keys, languages, or values are needed; treat Data Key names as case-sensitive.

For each in-scope rule family:

1. Use its list operation with bounded pagination.
2. Retrieve full details for rules that are active, suspicious, overlapping, or needed to answer the request.
3. Inspect the selected transport's schema before calling an unfamiliar operation or related MCP tool.
4. Evaluate enabled and approval state, activation windows, scope and conditions, competing actions, and references to Dataset-specific keys or values.

Search Indexes are read-only through the current API. State such limitations instead of filling gaps by inference.

## Report findings

Organize findings by severity and rule family. Identify the Dataset, exact rule names and IDs, observed evidence, likely effect, and recommended follow-up. Separate confirmed conflicts from possible overlaps that need business context. Do not claim a rule caused a performance outcome unless analytics support that conclusion.

Recommendations are not authorization to mutate configuration. If the user later requests changes, re-read the current rule first and follow the relevant capability skill's mutation safeguards.

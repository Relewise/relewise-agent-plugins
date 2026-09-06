---
name: relewise-merchandising-audit
description: Audit Relewise merchandising and Search Tools configuration without changing it. Use for configuration health checks, overlapping-rule reviews, stale-rule identification, or investigating configuration behind search behavior.
---

# Audit Relewise Merchandising

When `../../scripts/relewise-agent` exists relative to this file, resolve it to an absolute path and use that executable. Otherwise, use `relewise-agent` from `PATH`.

Use `relewise-agent` for execution. Never invent Dataset or rule IDs, construct Agent Gateway URLs, send HTTP directly, or ask for a PAT in chat. An audit authorizes reads only; do not update or patch rules.

## Scope the audit

Resolve and validate the Dataset and its available Agent Gateway areas. Clarify whether the user wants merchandising rules, Search Tools, or both. Retrieve Dataset metadata when Data Keys, languages, or values are needed; treat Data Key names as case-sensitive.

For each in-scope rule family:

1. Use its list operation with bounded pagination.
2. Retrieve full details for rules that are active, suspicious, overlapping, or needed to answer the request.
3. Inspect unfamiliar operations with `schema` before calling them.
4. Evaluate enabled and approval state, activation windows, scope and conditions, competing actions, and references to Dataset-specific keys or values.

Synonyms and Search Indexes are read-only through the current API and may have less detail available. State such limitations instead of filling gaps by inference.

## Report findings

Organize findings by severity and rule family. Identify the Dataset, exact rule names and IDs, observed evidence, likely effect, and recommended follow-up. Separate confirmed conflicts from possible overlaps that need business context. Do not claim a rule caused a performance outcome unless analytics support that conclusion.

Recommendations are not authorization to mutate configuration. If the user later requests changes, re-read the current rule first and follow the relevant capability skill's mutation safeguards.

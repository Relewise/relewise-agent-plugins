---
name: relewise-administration
metadata:
  relewise-execution-skill: relewise-agent-gateway
description: Inspect Relewise Dataset Jobs and execution history. Use when a user wants to understand configured jobs, recent runs, failures, execution messages, or job settings. These operations are read-only; they do not run or change Jobs.
---

# Relewise Administration

Before any Agent Gateway call, activate and follow the installed `relewise-agent-gateway` skill from this plugin. Pass it the selected REST operation ID and/or MCP tool plus validated parameters; do not resolve the CLI, choose a transport, or handle authentication in this domain skill. Confirm the intended Dataset before making an Administration call and ensure its Agent Gateway Administration area is enabled.

## Inspect Jobs

1. Call `list_jobs` to discover the Dataset's Jobs and their stable Job IDs. Do not guess a Job ID.
2. Use `get_job` with a Job ID returned by `list_jobs` to inspect its schedule, type, state, and safe custom configuration.
3. Treat the returned execution summary as the latest available summary; it does not provide the full execution history.
4. Explain that these operations cannot create, start, stop, or modify Jobs.

## Inspect execution history

1. Use `list_job_logs` with an inclusive UTC date range. Filter by Job ID when the user asks about one Job; omit it to inspect all Jobs.
2. Use the returned cursors for pagination. Do not combine `beforeLogId` and `afterLogId`.
3. Use `get_job_log` with a Job ID and Log ID returned by `list_job_logs` to inspect the complete execution messages.
4. Distinguish `completed`, `completedWithWarnings`, and `faulted`. Do not infer a run outcome from a missing or nullable message.

State the Dataset, Job name/type/ID, execution dates, result, and relevant messages. Separate observed Job configuration and execution records from conclusions about data freshness or integration health.

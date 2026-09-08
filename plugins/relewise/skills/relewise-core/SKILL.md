---
name: relewise-core
metadata:
  relewise-execution-skill: relewise-agent-gateway
description: Discover, identify, inspect, and compare Relewise Datasets. Use when a user asks which Datasets they can access, wants details or Agent Gateway capabilities for a Dataset, or needs Dataset context resolved before another Relewise task.
---

# Relewise Core

Before any Agent Gateway call, activate and follow the installed `relewise-agent-gateway` skill from this plugin. Pass it the selected REST operation ID and/or MCP tool plus validated parameters; do not resolve the CLI, choose a transport, or handle authentication in this domain skill.

## Resolve Dataset context

1. Discover the Datasets available to the configured PAT using REST operation `IdentityGetCurrentUser` or related MCP tool `get_me` through the Agent Gateway skill.
2. Match the user's wording against returned Dataset and License display names. Never invent or infer a Dataset ID that was not returned.
3. If multiple Datasets plausibly match and the intended one changes the answer, present the concise candidates and ask the user to choose.
4. Retrieve details for each selected Dataset before relying on its metadata or effective Agent Gateway policy. Use REST operation `CoreGetDataset` or related MCP tool `get_dataset_details` through the Agent Gateway skill.

Keep Dataset selection local to the current request. Do not establish one global Dataset. Resolve and validate each Dataset independently for comparisons.

## Work with Dataset capabilities

Use the effective policy to explain whether REST and MCP are enabled and which Agent Gateway Areas are available. Do not claim a capability that its policy disables.

When Dataset-specific vocabulary such as languages, currencies, Data Keys, or Classification Values is needed, use the Dataset-metadata capability. Inspect the selected transport's current schema first; over REST its operation ID is `CoreGetDatasetMetadata`. Treat Data Key names as case-sensitive.

## Respond

Use Dataset display names in the answer and include IDs only when they help disambiguate or the user requests them. For comparisons, preserve the association between each result and its Dataset. Explain access or policy limitations plainly; do not silently substitute another Dataset.

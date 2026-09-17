# My Relewise setup links

My Relewise is Relewise's web portal at `https://my.relewise.com`. It is separate from the AI client, plugin settings, or MCP connection UI. When setup requires the user to inspect or change portal state, identify My Relewise by name and provide a clickable absolute URL.

Use only these links:

- Personal Access Tokens: `https://my.relewise.com/user#personal-access-tokens`
- Connected Apps: `https://my.relewise.com/user#connected-apps`
- Dataset Agent Gateway settings: `https://my.relewise.com/{datasetId}/administration/agent-gateway`

Substitute `{datasetId}` only with a Dataset ID returned by `get_me` or another verified Agent Gateway response. Preserve it exactly and never invent it. If the Dataset ID is unavailable, use the applicable account-scoped link instead of constructing a Dataset link.

Do not infer or construct other My Relewise URLs from these examples. Never place a PAT value, OAuth access token, or OAuth client ID in a URL.

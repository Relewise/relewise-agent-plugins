# My Relewise links

My Relewise is Relewise's web portal at `https://my.relewise.com`. It is separate from the AI client, plugin settings, or MCP connection UI. When setup requires the user to inspect or change portal state, identify My Relewise by name and provide a clickable absolute URL.

## Setup pages

- User profile: `https://my.relewise.com/user#profile-information`
- Personal Access Tokens: `https://my.relewise.com/user#personal-access-tokens`
- Connected Apps: `https://my.relewise.com/user#connected-apps`
- Dataset Agent Gateway settings: `https://my.relewise.com/{datasetId}/administration/agent-gateway`

Use a Dataset-specific link only when the Dataset ID is known from verified context or tool output. Preserve the Dataset ID exactly; never invent it.

## URL construction

Dataset-scoped pages follow this form:

```text
https://my.relewise.com/{datasetId}/{area-path}
```

Account-scoped pages such as User and Billing omit the Dataset ID:

```text
https://my.relewise.com/{account-path}
```

Use the full `https://my.relewise.com` origin because responses from an external AI client cannot rely on portal-relative links. URL-encode IDs and keys inserted into path segments or query parameters.

Credential detail pages may be linked only when the corresponding non-secret key is present in verified context:

- Personal Access Token: `https://my.relewise.com/user?personalAccessTokenKey={personalAccessTokenKey}#personal-access-tokens`
- Connected App: `https://my.relewise.com/user?oauthConnectionKey={oauthConnectionKey}#connected-apps`

Never substitute a PAT value, OAuth access token, or OAuth client ID for these keys. Never ask the user to share a credential secret to construct a link.

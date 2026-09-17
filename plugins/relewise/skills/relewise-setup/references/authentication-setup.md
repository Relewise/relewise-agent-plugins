# Authentication setup

## Prefer OAuth for MCP

When the AI client supports OAuth for remote MCP servers, connect the Relewise Agent Gateway and complete the My Relewise sign-in and consent flow in the browser. This creates a Connected App; no Personal Access Token is needed for that MCP connection. The user can review the resulting connection under [Connected Apps](https://my.relewise.com/user#connected-apps). Use the client's normal reconnect or disconnect controls if the connection is revoked.

If sign-in fails before consent, diagnose MCP discovery or client configuration through the Agent Gateway skill. Keep OAuth setup pending while resolving that failure. When live OAuth metadata and documentation disagree, report the discrepancy and use observed protocol responses for the connection diagnosis. For an explicit OAuth requirement, continue through the host-managed Agent Gateway MCP connection.

## Create or replace the Personal Access Token

Enter this section only when the user chooses PAT or OAuth support has been ruled out for this client/server.

1. Open [Personal Access Tokens in My Relewise](https://my.relewise.com/user#personal-access-tokens) and sign in if prompted. This page is in the My Relewise web portal, not in the AI client.
2. Select **Create New Token**.
3. Choose the narrowest Dataset scope that supports the intended work. **Selected Datasets** is preferable when access to every Dataset is unnecessary.
4. Store the displayed value immediately in the client or operating-system configuration. My Relewise displays a token value only once.

If a token is expired, revoked, lost, or may have been exposed, create or regenerate it and replace the configured value. Regeneration invalidates the previous value. Dataset scope does not override the user's permissions or the Agent Gateway configuration.

See [Personal Access Tokens](https://docs.relewise.com/docs/myrelewise/agent-gateway/personal-access-tokens.html) for token status, expiration, regeneration, revocation, and Dataset scope.

## Make the token available

The bundled CLI and the plugin's direct REST fallback currently use a PAT. MCP clients without an OAuth-managed Agent Gateway connection may also require a PAT. If the AI client offers a protected plugin or extension setting, use it to configure that MCP connection without exposing the PAT in chat. A vendor-managed MCP credential may not be available to the other transports.

For the bundled CLI and the plugin's direct REST fallback, make the PAT available as `RELEWISE_AGENT_GATEWAY_TOKEN` through one durable route:

1. **Secure credential provider:** Store the PAT in a secure credential facility available to the AI client. Configure the client to retrieve it and inject it as `RELEWISE_AGENT_GATEWAY_TOKEN` whenever it starts the MCP connection, the bundled CLI, or an authenticated REST request. Use this route only when it can be repeated automatically.
2. **Persistent environment variable:** Configure the PAT as a persistent user or system environment variable named `RELEWISE_AGENT_GATEWAY_TOKEN`, then restart the AI client so its process receives the updated environment.

Both routes are supported. Vendors without OAuth or protected configuration use this variable for MCP authentication. Never place the PAT in an AI conversation, visible command text, command arguments, output, logs, URLs, or repository files. The setup must not require the user to paste or export the PAT again before each use.

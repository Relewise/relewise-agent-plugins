# Authentication setup

## Create or replace the Personal Access Token

1. Sign in to [My Relewise](https://my.relewise.com/).
2. Open **User > Personal Access Tokens** and select **Create New Token**.
3. Choose the narrowest Dataset scope that supports the intended work. **Selected Datasets** is preferable when access to every Dataset is unnecessary.
4. Store the displayed value immediately in the client or operating-system configuration. My Relewise displays a token value only once.

If a token is expired, revoked, lost, or may have been exposed, create or regenerate it and replace the configured value. Regeneration invalidates the previous value. Dataset scope does not override the user's permissions or the Agent Gateway configuration.

See [Personal Access Tokens](https://docs.relewise.com/docs/myrelewise/agent-gateway/personal-access-tokens.html) for token status, expiration, regeneration, revocation, and Dataset scope.

## Make the token available

The bundled CLI, the registered Agent Gateway MCP server, and direct Agent Gateway REST requests use the same PAT. If the AI client offers a protected plugin or extension setting, use it to configure the MCP connection without exposing the PAT in chat. A vendor-managed MCP credential may not be available to the other transports.

For the bundled CLI and direct REST, make the PAT available as `RELEWISE_AGENT_GATEWAY_TOKEN` through one durable route:

1. **Secure credential provider:** Store the PAT in a secure credential facility available to the AI client. Configure the client to retrieve it and inject it as `RELEWISE_AGENT_GATEWAY_TOKEN` whenever it starts the MCP connection, the bundled CLI, or an authenticated REST request. Use this route only when it can be repeated automatically.
2. **Persistent environment variable:** Configure the PAT as a persistent user or system environment variable named `RELEWISE_AGENT_GATEWAY_TOKEN`, then restart the AI client so its process receives the updated environment.

Both routes are supported. Vendors without protected configuration also use this variable for MCP authentication. Never place the PAT in an AI conversation, visible command text, command arguments, output, logs, URLs, or repository files. The setup must not require the user to paste or export the PAT again before each use.

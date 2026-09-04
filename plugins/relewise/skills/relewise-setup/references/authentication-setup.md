# Authentication setup

## Create or replace the Personal Access Token

1. Sign in to [My Relewise](https://my.relewise.com/).
2. Open **User > Personal Access Tokens** and select **Create New Token**.
3. Choose the narrowest Dataset scope that supports the intended work. **Selected Datasets** is preferable when access to every Dataset is unnecessary.
4. Store the displayed value immediately in the client or operating-system configuration. My Relewise displays a token value only once.

If a token is expired, revoked, lost, or may have been exposed, create or regenerate it and replace the configured value. Regeneration invalidates the previous value. Dataset scope does not override the user's permissions or the Agent Gateway configuration.

See [Personal Access Tokens](https://docs.relewise.com/docs/myrelewise/agent-gateway/personal-access-tokens.html) for token status, expiration, regeneration, revocation, and Dataset scope.

## Make the token available

Every authenticated `relewise-agent` invocation requires the PAT as the process environment variable `RELEWISE_AGENT_GATEWAY_TOKEN`. Configure one durable route:

1. **Secure credential provider:** Store the PAT in a secure credential facility available to the AI client. Configure the client to retrieve it and inject it only into the `relewise-agent` child process as `RELEWISE_AGENT_GATEWAY_TOKEN` on every invocation.
2. **Persistent environment variable:** Configure the PAT as a persistent user or system environment variable named `RELEWISE_AGENT_GATEWAY_TOKEN`, then restart the AI client so its process receives the updated environment.

Both routes are supported. Never place the PAT in an AI conversation, command text, command arguments, output, logs, or repository files. The setup must not require the user to paste or export the PAT again before each use.

# Privacy and security

The Relewise plugin runs a platform-specific helper executable on the user's device. It sends requests only to the Relewise Agent Gateway at `https://my.relewise.com/agents` for operations selected by the user or their AI agent.

- Authentication uses a Relewise Personal Access Token.
- The token is passed through protected platform configuration or the `RELEWISE_AGENT_GATEWAY_TOKEN` process environment variable. It is never passed as a command-line argument.
- The plugin does not store the token, add telemetry, or send requests to a separate plugin service.
- Relewise authorizes every request using the token's Dataset scope, the user's permissions, and each Dataset's enabled connection methods and allowed areas.
- Responses are returned to the host AI agent. The host platform's own data handling and privacy terms also apply.
- Users should grant the smallest practical Dataset scope and allowed areas, rotate tokens periodically, and revoke a token that may have been exposed.

For Relewise security behavior, see [Agent Gateway security and RBAC](https://docs.relewise.com/docs/myrelewise/agent-gateway/security-and-rbac.html). For Relewise privacy information, see the [Relewise privacy policy](https://www.relewise.com/about/privacypolicy).

Report security concerns privately to support@relewise.com. Do not include Personal Access Tokens or customer data in a public issue.

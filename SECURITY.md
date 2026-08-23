# Security policy

## Supported versions

Security fixes are applied to the latest published release. Users should upgrade to the newest release before reporting an issue that may already be resolved. Versions below `1.0.0` are prereleases and may change.

## Reporting a vulnerability

Report suspected vulnerabilities privately to [support@relewise.com](mailto:support@relewise.com) with **Agent Plugins security** in the subject. Do not open a public issue for a vulnerability.

Include the affected version, platform, impact, and reproduction steps where practical. Do not include Personal Access Tokens, customer data, or other credentials. Relewise will acknowledge the report and coordinate investigation and disclosure directly; response and resolution time depend on severity and complexity.

If a Personal Access Token may have been exposed, revoke it immediately in My Relewise and create a replacement with the smallest practical Dataset scope.

## Security model

- The packaged helper runs on the user's device and communicates with the Relewise Agent Gateway at `https://my.relewise.com/agents`.
- Authentication uses a user-provided Relewise Personal Access Token.
- The token is passed through protected client configuration or `RELEWISE_AGENT_GATEWAY_TOKEN`, never as a command-line argument.
- The plugin does not persist the token, add telemetry, or send requests to a separate plugin service.
- Relewise authorizes every request using the token's Dataset scope, the user's permissions, and the Dataset's enabled connection methods and allowed areas.
- Agent Gateway responses are returned to the host AI client, whose own data-handling and privacy terms also apply.

See [Agent Gateway security and RBAC](https://docs.relewise.com/docs/myrelewise/agent-gateway/security-and-rbac.html) and the [Relewise privacy policy](https://www.relewise.com/about/privacypolicy).

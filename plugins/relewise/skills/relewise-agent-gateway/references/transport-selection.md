# Transport selection

Transport permissions are Dataset-specific and cannot be known before identity and Dataset policy discovery. Treat discovery as a bootstrap phase, then choose the transport for the requested operation.

## Bootstrap

Honor the user's authentication and transport requirements throughout discovery and fallback. OAuth-only requests exclude the PAT-backed CLI and direct REST routes.

Attempt identity discovery in this order until one permitted authenticated route succeeds:

1. Registered Agent Gateway MCP: `get_me` (prefer the host-managed OAuth connection when it is connected).
2. Bundled CLI: `me` or `datasets`.
3. Authenticated direct REST: `GET /api/v1/me` using operation `IdentityGetCurrentUser`.

For connection setup or repair, perform the MCP connection preflight below before declaring MCP unavailable or recommending a new credential. A missing CLI PAT says nothing about the MCP connection's OAuth support.

### MCP connection preflight

- Search the host's available or discoverable tools for Agent Gateway `get_me`. Relewise Hub and Relewise Developer MCP servers are separate connections and do not verify Agent Gateway access.
- If tools are missing, inspect the installed plugin's declared MCP server and the client's server registration, enabled state, and authentication status using supported host controls or CLI commands. Read only non-secret configuration fields. Do not dump configuration, headers, credentials, or environment variables. Missing tools can mean disabled, not signed in, failed startup, or stale tool discovery.
- For setup, use the client's supported OAuth login/reconnect flow for the existing registered server. Determine current commands from host help or official documentation; do not create a duplicate server merely because tools are absent. If no login control is available to the agent, give the user the precise client action required and keep OAuth support unverified.
- Classify login failures separately: unsupported OAuth, sign-in/consent failure, and discovery/transport failure. A redirect, invalid metadata, or network failure during discovery is a connection blocker, not proof that OAuth is unsupported.
- When discovery fails, inspect bounded unauthenticated protocol responses and the advertised metadata URL as needed. Record method, status, redirect location, and authentication challenge. A browser-style GET and an MCP initialization POST may behave differently; follow the advertised `resource_metadata` URL rather than assuming its path. Do not infer other clients' behavior or prescribe a server fix from a single failed request.
- After successful sign-in, refresh tools as supported and call `get_me`. Report pending refresh/restart or a specific blocker when verification cannot yet complete. Do not expose OAuth tokens, authorization codes, or client secrets during diagnosis.

### Dataset discovery

Use the successful identity response to resolve the requested Dataset without guessing its ID. If several Datasets plausibly match and the choice changes the answer, ask the user to choose.

Retrieve that Dataset's details through the working bootstrap route:

- CLI: `dataset <dataset-id>`.
- MCP: `get_dataset_details`.
- Direct REST: operation `CoreGetDataset`.

The effective policy reports `restApiEnabled`, `mcpEnabled`, and enabled `areas`.

## Retain state at the correct scope

For workflows with several calls, retain verified findings instead of repeating discovery:

- **Task scope:** Retain the resolved CLI path and whether the local CLI can execute. Also retain observed availability of registered MCP and direct REST credentials or connections. A genuinely missing or incompatible local executable applies across Datasets.
- **Dataset scope:** Retain access validation and the effective Agent Gateway policy separately for every Dataset used in the workflow. Do not apply one Dataset's transport, Area, permission, or policy result to another Dataset.
- **Operation scope:** Confirm that the requested capability has an exact REST operation or MCP tool on the candidate transport, and use that transport's own schema.

Bootstrap identity and Dataset discovery once when the retained results are sufficient. Retrieve policy once for each involved Dataset, then select and reuse a preferred transport for that Dataset and requested capability. A workflow spanning several Datasets may legitimately mix CLI, MCP, and direct REST. Re-select when the Dataset changes, the next capability is not exposed by the preferred transport, or a classified failure changes that transport's availability.

Do not treat a Dataset-specific policy or permission denial as a task-wide transport failure. Conversely, do not repeatedly try a task-wide missing executable for every Dataset. Preserve call ordering when later calls depend on earlier results or when the domain skill defines a mutation workflow.

## Select the operation transport

After policy discovery, use this preference order:

1. Use registered MCP when it is connected, `mcpEnabled` is true, the requested Area is enabled, and the capability has an exact MCP tool. This is preferred for a host-managed OAuth connection.
2. Use the bundled CLI when it works, `restApiEnabled` is true, the requested Area is enabled, and the capability has an exact REST operation.
3. Use direct REST when `restApiEnabled` is true, the requested Area is enabled, the capability has an exact REST operation, and no preferred MCP or CLI route is usable.

Do not infer that an operation is permitted merely because bootstrap discovery succeeded. Apply the selected Dataset's effective policy to every Dataset-scoped operation.

## Classify failures before falling back

- **Local CLI unavailable:** Missing launcher, unsupported OS or architecture, permission-to-execute failure, or an incompatible executable. Continue to MCP, then direct REST when available.
- **Credential unavailable to one transport:** Another transport may be tried only when it has an independently configured credential. A protected MCP credential, for example, may work even when the CLI environment variable is absent.
- **Network or transient transport failure:** Try another policy-permitted transport when it offers an independent connection path. Avoid identical retries; retry once only when the request warrants it.
- **Authentication rejected:** Determine which credential type the transport uses. For OAuth, the connection may be expired, revoked, or require reconnecting. For PAT authentication, the PAT may be missing, malformed, expired, revoked, or rejected. Do not expose credentials. Try another transport only when it has an independently configured credential, not as a way to evade rejection.
- **Validation error:** Correct the request from the selected transport's schema. Do not switch transports to evade validation.
- **Dataset access, permission, Area, or policy denial:** Stop. Do not bypass the denial through another transport.

Accumulate relevant preflight and bootstrap findings. Report one concise diagnosis and the most useful corrective action instead of treating every unavailable candidate as a separate failure.

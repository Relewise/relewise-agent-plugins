# Transport selection

Transport permissions are Dataset-specific and cannot be known before identity and Dataset policy discovery. Treat discovery as a bootstrap phase, then choose the transport for the requested operation.

## Bootstrap

Attempt identity discovery in this order until one route succeeds:

1. Bundled CLI: `me` or `datasets`.
2. Registered Agent Gateway MCP: `get_me`.
3. Authenticated direct REST: `GET /api/v1/me` using operation `IdentityGetCurrentUser`.

Use the successful identity response to resolve the requested Dataset without guessing its ID. If several Datasets plausibly match and the choice changes the answer, ask the user to choose.

Retrieve that Dataset's details through the working bootstrap route:

- CLI: `dataset <dataset-id>`.
- MCP: `get_dataset_details`.
- Direct REST: operation `CoreGetDataset`.

The effective policy reports `restApiEnabled`, `mcpEnabled`, and enabled `areas`.

## Select the operation transport

After policy discovery, use this preference order:

1. Use the bundled CLI when it works, `restApiEnabled` is true, and the requested Area is enabled. It is the preferred deterministic REST adapter.
2. Use registered MCP when it is connected, `mcpEnabled` is true, and the requested Area is enabled.
3. Use direct REST when `restApiEnabled` is true, the requested Area is enabled, and the CLI is locally unavailable.

Do not infer that an operation is permitted merely because bootstrap discovery succeeded. Apply the selected Dataset's effective policy to every Dataset-scoped operation.

## Classify failures before falling back

- **Local CLI unavailable:** Missing launcher, unsupported OS or architecture, permission-to-execute failure, or an incompatible executable. Continue to MCP, then direct REST when available.
- **Credential unavailable to one transport:** Another transport may be tried only when it has an independently configured credential. A protected MCP credential, for example, may work even when the CLI environment variable is absent.
- **Network or transient transport failure:** Try another policy-permitted transport when it offers an independent connection path. Avoid identical retries; retry once only when the request warrants it.
- **Authentication rejected:** Explain that the configured PAT is missing, malformed, expired, revoked, or rejected. Do not expose it. Trying another transport is useful only if it has an independently configured credential, not as a way to evade rejection.
- **Validation error:** Correct the request from the selected transport's schema. Do not switch transports to evade validation.
- **Dataset access, permission, Area, or policy denial:** Stop. Do not bypass the denial through another transport.

Accumulate relevant preflight and bootstrap findings. Report one concise diagnosis and the most useful corrective action instead of treating every unavailable candidate as a separate failure.

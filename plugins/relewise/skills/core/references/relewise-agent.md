# relewise-agent usage

The executable emits one JSON document and uses exit codes as a secondary signal. Read `success` first.

## Authentication

`RELEWISE_AGENT_GATEWAY_TOKEN` must be configured in the executable's environment. Never pass a PAT as a CLI argument, write it to an input file, or reproduce it in output. On `authentication_error`, tell the user to configure or replace the environment variable without asking them to paste its value.

## Dataset commands

```shell
relewise-agent me
relewise-agent datasets
relewise-agent dataset <dataset-id>
```

Prefer `datasets` for normalized discovery. Use `me` only when user or PAT metadata is relevant. `dataset` validates accessibility and returns Dataset details plus the effective Agent Gateway policy.

## Contract-backed operations

```shell
relewise-agent operations
relewise-agent schema <operation-id>
relewise-agent call <operation-id> --dataset <dataset-id> [--input <path>]
```

Ground every call in an exact operation ID returned by `operations` or named by this skill's `operations.json`. Inspect `schema` before constructing unfamiliar input.

When input is required, write a temporary JSON file using this envelope:

```json
{
  "parameters": {},
  "body": {}
}
```

Use `parameters` for non-Dataset path and query parameters. Include `body` only when the operation accepts a request body. The CLI inserts and validates the Dataset ID itself.

## Error recovery

- `authentication_error`: PAT missing, malformed, expired, or rejected; ask the user to configure it securely.
- `dataset_access_error`: re-run Dataset discovery and do not retry the inaccessible ID.
- `operation_not_found`: refresh operation selection from `operations`; do not guess another ID.
- `validation_error`: correct the input using `schema` and the returned message.
- `api_error`: use the bounded message and status code to correct the request when possible; avoid identical retries.
- `network_error`: report the connectivity failure; retry once only when the user's request warrants it.

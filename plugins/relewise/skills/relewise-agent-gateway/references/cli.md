# Bundled CLI usage

The executable emits one JSON document. Read its `success` property first and use the process exit code as a secondary signal.

## Discovery

```text
relewise-agent me
relewise-agent datasets
relewise-agent dataset <dataset-id>
```

Prefer `datasets` for normalized Dataset discovery. Use `me` when user or non-secret PAT metadata is relevant. `dataset` validates accessibility and returns Dataset details plus its effective Agent Gateway policy.

## Contract-backed operations

```text
relewise-agent operations
relewise-agent schema <operation-id>
relewise-agent call <operation-id> --dataset <dataset-id> [--input <path>]
```

Ground every call in an exact operation ID returned by `operations` or declared by the calling domain skill's `operations.json`. Inspect `schema` before constructing unfamiliar input.

When input is required, write a temporary JSON file with this envelope:

```json
{
  "parameters": {},
  "body": {}
}
```

Use `parameters` for non-Dataset path and query parameters. Include `body` only when the operation accepts a request body. The CLI inserts and validates the Dataset ID.

## Errors

- `authentication_error`: Follow the shared transport failure classification. Never inspect or expose the PAT.
- `dataset_access_error`: Rediscover Datasets and do not retry an inaccessible ID.
- `operation_not_found`: Refresh operation selection from `operations`; never guess an ID.
- `validation_error`: Correct input using `schema` and the returned message.
- `api_error`: Use the bounded message and status code to correct the request when possible; avoid identical retries.
- `network_error`: Treat it as a transport failure and follow the bounded fallback rules.

# relewise-agent

`relewise-agent` is the cross-platform executable used by Relewise Agent Skills. It targets .NET 10 NativeAOT so released binaries do not require a separately installed .NET runtime.

The initial CLI supports PAT-authenticated identity and Dataset discovery, structured help, version, operation discovery, operation schema lookup, and command errors. Additional Dataset-scoped Agent Gateway commands are added in subsequent steps.

## Commands

Authenticate and return the current user, non-secret PAT metadata, and accessible Datasets grouped by License:

```shell
relewise-agent me
```

`me` reads the PAT exclusively from `RELEWISE_AGENT_GATEWAY_TOKEN`. Tokens are not accepted as command-line arguments and are never included in diagnostics.

List accessible Datasets in a normalized, deterministic order with their License context:

```shell
relewise-agent datasets
```

Validate a UUID against the Datasets returned by `/me`, then retrieve its Dataset details and effective Agent Gateway policy:

```shell
relewise-agent dataset 00000000-0000-0000-0000-000000000000
```

The `dataset` command always re-checks `/me` before making the Dataset-scoped request. Unknown, inaccessible, and malformed Dataset IDs return `dataset_access_error`; Dataset IDs are never inferred or invented.

List the embedded Agent Gateway operation catalog in a bounded summary form:

```shell
relewise-agent operations
```

Return the full generated definition for one exact OpenAPI operation ID:

```shell
relewise-agent schema CoreGetDataset
```

The operation catalog is embedded at build time from `generated/operations.json`, so the released executable uses the same versioned contract as its source release.

Execute a Dataset-scoped operation by its exact OpenAPI operation ID:

```shell
relewise-agent call AnalyticsGetRevenue --dataset 00000000-0000-0000-0000-000000000000 --input request.json
```

The optional input file uses a stable envelope:

```json
{
  "parameters": {
    "fromDate": "2026-08-01",
    "toDate": "2026-08-21",
    "currency": "DKK"
  },
  "body": {}
}
```

`parameters` supplies non-Dataset path and query parameters. `body` supplies the JSON request body and must be omitted for operations that do not accept one. `--input` can be omitted when an operation requires neither.

Before executing the operation, `call`:

1. resolves method, path, parameters, body, and Area from the embedded catalog;
2. validates the input envelope, required parameters, scalar parameter types, and required body presence;
3. verifies the Dataset through `/me`;
4. retrieves `/core/dataset` and enforces its effective REST and Area policy;
5. attaches bearer authentication and executes the HTTPS request;
6. returns the operation ID, Dataset ID, HTTP status, and JSON response.

Input files are limited to 1 MiB and a JSON depth of 64. The PAT, HTTP method, URL construction, Dataset path placement, headers, and JSON escaping remain implementation details of `relewise-agent`.

All commands emit one JSON document. Successful commands exit with code `0`; internal failures use `1`, invalid commands or arguments use `2`, unknown operation IDs use `3`, authentication failures use `4`, network failures use `5`, Agent Gateway API failures use `6`, Dataset access failures use `7`, and request validation failures use `8`.

Failures use a stable machine-readable envelope:

```json
{
  "success": false,
  "error": {
    "type": "validation_error",
    "message": "Required parameter 'fromDate' is missing.",
    "operationId": "AnalyticsGetRevenue"
  }
}
```

`type` is one of `authentication_error`, `dataset_access_error`, `operation_not_found`, `validation_error`, `api_error`, `network_error`, `invalid_arguments`, `command_not_found`, or `internal_error`. `operationId` and `statusCode` are included when they apply. For API failures, the CLI extracts a concise message from a JSON problem response when available; otherwise it reports the HTTP status. Error response bodies are bounded to 64 KiB, error messages to 500 characters, and bearer tokens are never returned.

## Run during development

```shell
dotnet run --project src/relewise-agent -- --version
```

## Publish a native executable

Publish for the current operating system by supplying its runtime identifier:

```shell
dotnet publish src/relewise-agent --configuration Release --runtime win-x64
```

Planned release runtime identifiers are:

- `win-x64`
- `linux-x64`
- `linux-arm64`
- `osx-x64`
- `osx-arm64`

NativeAOT compilation is performed on the target operating system in the release build matrix; it is not cross-compiled from one host.

# Agent Gateway integration tests

These live tests verify the released CLI boundary against dedicated, non-customer Relewise test Datasets. They authenticate through `/me`, discover and validate two Datasets, inspect their effective Agent Gateway policies, and execute `CoreGetDatasetMetadata` through the generic operation executor.

The GitHub Actions workflow requires:

| Type | Name |
| --- | --- |
| Repository secret | `RELEWISE_AGENT_GATEWAY_TEST_TOKEN` |
| Repository variable | `RELEWISE_AGENT_GATEWAY_TEST_DATASET_ID_PRIMARY` |
| Repository variable | `RELEWISE_AGENT_GATEWAY_TEST_DATASET_ID_SECONDARY` |

The PAT must be dedicated to CI and restricted to the two configured test Datasets. The workflow does not print API payloads, response headers, the PAT, or Dataset IDs.

To run locally, configure the same three environment variables and publish a native executable, then run:

```shell
pwsh tests/integration/live.ps1 -ExecutablePath <path-to-relewise-agent>
```

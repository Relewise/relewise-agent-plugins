# API coverage generator

This internal build-time tool maps every operation in the generated Agent Gateway catalog to the canonical capability skills that reference it. It is used by contributors and CI and is not distributed as part of a plugin.

Run it from anywhere inside the repository:

```shell
dotnet run --project tools/generate-coverage
```

It reads `generated/operations.json` and `plugins/**/operations.json`, then writes:

- `generated/operation-coverage.json` for machine-readable coverage data;
- `docs/api-coverage.md` for the human-readable matrix.

The command reports the covered and total operation counts and exits with a failure when any catalog operation is not represented by at least one skill.

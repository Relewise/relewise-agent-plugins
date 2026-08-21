# Skill operation validator

This internal build-time tool verifies that canonical Relewise skills reference operations present in the versioned Agent Gateway contract. It is used by contributors and CI and is not distributed as part of a plugin.

Each skill declares its contract dependencies in an `operations.json` file:

```json
{
  "operationIds": [
    "CoreGetDataset"
  ]
}
```

The validator discovers these files below `plugins/` and checks that every operation ID:

- is a string;
- occurs only once within its manifest;
- exists in `generated/operations.json`.

An operation manifest must contain at least one operation ID. Invalid JSON and malformed manifests also fail validation.

Run the validator from anywhere inside the repository:

```shell
dotnet run --project tools/validate-skills
```

The tool locates the repository root automatically and uses these fixed locations:

| Purpose | Location |
| --- | --- |
| Generated operation catalog | `generated/operations.json` |
| Skill operation manifests | `plugins/**/operations.json` |

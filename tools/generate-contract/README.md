# Agent Gateway contract generator

Generate the operation catalog and component schema files from the checked-in OpenAPI snapshot:

```shell
dotnet run --project tools/generate-contract
```

The command can be run from any directory inside the repository. Optional `--contract <path>` and `--output <directory>` arguments override the default locations.

# relewise-agent

`relewise-agent` is the cross-platform executable used by Relewise Agent Skills. It targets .NET 10 NativeAOT so released binaries do not require a separately installed .NET runtime.

The initial CLI supports structured help, version, operation discovery, operation schema lookup, and command errors. Network-backed Agent Gateway commands are added in subsequent steps.

## Commands

List the embedded Agent Gateway operation catalog in a bounded summary form:

```shell
relewise-agent operations
```

Return the full generated definition for one exact OpenAPI operation ID:

```shell
relewise-agent schema CoreGetDataset
```

The operation catalog is embedded at build time from `generated/operations.json`, so the released executable uses the same versioned contract as its source release.

All commands emit one JSON document. Successful commands exit with code `0`; invalid commands or arguments use `2`, unknown operation IDs use `3`, and internal catalog failures use `1`.

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

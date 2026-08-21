# relewise-agent

`relewise-agent` is the cross-platform executable used by Relewise Agent Skills. It targets .NET 10 NativeAOT so released binaries do not require a separately installed .NET runtime.

The initial foundation supports structured help, version, and unknown-command responses. Agent Gateway commands are added in subsequent steps.

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

# GitHub Copilot CLI adapter

This adapter supports two separately installable products: `Relewise` for configuration, analytics, and optimization, and `Relewise Developer` for implementation and troubleshooting.

The adapter packages the canonical Relewise Agent Plugin with the `relewise-agent` NativeAOT executable. Its manifest and skills remain under `plugins/relewise`; the package script copies them and adds only the Copilot-specific executable-location instruction. Local adapter packaging can target one runtime for validation; normal distribution uses the repository marketplace.

Copilot CLI does not define protected plugin configuration in `plugin.json`. Set `RELEWISE_AGENT_GATEWAY_TOKEN` in the environment used to start Copilot, preferably through your operating system or secret manager, and redact it from Copilot's shell and MCP environments:

```shell
copilot --secret-env-vars=RELEWISE_AGENT_GATEWAY_TOKEN --plugin-dir artifacts/github-copilot/<runtime-id>/relewise
```

The PAT is inherited by the bundled launcher and passed to the executable through its process environment. It is never placed in command arguments or package files.

Build the executable for the target runtime, then package it:

```powershell
dotnet publish src/relewise-agent/relewise-agent.csproj --configuration Release --runtime win-x64 --output artifacts/win-x64
./tools/package/github-copilot.ps1 -RuntimeIdentifier win-x64 -ExecutablePath artifacts/win-x64/relewise-agent.exe
```

The default output is `artifacts/github-copilot/<runtime-id>/relewise`. Supported runtime identifiers are `win-x64`, `linux-x64`, `linux-arm64`, `osx-x64`, and `osx-arm64`.

For repository installation, register and install the marketplace:

```shell
copilot plugin marketplace add Relewise/relewise-agent-plugins
copilot plugin install relewise@relewise
copilot plugin install relewise-developer@relewise
```

The root `.github/plugin/marketplace.json` points directly to `plugins/relewise`; the package path remains useful for testing release archives.

Installed plugins update through Copilot's marketplace mechanism. The Claude custom-plugin ZIP is not a Copilot distribution artifact.

The Relewise Developer plugin is read directly from `plugins/relewise-developer`. Copilot discovers its `.mcp.json`, connects `https://mcp.relewise.com`, and loads the development skill without an Agent Gateway executable or PAT.

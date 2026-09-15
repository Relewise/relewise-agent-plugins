# GitHub Copilot CLI adapter

This adapter supports two separately installable products: `Relewise` for configuration, analytics, and optimization, and `Relewise Developer` for implementation and troubleshooting.

The adapter packages the canonical Relewise Agent Plugin with the `relewise-agent` NativeAOT executable. Its manifest and skills remain under `plugins/relewise`; the package script copies them and adds only the Copilot-specific executable-location instruction. Local adapter packaging can target one runtime for validation; normal distribution uses the repository marketplace.

Copilot connects Agent Gateway through OAuth. Use `/mcp auth relewise-agent-gateway` when sign-in is required. The generated Agent Plugins `mcp.json` contains no PAT header or token requirement.

For the bundled CLI or direct REST fallback only, supply `RELEWISE_AGENT_GATEWAY_TOKEN` through a secure credential provider or the process environment. Never place it in command arguments or package files.

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

The root `.claude-plugin/marketplace.json` points directly to `plugins/relewise`; the package path remains useful for testing release archives.

Installed plugins update through Copilot's marketplace mechanism. The Claude custom-plugin ZIP is not a Copilot distribution artifact.

The Relewise Developer plugin is read directly from `plugins/relewise-developer`. Copilot discovers its generated `mcp.json`, connects `https://mcp.relewise.com`, and loads the development skill without an Agent Gateway executable or PAT.

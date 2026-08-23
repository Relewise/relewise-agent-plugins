# GitHub Copilot CLI adapter

This adapter packages `Relewise`: work with your Relewise configuration, analytics and optimization using AI. `Relewise Developer` is a separate product and is not included.

The adapter packages the canonical Relewise skills with one platform-specific `relewise-agent` NativeAOT executable. Canonical skills remain under `plugins/relewise/skills`; the package script copies them and adds only the Copilot-specific executable-location instruction.

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

For a persistent installation, use `copilot plugin install <package-path>` instead of `--plugin-dir`.

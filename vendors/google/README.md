# Google Gemini CLI adapter

This adapter packages `Relewise`: work with your Relewise configuration, analytics and optimization using AI. `Relewise Developer` is a separate product and is not included.

The adapter packages the canonical Relewise skills with the `relewise-agent` NativeAOT executable. Canonical skills remain under `plugins/relewise/skills`, while the gallery manifest remains at the repository root as required by Gemini CLI. Tagged releases provide Gemini's five conventionally named platform archives so Gemini CLI can select the smallest correct asset automatically. Windows uses the PowerShell launcher; the other platforms use the shell launcher.

Gemini requests the Agent Gateway PAT as a sensitive extension setting during installation or configuration. Gemini stores it securely and makes it available to the registered MCP connection.

To use the bundled CLI fallback as well, make the PAT available to Gemini CLI as `RELEWISE_AGENT_GATEWAY_TOKEN` through a secure credential provider or a persistent user or system environment variable, then restart Gemini CLI. The PAT is never placed in command arguments or package files.

Build the executable for the target runtime, then package it:

```powershell
dotnet publish src/relewise-agent/relewise-agent.csproj --configuration Release --runtime win-x64 --output artifacts/win-x64
./tools/package/google.ps1 -RuntimeIdentifier win-x64 -ExecutablePath artifacts/win-x64/relewise-agent.exe
```

The default output is `artifacts/google/<runtime-id>/relewise`. Install that directory with:

```shell
gemini extensions install artifacts/google/<runtime-id>/relewise
```

Supported runtime identifiers are `win-x64`, `linux-x64`, `linux-arm64`, `osx-x64`, and `osx-arm64`.

For normal GitHub installation, Gemini CLI uses the conventionally named platform release asset and detects updates from the latest stable GitHub release tag. Gemini does not use the Claude custom-plugin ZIP.

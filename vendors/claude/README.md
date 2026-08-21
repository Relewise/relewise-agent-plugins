# Claude Code adapter

The Claude Code adapter packages the canonical Relewise skills with one platform-specific `relewise-agent` NativeAOT executable. Canonical skills remain under `plugins/relewise/skills`; they are copied into packages and are not maintained here.

The plugin asks for a required Agent Gateway PAT through Claude Code's sensitive user configuration. Claude stores that value securely and exposes it to the bundled launcher as `CLAUDE_PLUGIN_OPTION_agent_gateway_token`. The launcher maps it to `RELEWISE_AGENT_GATEWAY_TOKEN` only in the executable process environment. It never places the PAT in command arguments or plugin files.

Build the executable for the target runtime, then package it:

```powershell
dotnet publish src/relewise-agent/relewise-agent.csproj --configuration Release --runtime win-x64 --output artifacts/win-x64
./tools/package/claude.ps1 -RuntimeIdentifier win-x64 -ExecutablePath artifacts/win-x64/relewise-agent.exe
```

The default output is `artifacts/claude/<runtime-id>/relewise`. Load that directory during development with:

```shell
claude --plugin-dir artifacts/claude/<runtime-id>/relewise
```

Supported runtime identifiers are `win-x64`, `linux-x64`, `linux-arm64`, `osx-x64`, and `osx-arm64`.

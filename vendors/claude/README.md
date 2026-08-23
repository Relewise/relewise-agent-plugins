# Claude Code adapter

This adapter packages `Relewise`: work with your Relewise configuration, analytics and optimization using AI. `Relewise Developer` is a separate product and is not included.

The adapter packages the canonical Relewise skills with one platform-specific `relewise-agent` NativeAOT executable. Canonical skills remain under `plugins/relewise/skills`; they are copied into packages and are not maintained here.

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

## Fresh-install acceptance test

Use a machine with Claude Code installed and authenticated but without an existing Relewise plugin. Build the package for that machine, load its `relewise` directory with `claude --plugin-dir`, and provide the Agent Gateway PAT when Claude prompts for the required protected plugin option.

Verify these prompts in order:

1. `What Relewise Datasets do I have access to?`
2. `Tell me about <one returned Dataset name>.`
3. `Compare <one returned Dataset name> and <another returned Dataset name>.`

The workflow passes when Claude discovers and invokes the packaged skill and launcher, authenticates successfully, resolves the named Datasets without the user supplying IDs, and returns a useful comparison. The PAT must not appear in command arguments, output, transcripts, or package files.

# Claude Code adapter

This adapter packages `Relewise`: work with your Relewise configuration, analytics and optimization using AI. `Relewise Developer` is a separate product and is not included.

The adapter packages the canonical Relewise skills with the `relewise-agent` NativeAOT executable. Canonical skills remain under `plugins/relewise/skills`; they are copied into packages and are not maintained here. Local adapter packaging can target one runtime for validation. Tagged releases instead provide one portable marketplace containing every supported runtime for manual installation across Claude, Codex, and GitHub Copilot.

Make the Agent Gateway PAT available to the executable as `RELEWISE_AGENT_GATEWAY_TOKEN`. Use a secure credential provider that can inject it into the `relewise-agent` process on every invocation, or configure it as a persistent user or system environment variable. The PAT is never placed in command arguments or plugin files.

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

For repository installation, register and install the marketplace:

```shell
claude plugin marketplace add Relewise/relewise-agent-plugins
claude plugin install relewise@relewise
```

The root `.claude-plugin/marketplace.json` points directly to `plugins/relewise`; the package path remains useful for testing release archives.

For manual distribution, use `relewise-portable-marketplace-v<version>.zip` from the GitHub release. Extract it and add the resulting `relewise-agent-plugins` folder as a local marketplace. Local packages do not receive GitHub marketplace updates, so users install a newer downloaded release to upgrade. Repository-installed plugins continue to update through Claude's marketplace mechanism.

## Fresh-install acceptance test

Use a machine with Claude Code installed and authenticated but without an existing Relewise plugin. Configure `RELEWISE_AGENT_GATEWAY_TOKEN` in the environment available to Claude Code, build the package for that machine, and load its `relewise` directory with `claude --plugin-dir`.

Verify these prompts in order:

1. `What Relewise Datasets do I have access to?`
2. `Tell me about <one returned Dataset name>.`
3. `Compare <one returned Dataset name> and <another returned Dataset name>.`

The workflow passes when Claude discovers and invokes the packaged skill and launcher, authenticates successfully, resolves the named Datasets without the user supplying IDs, and returns a useful comparison. The PAT must not appear in command arguments, output, transcripts, or package files.

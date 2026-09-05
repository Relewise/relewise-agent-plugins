# OpenAI Codex adapter

This adapter supports two separately installable products: `Relewise` for configuration, analytics, and optimization, and `Relewise Developer` for implementation and troubleshooting.

The adapter packages the canonical Relewise skills with the `relewise-agent` NativeAOT executable. Canonical skills remain under `plugins/relewise/skills`; the package script copies them and adds only the Codex-specific executable-location instruction. Local adapter packaging can target one runtime for validation; normal distribution uses the repository marketplace.

Codex plugin manifests do not contain protected plugin configuration. Set `RELEWISE_AGENT_GATEWAY_TOKEN` in the environment available to Codex, preferably through your operating system or secret manager. The PAT is inherited by the bundled launcher and passed to the executable through its process environment. It is never placed in command arguments or package files.

Build the executable for the target runtime, then package it:

```powershell
dotnet publish src/relewise-agent/relewise-agent.csproj --configuration Release --runtime win-x64 --output artifacts/win-x64
./tools/package/openai.ps1 -RuntimeIdentifier win-x64 -ExecutablePath artifacts/win-x64/relewise-agent.exe
```

The default output is `artifacts/openai/<runtime-id>/relewise`. Supported runtime identifiers are `win-x64`, `linux-x64`, `linux-arm64`, `osx-x64`, and `osx-arm64`.

For direct Codex installation, add the repository as a marketplace using the `main` Git ref and an empty sparse-path setting. The root `.agents/plugins/marketplace.json` catalog points directly to the canonical plugin under `plugins/relewise`.

The required source fingerprint prevents runtime-affecting changes from merging without their generated payload. A maintainer runs **Refresh marketplace payload** on the originating feature branch to build all five native runtimes and commit synchronized vendor manifests and executables before merge. `main` is verification-only and never opens a repair PR. Public ChatGPT/Codex directory updates remain subject to OpenAI's submission, review, and publication process.

`Relewise Developer` is packaged from `plugins/relewise-developer` without the Agent Gateway executable. Its `.mcp.json` connects `https://mcp.relewise.com`, and its Codex manifest provides the separate Developer identity and icon.

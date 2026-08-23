# OpenAI Codex adapter

This adapter packages `Relewise`: work with your Relewise configuration, analytics and optimization using AI. `Relewise Developer` is a separate product and is not included.

The adapter packages the canonical Relewise skills with the `relewise-agent` NativeAOT executable. Canonical skills remain under `plugins/relewise/skills`; the package script copies them and adds only the Codex-specific executable-location instruction. Local packaging can target one runtime, while tagged releases also provide a universal archive containing every supported runtime. Its launcher selects the correct executable automatically without downloading code during use.

Codex plugin manifests do not contain protected plugin configuration. Set `RELEWISE_AGENT_GATEWAY_TOKEN` in the environment available to Codex, preferably through your operating system or secret manager. The PAT is inherited by the bundled launcher and passed to the executable through its process environment. It is never placed in command arguments or package files.

Build the executable for the target runtime, then package it:

```powershell
dotnet publish src/relewise-agent/relewise-agent.csproj --configuration Release --runtime win-x64 --output artifacts/win-x64
./tools/package/openai.ps1 -RuntimeIdentifier win-x64 -ExecutablePath artifacts/win-x64/relewise-agent.exe
```

The default output is `artifacts/openai/<runtime-id>/relewise`. Supported runtime identifiers are `win-x64`, `linux-x64`, `linux-arm64`, `osx-x64`, and `osx-arm64`.

For repository distribution and acceptance testing, use `relewise-openai-universal-v<version>.tar.gz` from the GitHub release. Public ChatGPT/Codex directory updates follow OpenAI's submission, review, and publication process rather than tracking the latest repository release automatically.

Marketplace metadata and public installation instructions are intentionally deferred to the marketplace phase of the implementation plan.

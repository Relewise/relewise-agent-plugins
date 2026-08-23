# OpenAI Codex adapter

The OpenAI Codex adapter packages the canonical Relewise skills with one platform-specific `relewise-agent` NativeAOT executable. Canonical skills remain under `plugins/relewise/skills`; the package script copies them and adds only the Codex-specific executable-location instruction.

Codex plugin manifests do not contain protected plugin configuration. Set `RELEWISE_AGENT_GATEWAY_TOKEN` in the environment available to Codex, preferably through your operating system or secret manager. The PAT is inherited by the bundled launcher and passed to the executable through its process environment. It is never placed in command arguments or package files.

Build the executable for the target runtime, then package it:

```powershell
dotnet publish src/relewise-agent/relewise-agent.csproj --configuration Release --runtime win-x64 --output artifacts/win-x64
./tools/package/openai.ps1 -RuntimeIdentifier win-x64 -ExecutablePath artifacts/win-x64/relewise-agent.exe
```

The default output is `artifacts/openai/<runtime-id>/relewise`. Supported runtime identifiers are `win-x64`, `linux-x64`, `linux-arm64`, `osx-x64`, and `osx-arm64`.

Marketplace metadata and public installation instructions are intentionally deferred to the marketplace phase of the implementation plan.

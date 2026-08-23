# Google Gemini CLI adapter

The Gemini CLI adapter packages the canonical Relewise skills with one platform-specific `relewise-agent` NativeAOT executable. Canonical skills remain under `plugins/relewise/skills`; the package script copies them and adds only the Gemini-specific executable-location instruction.

During extension installation, Gemini CLI asks for the Relewise Agent Gateway PAT declared in `gemini-extension.json`. The setting is marked sensitive, so Gemini stores it in the system keychain, obfuscates it in the UI, and exposes it to the extension as `RELEWISE_AGENT_GATEWAY_TOKEN`. The PAT is never placed in command arguments or package files.

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

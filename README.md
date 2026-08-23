# Relewise Agent Plugins

AI agent plugins for Relewise.

## Products

### Relewise

Work with your Relewise configuration, analytics and optimization using AI.

This product is for people operating and improving Relewise. It is available for Claude Code, GitHub Copilot CLI, OpenAI Codex, and Google Gemini CLI.

### Relewise Developer

Build and troubleshoot Relewise integrations using AI development agents.

This product is for developers implementing Search, Recommendations, and behavioral tracking with Relewise.

The two products are intentionally separate. Choose the product that matches the work you want to do; no knowledge of the underlying Relewise APIs or agent protocols is required.

## Releases

The repository is versioned as one ecosystem. Pushing a semantic version tag such as `v0.1.0` validates the contracts and skills, builds and tests all supported native executables, packages every vendor adapter, and publishes the installable archives in a GitHub release. `v0.*` releases are published as prereleases; `v1.0.0` and later tags are stable releases.

Each tagged release includes a self-contained universal archive for Claude Code, GitHub Copilot CLI, OpenAI Codex, and Google Gemini CLI. A universal archive contains all five supported native runtimes and its launcher automatically selects Windows x64, Linux x64/ARM64, or macOS x64/ARM64. No executable is downloaded during plugin use. Platform-specific archives remain available, including Gemini's conventionally named assets used for automatic platform selection.

The tag is the release version source. It is applied to the executable and packaged manifests during the release; maintainers do not need to update each source manifest before tagging.

Marketplace-ready copy, onboarding guidance, platform notes, and official artwork live under `marketplace/relewise/`.

Installed versions update through the vendor's plugin or extension update mechanism. The Agent Gateway PAT remains external user configuration and is neither packaged nor replaced during an upgrade.

This repository is licensed under the [MIT License](LICENSE).

# Relewise Agent Plugins

AI agent plugins for Relewise.

## Products

### Relewise

Work with your Relewise configuration, analytics and optimization using AI.

This product is for people operating and improving Relewise. It is available for Claude Code, GitHub Copilot CLI, OpenAI Codex, and Google Gemini CLI.

### Relewise Developer

Build and troubleshoot Relewise integrations using AI development agents.

This product is for developers implementing Search, Recommendations, behavioral tracking, and data integration with Relewise. It automatically connects the remote Relewise Developer MCP and does not require an Agent Gateway PAT.

The two products are intentionally separate. Choose the product that matches the work you want to do; no knowledge of the underlying Relewise APIs or agent protocols is required.

Both products use the portable [Agent Plugins](https://agent-plugins.org/) structure: each directory under `plugins/` contains a canonical `plugin.json` manifest and [Agent Skills](https://agentskills.io/) compliant with the open specification. Platform-specific files under `vendors/` adapt that shared source for clients that require their own format. Installation and updates remain specific to each client.

## Prerelease installation

The project is currently distributed as a prerelease. Codex, Claude Code, and GitHub Copilot CLI users can add this repository directly as a marketplace. Gemini CLI installs the platform package selected from [GitHub Releases](https://github.com/Relewise/relewise-agent-plugins/releases).

To add the Codex marketplace, use `https://github.com/Relewise/relewise-agent-plugins.git` as the source, `main` as the Git ref, and leave **Sparse paths** empty. The marketplace points directly at the canonical Relewise plugin and includes all five native runtimes.

Marketplace updates are atomic with their source changes. Required fingerprints separately track plugin content and executable inputs. A maintainer runs **Refresh marketplace payload** on a stale feature branch: runtime changes rebuild and commit all five NativeAOT executables, while skill, metadata, asset, launcher, or packaging-only changes reuse the existing executables. Both paths package and smoke-test the complete plugin before committing synchronized metadata back to the branch. Workflows on `main` only verify committed content and never create repair commits or follow-up pull requests.

Claude Code users add the marketplace with `claude plugin marketplace add Relewise/relewise-agent-plugins`, then install either `relewise@relewise` or `relewise-developer@relewise`. GitHub Copilot CLI users add the same repository marketplace, then install either plugin with `copilot plugin install`. Codex users can choose both plugins after adding the repository marketplace. Every catalog points to the canonical plugin directories; skills are not copied into the vendor adapters.

Gemini CLI users run `gemini extensions install https://github.com/Relewise/relewise-agent-plugins`. Gemini selects the matching release asset for the current platform. The repository must also carry the `gemini-cli-extension` GitHub topic before gallery discovery can work.

Claude Desktop and Cowork users who do not want to connect GitHub can download either `relewise-claude-plugin-v<version>.zip` or `relewise-developer-claude-plugin-v<version>.zip` from [GitHub Releases](https://github.com/Relewise/relewise-agent-plugins/releases) and upload it as a custom plugin. The Relewise ZIP contains all five supported Agent Gateway runtimes; the smaller Relewise Developer ZIP contains its skill, icon, and remote MCP configuration. Manually uploaded plugins must be uploaded again for upgrades.

Make a Relewise Agent Gateway PAT available to the executable as `RELEWISE_AGENT_GATEWAY_TOKEN`, either through a secure credential provider that injects it on every invocation or as a persistent user or system environment variable. Never put a PAT in a prompt or command argument.

Packaged skills explicitly invoke `scripts/relewise-agent`, which selects the matching native executable under `libexec/<runtime>/`. Packages intentionally have no top-level `bin/` directory so hosted marketplaces do not receive an undeclared PATH executable.

## Releases

The repository is versioned as one ecosystem. Pushing a semantic version tag such as `v0.1.0` validates the contracts and skills, builds and tests all supported native executables, packages every vendor adapter, and publishes the installable archives in a GitHub release. `v0.*` releases are published as prereleases; `v1.0.0` and later tags are stable releases.

The planned version is maintained manually in `version.json`. Marketplace manifests automatically use `<version>-main.<run ID>`. Executables retain the version of their most recent runtime build until their code, embedded operation catalog, project configuration, or `version.json` changes. A release tag such as `v0.4.0` must match `version.json` and rebuilds every executable and manifest as version `0.4.0`. After a release, update `version.json` in a normal pull request when the next version is decided.

Each tagged release contains seven intentional assets: five conventionally named, platform-specific Relewise archives used by Gemini CLI, plus one direct-upload Claude ZIP for each plugin. `relewise-claude-plugin-v<version>.zip` contains all five native runtimes and its launcher selects Windows x64, Linux x64/ARM64, or macOS x64/ARM64. `relewise-developer-claude-plugin-v<version>.zip` contains no native executable because it connects directly to the remote Developer MCP.

The release workflow applies that version to the executable and every packaged manifest; maintainers do not update the individual manifests.

Marketplace-ready copy, onboarding guidance, platform notes, and official artwork live under `marketplace/relewise/`.

Installed versions update through the vendor's plugin or extension update mechanism. The Agent Gateway PAT remains external user configuration and is neither packaged nor replaced during an upgrade.

See [CONTRIBUTING.md](CONTRIBUTING.md) before proposing changes and [SECURITY.md](SECURITY.md) for private vulnerability reporting. This repository is licensed under the [MIT License](LICENSE).

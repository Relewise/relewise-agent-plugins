# OpenAI Codex

## Prepared listing

- Name: **Relewise**
- Description: **Work with your Relewise configuration, analytics and optimization using AI.**
- Category: **Productivity**
- Brand color: **#3764E4**
- Homepage: https://www.relewise.com/
- Support: https://docs.relewise.com/docs/support/

Use the detailed description, requirements, examples, and security text from the parent marketplace content.

## Installation and authentication copy

Add `https://github.com/Relewise/relewise-agent-plugins.git` as a Codex plugin marketplace, use `main` as the Git ref, and leave **Sparse paths** empty. Then install Relewise from that marketplace. Make the Personal Access Token available to the executable as `RELEWISE_AGENT_GATEWAY_TOKEN`. Use a secure credential provider that can inject it into the `relewise-agent` process on every invocation, or configure it as a persistent user or system environment variable. Never place the PAT in a prompt, command argument, repository file, or log.

The repository marketplace is self-contained and supports Windows x64, Linux x64/ARM64, and macOS x64/ARM64 without downloading executable code during use.

## Publication route

The repository-level `.agents/plugins/marketplace.json` on `main` points directly to the canonical Relewise plugin. Runtime-affecting source changes cannot merge until a maintainer-triggered workflow has committed all five synchronized NativeAOT runtimes and vendor manifests to the same pull request branch. `main` only verifies that committed payload. OpenAI's reviewed public directory remains a separate discovery route.

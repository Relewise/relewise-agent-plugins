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

Add `https://github.com/Relewise/relewise-agent-plugins.git` as a Codex plugin marketplace, use `main` as the Git ref, and leave **Sparse paths** empty. Then install Relewise from that marketplace. Set `RELEWISE_AGENT_GATEWAY_TOKEN` in the environment available to Codex, preferably through the operating system or a secret manager. The bundled launcher passes the token to the executable through its process environment and never places it in command arguments.

The repository marketplace is self-contained and supports Windows x64, Linux x64/ARM64, and macOS x64/ARM64 without downloading executable code during use.

## Publication route

The repository-level `.agents/plugins/marketplace.json` on `main` points directly to the canonical Relewise plugin. GitHub Actions keeps its five committed NativeAOT runtimes synchronized through generated PRs. OpenAI's reviewed public directory remains a separate discovery route.

# GitHub Copilot CLI

## Prepared listing

- Name: **Relewise**
- Description: **Work with your Relewise configuration, analytics and optimization using AI.**
- Category: **Productivity**
- Homepage: https://www.relewise.com/
- Support: https://docs.relewise.com/docs/support/

Use the detailed description, requirements, examples, and security text from the parent marketplace content.

## Installation and authentication copy

Register the repository marketplace and install Relewise:

```shell
copilot plugin marketplace add Relewise/relewise-agent-plugins
copilot plugin install relewise@relewise
```

Set `RELEWISE_AGENT_GATEWAY_TOKEN` in the environment used to start Copilot CLI, preferably through the operating system or a secret manager, and protect it from tool output:

```shell
copilot --secret-env-vars=RELEWISE_AGENT_GATEWAY_TOKEN
```

## Publication route

Copilot CLI discovers the root `.github/plugin/marketplace.json`. Its Relewise entry points to the canonical `plugins/relewise` directory on `main`.

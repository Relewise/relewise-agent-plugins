# GitHub Copilot CLI

## Prepared listing

- Name: **Relewise**
- Description: **Work with your Relewise configuration, analytics and optimization using AI.**
- Category: **Productivity**
- Homepage: https://www.relewise.com/
- Support: https://docs.relewise.com/docs/support/

Use the detailed description, requirements, examples, and security text from the parent marketplace content.

## Installation and authentication copy

Install the Relewise plugin from its published marketplace. Set `RELEWISE_AGENT_GATEWAY_TOKEN` in the environment used to start Copilot CLI, preferably through the operating system or a secret manager, and protect it from tool output:

```shell
copilot --secret-env-vars=RELEWISE_AGENT_GATEWAY_TOKEN
```

The final installation command depends on the marketplace identifier assigned during publication.

## Publication route

Copilot CLI installs plugins from registered marketplaces, repositories, or local paths. A marketplace catalog and public distribution source will be added during publication.

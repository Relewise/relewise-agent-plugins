# Claude Code

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
claude plugin marketplace add Relewise/relewise-agent-plugins
claude plugin install relewise@relewise
```

Make `RELEWISE_AGENT_GATEWAY_TOKEN` available in the environment used by Claude Code. In Claude Desktop, use the encrypted local environment editor; open the environment selector beside the prompt, hover over **Local**, select the gear icon, and add the variable there. Start a new Claude session after changing it. The plugin does not use Claude's protected `userConfig` because those sensitive values are not available to ordinary commands run by skills.

## Publication route

Claude Code discovers the root `.claude-plugin/marketplace.json`. Its Relewise entry points to the canonical `plugins/relewise` directory on `main`. Submission to Anthropic's official marketplace remains a separate optional publication step.

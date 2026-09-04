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

Make the Personal Access Token available to the executable as `RELEWISE_AGENT_GATEWAY_TOKEN`. Use a secure credential provider that can inject it into the `relewise-agent` process on every invocation, or configure it as a persistent user or system environment variable and restart Claude Code. Never place the PAT in a prompt, command argument, repository file, or log. The plugin does not use Claude's protected `userConfig` because its sensitive values are not available to ordinary commands run by skills.

## Publication route

Claude Code discovers the root `.claude-plugin/marketplace.json`. Its Relewise entry points to the canonical `plugins/relewise` directory on `main`. Submission to Anthropic's official marketplace remains a separate optional publication step.

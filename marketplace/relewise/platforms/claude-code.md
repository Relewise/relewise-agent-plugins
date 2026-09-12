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

Claude authenticates the Agent Gateway MCP connection through OAuth. Sign in to My Relewise and approve the Connected App when prompted. No Personal Access Token is needed for that MCP connection.

To use the bundled `relewise-agent` fallback, or when OAuth is unavailable, make a PAT available to the executable as `RELEWISE_AGENT_GATEWAY_TOKEN` through a secure credential provider or a persistent user or system environment variable, then restart Claude Code. Never place the PAT in a prompt, command argument, repository file, or log.

## Publication route

Claude Code discovers the root `.claude-plugin/marketplace.json`. Its Relewise entry points to the canonical `plugins/relewise` directory on `main`. Submission to Anthropic's official marketplace remains a separate optional publication step.

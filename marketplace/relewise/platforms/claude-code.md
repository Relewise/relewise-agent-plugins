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

Provide a Relewise Agent Gateway Personal Access Token when Claude Code requests the protected plugin setting. Claude Code exposes the protected value only to the plugin launcher, which passes it to the bundled executable through its process environment.

## Publication route

Claude Code discovers the root `.claude-plugin/marketplace.json`. Its Relewise entry points to the canonical `plugins/relewise` directory on `main`. Submission to Anthropic's official marketplace remains a separate optional publication step.

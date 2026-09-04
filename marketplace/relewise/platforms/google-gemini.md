# Google Gemini CLI

## Prepared listing

- Name: **Relewise**
- Description: **Work with your Relewise configuration, analytics and optimization using AI.**
- Homepage: https://www.relewise.com/
- Support: https://docs.relewise.com/docs/support/

Use the detailed description, requirements, examples, and security text from the parent marketplace content.

## Installation and authentication copy

Install the Relewise extension from its GitHub release. Make the Personal Access Token available to the executable as `RELEWISE_AGENT_GATEWAY_TOKEN`. Use a secure credential provider that can inject it into the `relewise-agent` process on every invocation, or configure it as a persistent user or system environment variable. Gemini CLI's sensitive extension setting implements the credential-provider route. Never place the PAT in a prompt, command argument, repository file, or log.

The final command will use the public repository URL:

```shell
gemini extensions install https://github.com/Relewise/relewise-agent-plugins
```

## Publication route

Gemini CLI's gallery discovers public GitHub repositories with the `gemini-cli-extension` topic and a root manifest in the repository or release archive. The release pipeline produces the required platform-specific asset names:

- `win32.x64.relewise.zip`
- `linux.x64.relewise.tar.gz`
- `linux.arm64.relewise.tar.gz`
- `darwin.x64.relewise.tar.gz`
- `darwin.arm64.relewise.tar.gz`

Making the repository public and adding the discovery topic are publication steps, not part of metadata preparation.

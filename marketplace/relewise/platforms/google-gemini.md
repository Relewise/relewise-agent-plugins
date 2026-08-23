# Google Gemini CLI

## Prepared listing

- Name: **Relewise**
- Description: **Work with your Relewise configuration, analytics and optimization using AI.**
- Homepage: https://www.relewise.com/
- Support: https://docs.relewise.com/docs/support/

Use the detailed description, requirements, examples, and security text from the parent marketplace content.

## Installation and authentication copy

Install the Relewise extension from its GitHub release. Gemini CLI requests the Relewise Agent Gateway Personal Access Token during installation, stores the sensitive setting in the system keychain, and exposes it to the extension as `RELEWISE_AGENT_GATEWAY_TOKEN`.

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

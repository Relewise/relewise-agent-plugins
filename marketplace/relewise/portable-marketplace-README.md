# Relewise portable marketplace

This package provides the Relewise plugin for Claude, OpenAI Codex, and GitHub Copilot without connecting the client directly to GitHub.

1. Extract the ZIP file.
2. In your AI client, add the extracted `relewise-agent-plugins` folder as a local plugin marketplace.
3. Install **Relewise** from that marketplace.
4. Ask your agent: `Help me connect Relewise.`

The package supports Windows x64, Linux x64/ARM64, and macOS x64/ARM64. It includes no credentials. Relewise requires an Agent Gateway Personal Access Token; follow the agent's setup guidance or see [Use Relewise with an AI Assistant](https://docs.relewise.com/docs/myrelewise/agent-gateway/agent-plugin.html).

Local packages do not update through GitHub. Download and install a newer release when you want to upgrade. Vendor interfaces can change; contact Relewise if the local-marketplace option no longer appears in your client.

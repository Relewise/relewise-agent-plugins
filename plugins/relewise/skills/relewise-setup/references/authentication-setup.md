# Authentication setup

Use the section that matches the user's client. Do not give every platform's instructions at once.

## Create or replace the Personal Access Token

1. Sign in to [My Relewise](https://my.relewise.com/).
2. Open **User > Personal Access Tokens** and select **Create New Token**.
3. Choose the narrowest Dataset scope that supports the intended work. **Selected Datasets** is preferable when access to every Dataset is unnecessary.
4. Store the displayed value immediately in the client or operating-system configuration. My Relewise displays a token value only once.

If a token is expired, revoked, lost, or may have been exposed, create or regenerate it and replace the configured value. Regeneration invalidates the previous value. Dataset scope does not override the user's permissions or the Agent Gateway configuration.

See [Personal Access Tokens](https://docs.relewise.com/docs/myrelewise/agent-gateway/personal-access-tokens.html) for token status, expiration, regeneration, revocation, and Dataset scope.

## Codex

Codex must be started with `RELEWISE_AGENT_GATEWAY_TOKEN` available in its environment. Fully quit Codex before changing the variable, then reopen it afterwards.

### Windows

1. Open the Start menu and search for **Edit environment variables for your account**.
2. Under **User variables**, select **New**.
3. Enter `RELEWISE_AGENT_GATEWAY_TOKEN` as the variable name and paste the token as its value.
4. Confirm all dialogs, fully quit Codex, and reopen it.

Use a user variable rather than a system variable. The setting applies only to this Windows user and does not synchronize to another computer.

### macOS

macOS applications opened from Finder or the Dock do not normally receive variables configured only in a shell profile. Prefer a trusted secret manager or managed launch configuration that can expose `RELEWISE_AGENT_GATEWAY_TOKEN` to Codex.

For a session-scoped setup without writing the token to a shell startup file:

1. Fully quit Codex and open **Terminal**.
2. Run `read -s "RELEWISE_AGENT_GATEWAY_TOKEN?Paste the token, then press Return: "`. The terminal waits for input and does not display the pasted value.
3. Paste the token and press Return.
4. Run `launchctl setenv RELEWISE_AGENT_GATEWAY_TOKEN "$RELEWISE_AGENT_GATEWAY_TOKEN"` followed by `unset RELEWISE_AGENT_GATEWAY_TOKEN`.
5. Reopen Codex from Finder or the Dock.

The launch setting lasts only for the current macOS login session. Run `launchctl unsetenv RELEWISE_AGENT_GATEWAY_TOKEN` to remove it. Do not put the token itself directly in a command, shell history, repository file, shell startup file, or Codex prompt.

## Claude Code

Use the Relewise plugin's required **Relewise Agent Gateway PAT** protected setting. Claude Code stores it as sensitive user configuration and supplies it only to the plugin launcher. Do not additionally create `RELEWISE_AGENT_GATEWAY_TOKEN` at operating-system level unless the protected setting is unavailable in the installed Claude version.

If the protected value must be replaced, use Claude Code's plugin configuration to update it, then start a new Claude session before verifying the connection.

## GitHub Copilot CLI

Make `RELEWISE_AGENT_GATEWAY_TOKEN` available in the environment that starts Copilot CLI, then start Copilot with `--secret-env-vars=RELEWISE_AGENT_GATEWAY_TOKEN` so the value is protected from tool output. Never put the token value itself in the command.

## Gemini CLI

Provide the token when the Relewise extension requests its sensitive setting. Gemini stores that setting in the system keychain and exposes it to the extension as `RELEWISE_AGENT_GATEWAY_TOKEN`. Use the extension configuration to replace the value when necessary.

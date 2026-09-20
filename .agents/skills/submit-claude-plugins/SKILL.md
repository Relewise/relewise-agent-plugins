---
name: submit-claude-plugins
description: Prepare, validate, submit, or resubmit the Relewise and Relewise Developer plugins to Anthropic's public Claude Plugin Directory. Use only for this repository's Claude directory workflow, including checking an existing submission's status or handling a duplicate-under-review result.
---

# Submit Relewise plugins to Claude

Prepare each directory submission from repository-owned metadata, then use Anthropic's current submission form only when the user authorizes browser operation.

## Establish the submission state

1. Read `AGENTS.md`, `CONTRIBUTING.md`, the selected plugin's `.claude-plugin/plugin.json`, and its OpenAI submission dossier under `marketplace/<plugin>/openai/submission.json`.
2. Confirm the source branch and commit contain the intended public plugin state. For shipped plugin changes, require the synchronized marketplace payload and generated plugin version described in `AGENTS.md` before presenting the submission as ready. Never refresh the payload on `main`.
3. Determine whether this is an initial submission, a replacement requested by Anthropic, or an attempted resubmission. Do not assume an under-review submission can be replaced.
4. Run the local Claude/plugin validations relevant to the selected plugin before opening the form. At minimum run:

```powershell
./tests/package/configuration.ps1
./tests/package/codex-marketplace.ps1 -MarketplaceRoot .
./tools/validate-agent-skills/validate-agent-skills.ps1 -PluginsRoot .agents/skills
git diff --check
```

Use the parameter shape actually required by a validation script in the current checkout; inspect its `param` block rather than guessing.

## Populate the form

Read [references/portal-workflow.md](references/portal-workflow.md) before operating Anthropic's portal. Populate one plugin at a time and review every value against the repository before continuing.

Use these canonical mappings:

- **Link to plugin:** `https://github.com/Relewise/relewise-agent-plugins`
- **Path within repository:** `plugins/relewise` or `plugins/relewise-developer`
- **Plugin name and description:** the selected `.claude-plugin/plugin.json`, with longer public copy from the matching OpenAI dossier when the form supports it
- **Homepage:** plugin-specific documentation, not the corporate landing page
  - Relewise: `https://docs.relewise.com/docs/myrelewise/agent-gateway/agent-plugin.html`
  - Relewise Developer: `https://docs.relewise.com/docs/developer/mcp.html`
- **License:** `MIT`
- **Privacy policy:** the matching OpenAI dossier's `branding.privacyPolicy`; currently `https://docs.relewise.com/Privacy.html`
- **Supported platforms:** select only surfaces verified for the submitted plugin version. Both repository plugins are intended for Claude Code and Claude Cowork, but re-check current packaging and validation evidence before asserting support.
- **Contact email:** obtain it from the maintainer for the submission. Never infer it from Git history or commit metadata.

Derive concise example use cases from the plugin's public marketplace README and canonical skills. Keep the business-facing Relewise plugin distinct from Relewise Developer: the former covers authorized Dataset operations and analysis; the latter covers implementation guidance for Relewise APIs and SDKs.

## Authorization and stopping conditions

Browser login, form population, and transmission of the explicitly supplied contact email may proceed only within the user's authorization and the active computer-use confirmation policy.

Immediately before **Submit for review**, show the user the plugin name, repository path, supported surfaces, homepage, privacy URL, license, and contact email. Obtain fresh confirmation for that submission. A request to prepare or resubmit does not replace action-time confirmation for the final representational submission.

After submission, verify the visible success state and record the status without storing portal identifiers or personal data in the repository.

If the portal reports that the repository and path already have a submission under review, stop. Do not create a duplicate, change the path to evade matching, or claim that resubmission succeeded. Inspect available submission-management UI without discarding a draft or deleting/withdrawing a submission. Deleting or withdrawing an existing submission requires separate explicit confirmation at action time. If no management control is available, report that Anthropic or the Relewise partner contact must amend or withdraw the pending submission.

Never commit credentials, customer data, reviewer access, portal identifiers, or temporary URLs.

---
name: submit-openai-plugins
description: Prepare, validate, and optionally populate initial or update drafts for the Relewise and Relewise Developer plugins in the public OpenAI Plugins Directory. Use only for this repository's OpenAI submission workflow; never submit, publish, or unpublish a plugin.
---

# Submit Relewise plugins to OpenAI

Prepare a reproducible submission from the repository. Ask the human whether to use the available browser to populate the portal draft; do not operate the portal without that approval.

## Prepare the repository

1. Read `AGENTS.md`, `CONTRIBUTING.md`, and the selected plugin's `marketplace/<plugin>/openai/submission.json`.
2. Confirm the source branch contains the intended plugin changes. Shipped plugin changes require a refreshed marketplace payload and generated plugin version before a PR is ready; never refresh on `main`.
3. Run the preparation script from the repository root:

```powershell
./.agents/skills/submit-openai-plugins/scripts/prepare-openai-plugin-submission.ps1 `
  -Plugin relewise `
  -SubmissionMode Initial `
  -Version <public-semver> `
  -ReleaseNotes <reviewer-facing-summary> `
  -DemoRecordingUrl <https-url-if-available>
```

Choose `Initial` when the selected plugin has no published directory record; choose `Update` when creating a new draft for an existing published plugin. This choice is independent of `-Plugin`. The script validates the canonical dossier, verifies the MCP endpoint and every declared skill, packages complete skill directories (including scripts, references, and assets), packages the full plugin, and writes portal material under `artifacts/openai-submission/<plugin>/<version>/`.

## Review the artifacts

Review `chatgpt-app-submission.json`, `artifact-manifest.json`, and `manual-checklist.md`. Do not treat generated copy or tool justifications as self-approving. After the portal scans the live MCP server, compare every discovered tool and annotation with the generated material and the server's actual behavior.

Read [references/portal-workflow.md](references/portal-workflow.md) before operating the portal. It distinguishes initial submissions, updates, continuously reviewed MCP changes, and manual-only steps.

## Validate

Run:

```powershell
./tests/package/openai-submission.ps1
./tools/validate-agent-skills/validate-agent-skills.ps1 -PluginsRoot .agents/skills
git diff --check
```

Also run the repository validations relevant to any changed shipped plugin content. Generated submission artifacts are local review outputs and must not be committed.

## Authorization boundary

Creating or editing a portal draft, uploading files, and entering reviewer credentials are external actions. Prepare everything first, then explicitly ask the human whether to use the available browser to populate the draft. Approval to populate a draft does not authorize any final action.

Always stop with the completed draft open for human review. Never click or otherwise invoke **Submit for Review**, **Publish**, or **Unpublish**, even if the user asks. Explain that these actions are intentionally human-only. Do not accept attestations on the human's behalf. Never commit reviewer credentials, access tokens, customer data, or signed temporary file URLs.

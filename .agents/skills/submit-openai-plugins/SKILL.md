---
name: submit-openai-plugins
description: Prepare, validate, and guide initial or update submissions of the Relewise and Relewise Developer plugins to the public OpenAI Plugins Directory. Use only for this repository's OpenAI submission workflow; it does not authorize submitting, publishing, unpublishing, or changing live portal records.
---

# Submit Relewise plugins to OpenAI

Prepare a reproducible submission from the repository and stop before external actions unless the user explicitly authorizes them.

## Prepare the repository

1. Read `AGENTS.md`, `CONTRIBUTING.md`, and the selected plugin's `marketplace/<plugin>/openai/submission.json`.
2. Confirm the source branch contains the intended plugin changes. Shipped plugin changes require a refreshed marketplace payload and generated plugin version before a PR is ready; never refresh on `main`.
3. Run the preparation script from the repository root:

```powershell
./.agents/skills/submit-openai-plugins/scripts/prepare-openai-plugin-submission.ps1 `
  -Plugin relewise `
  -Version <public-semver> `
  -ReleaseNotes <reviewer-facing-summary> `
  -DemoRecordingUrl <https-url-if-available>
```

Use `-Plugin relewise-developer` for the developer plugin. The script validates the canonical dossier, verifies the MCP endpoint and every declared skill, packages complete skill directories (including scripts, references, and assets), packages the full plugin, and writes portal material under `artifacts/openai-submission/<plugin>/<version>/`.

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

Creating a portal draft, uploading files, entering reviewer credentials, accepting attestations, submitting for review, publishing, and unpublishing are external actions. Prepare everything first, then obtain any confirmation required by the active computer-use policy immediately before the relevant action. Never commit reviewer credentials, access tokens, customer data, or signed temporary file URLs.

# Claude Plugin Directory workflow

## Current entry points

Check Anthropic's current plugin documentation before each submission because directory names, eligibility, and review routing can change.

- Submission documentation: `https://code.claude.com/docs/en/plugins#submit-your-plugin-to-the-community-marketplace`
- Claude Platform form: `https://platform.claude.com/plugins/submit`
- Claude organization form: `https://claude.ai/admin-settings/directory/submissions/plugins/new`

The organization form requires an eligible paid Claude plan and directory-management access. Use the Claude Platform form for an individual maintainer when organization access is unavailable. Do not upgrade a plan or create a different account as part of this workflow.

Anthropic's documentation and UI may distinguish the public community directory from separately curated official listings. Describe the destination using the wording visible in the current form and documentation; do not promise placement in an Anthropic-curated catalog.

## Prepare one plugin

1. Validate the repository and confirm the intended commit is pushed and publicly accessible.
2. Open the submission form in the maintainer's authorized Anthropic account.
3. Read and accept the current directory terms only when the user requested submission work.
4. Populate the repository URL, exact repository-relative plugin path, documentation homepage, public name, description, and representative use cases.
5. Select only tested Claude surfaces.
6. Enter `MIT`, the canonical privacy-policy URL, and the maintainer-supplied contact email.
7. Review the complete form against the repository.
8. Obtain action-time confirmation immediately before **Submit for review**.
9. Submit once and verify the visible result.

Prepare and submit Relewise and Relewise Developer separately because Anthropic identifies each by its repository path.

## Existing and replacement submissions

Treat the portal's current status as authoritative:

- If no matching submission exists, proceed as an initial submission.
- If Anthropic explicitly requested a corrected replacement, follow the instructions attached to that submission and preserve the exact repository path.
- If the form reports that the repository and path are already under review, stop before submission. The Console form may not expose a submission dashboard or withdrawal control.
- Do not discard an unsaved browser draft merely to inspect another screen without applying the active confirmation policy.
- Do not delete or withdraw a submission without separate explicit confirmation immediately before that action.
- If no update, delete, or withdrawal control is available, ask the maintainer to contact Anthropic or their partner contact. Do not work around duplicate detection with a different URL, branch, or path.

## Canonical copy sources

Use repository sources instead of remembering portal text:

| Portal field | Relewise | Relewise Developer |
|---|---|---|
| Repository path | `plugins/relewise` | `plugins/relewise-developer` |
| Manifest | `plugins/relewise/.claude-plugin/plugin.json` | `plugins/relewise-developer/.claude-plugin/plugin.json` |
| Public dossier | `marketplace/relewise/openai/submission.json` | `marketplace/relewise-developer/openai/submission.json` |
| Marketplace copy | `marketplace/relewise/README.md` | `marketplace/relewise-developer/README.md` |
| Homepage | Agent Gateway plugin documentation | Relewise Developer MCP documentation |

The OpenAI dossiers are reused only as canonical public company, privacy, and long-description metadata. Claude-specific repository paths, manifests, supported surfaces, and portal behavior remain authoritative for the Claude submission.

## Handoff

Report for each plugin:

- repository commit and generated plugin version;
- validations run and their results;
- form destination and account/organization used, without exposing personal account data unnecessarily;
- submitted, under review, blocked as duplicate, or awaiting maintainer action;
- any portal warning or Anthropic follow-up required.

Do not claim that a submitted plugin is published or installed in a public directory until the live directory confirms it.

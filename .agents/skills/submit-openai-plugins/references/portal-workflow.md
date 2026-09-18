# OpenAI portal workflow

Source of truth: https://developers.openai.com/plugins/deploy/submission

## Initial submission

Use this mode when the selected plugin has no published directory record.

1. Open `https://platform.openai.com/plugins` in the correct organization and project.
2. Select **Create plugin** and **With MCP**.
3. Upload `chatgpt-app-submission.json` when the portal accepts the current generated format, then review every imported field. Otherwise use it as the canonical copy source.
4. Upload the directory and composer icons from the prepared artifact directory.
5. Enter the production MCP endpoint and OAuth configuration, complete domain verification, and select **Scan Tools**.
6. Upload the generated per-skill ZIPs. Do not upload only `SKILL.md`; the ZIP must retain scripts, references, assets, and relative paths.
7. Review the three starter prompts, five positive tests, three negative tests, availability, reviewer setup, release notes, and demo recording.
8. Stop with the completed draft open. The human must review it, complete attestations, and select **Submit for Review** themselves.

## Update submission

Use this mode when the selected plugin already has a published directory record.

1. Open the existing record for the selected plugin.
2. Use the plugin-level **Create Draft** action. Released versions are read-only.
3. Set a semantic version greater than the published version and import or copy the prepared metadata.
4. Scan the MCP endpoint from the selected dossier, review every discovered tool and justification, and upload every generated skill ZIP.
5. Re-run the tests and review all previously approved fields. Do not assume the existing recording or attestations are automatically sufficient; reuse the recording only when it still demonstrates the submitted behavior and the portal accepts it.
6. Stop with the completed draft open. The human must review it, complete attestations, and select **Submit for Review** themselves; publication is also human-only.

## When a new version is required

The portal continuously reviews compatible changes to an already published MCP server. A new portal version is still required for changed listing information, imported skill snapshots, new or materially changed tools, endpoint changes, or other changes the portal flags for review. Server-only fixes that preserve published tool definitions and behavior may not require a new version; verify against the current review documentation and portal notice.

## Manual-only material

- Verified Relewise business identity and Apps Management write access.
- Domain-verification challenge response when requested.
- Reviewer account or credentials supplied only through the secure portal channel and usable without MFA, email/SMS confirmation, or private-network access.
- Demo recording made in Developer Mode. Treat it as required whenever the portal field or reviewer asks for it; there is no documented blanket exemption for updates.
- Policy attestations, final **Submit for Review**, post-approval **Publish**, and **Unpublish**. The skill must refuse to perform these actions even when asked.

Never place credentials, customer Dataset IDs, customer data, temporary signed URLs, or portal-generated file IDs in the repository.

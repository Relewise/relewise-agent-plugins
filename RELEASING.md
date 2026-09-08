# Releasing

This public guide is for repository maintainers. It is not included in the Relewise plugins or vendor packages.

## Repository release

The repository is released as one ecosystem. `version.json` is the planned semantic version; individual plugin manifests are generated and must not be edited manually.

Use the internal `release-relewise-agent-plugins` skill under `.agents/skills/` to run the resumable two-phase process:

1. Prepare a release branch and pull request, link its Trello card, update the planned version, refresh the marketplace payload, and wait for required validation.
2. After the pull request is merged and publication is explicitly approved, tag the exact merge commit, monitor the release workflow, verify every expected artifact, and complete the Trello publication item.

The release workflow is the source of truth for generated artifacts and whether a release is marked as a prerelease. Do not create or replace release assets manually.

## Vendor-specific publication

A GitHub release and a vendor's official directory are separate publication channels. Follow the additional rules below when a change affects a reviewed vendor listing.

### Repository marketplaces

Codex, Claude Code, and GitHub Copilot CLI consume the repository marketplace. Refreshing the marketplace payload on the feature or release branch synchronizes their installable versions. Installed updates are handled through each client.

### Gemini CLI

Gemini CLI installs the platform-specific archive published by the tagged release. Verify all Gemini assets as part of the repository release; there is no separate Relewise Developer Gemini package.

### Claude Desktop and Cowork

The tagged release publishes one direct-upload ZIP for each plugin. Users of a manually uploaded ZIP must upload the newer ZIP themselves. An official Anthropic directory submission or update is a separate vendor process and must follow Anthropic's current requirements.

### OpenAI Plugin Directory: Relewise Developer

OpenAI publishes a reviewed snapshot of the metadata exposed by `https://mcp.relewise.com`.

- Changes to the tool list, names, titles, descriptions, input or output schemas, annotations, security schemes, tool `_meta`, linked UI resource metadata, or MCP server instructions require a new draft version. Deploy the backward-compatible change, scan the endpoint, submit the version for review, and publish it after approval.
- Compatible server-only fixes, live tool-result changes, and business-data changes do not require resubmission when the published contract remains unchanged.
- Do not deploy breaking contract changes. Add replacements while preserving the published contract, then submit and publish the new version.
- Changing the MCP endpoint path uses the normal new-version flow. Changing its scheme, hostname, or port requires a new plugin submission.

See [OpenAI's MCP metadata versioning guidance](https://developers.openai.com/plugins/deploy/app-review#how-published-mcp-metadata-versions-work) before updating the published plugin; vendor requirements can change.

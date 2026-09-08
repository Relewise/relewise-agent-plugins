# Relewise Developer

Build and troubleshoot Relewise integrations using current API and SDK guidance from the remote [Relewise Developer MCP](https://docs.relewise.com/docs/developer/mcp.html).

Install this plugin when you are implementing Search, Recommendations, behavioral tracking, or data integration in C#, TypeScript/JavaScript, PHP, or Java. It includes one focused development skill and automatically connects `https://mcp.relewise.com`; no Relewise credential is required for the Developer MCP.

`Relewise Developer` is separate from the business-facing `Relewise` plugin. It does not include Agent Gateway binaries, PAT setup, analytics, merchandising, or other operational workflows.

Additional developer skills should be introduced only when real usage shows that a narrower workflow adds value.

## OpenAI Plugin Directory maintenance

OpenAI publishes a reviewed snapshot of the Developer MCP metadata. Changes to tool names, descriptions, schemas, annotations, security schemes, `_meta` fields, or server instructions require a new draft version in the OpenAI submission portal: deploy the compatible change, scan the MCP endpoint, submit it for review, and publish it after approval.

Server-only fixes and changes to live results do not require resubmission when they preserve the published contract. Do not deploy breaking contract changes while the current version is published; keep existing contracts working until the replacement has been reviewed and published.

See [OpenAI's MCP metadata versioning guidance](https://developers.openai.com/plugins/deploy/app-review#how-published-mcp-metadata-versions-work) for the current requirements.

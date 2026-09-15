# Repository maintainer instructions

Read `CONTRIBUTING.md` before changing this repository. Keep maintainer instructions outside the shipped plugins.

## Plugin versions and PR readiness

Changes to shipped plugin content, including skills, references, MCP configuration, metadata, assets, launchers, or runtime code, must include a synchronized marketplace payload and updated generated plugin version in the same pull request. Skill-only changes count.

Before presenting a plugin PR as ready for review:

1. Commit and push the source changes on the feature branch.
2. Run **Refresh marketplace payload** (`refresh-marketplace.yml`) on that branch. Never run the refresh on `main`.
3. Wait for the workflow to finish, fetch its generated commit, and fast-forward the local branch when safe. Inspect the generated manifest versions and fingerprints. Verify that the changed plugin's version advanced; do not assume pushing source changes bumps it.
4. Check validation on the resulting PR head. Resolve failures and report any pending checks or blockers explicitly before handing off the PR.
5. Include the resulting version and refresh/validation status in the PR description or handoff. If plugin content changes again, repeat the refresh before declaring the PR ready.

Do not manually edit generated manifest versions or fingerprints. The workflow generates `<version>-main.<run ID>` versions and decides whether native executables need rebuilding. Maintainer-only documentation changes do not require a payload refresh unless they affect packaged inputs.

`version.json` is the planned semantic release version, not a per-PR counter. Change it when the next release version is decided, keep the root `gemini-extension.json` version aligned, and refresh the payload afterward. For a tagged release, follow `.agents/skills/release-relewise-agent-plugins/SKILL.md` and `RELEASING.md`; a routine plugin PR does not authorize tagging or publishing a release.

## Public audience and instruction scope

Write shipped plugin instructions for external users of this repository's marketplace and plugins. Identify tools and connections through positive matches to the owning plugin's declared server name, endpoint, and capability. Keep examples and dependencies grounded in this repository's public plugin contents and documented interfaces. Explain the required action directly; preserve explicit credential and permission safeguards where needed.

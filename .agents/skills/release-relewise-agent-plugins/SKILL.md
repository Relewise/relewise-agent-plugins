---
name: release-relewise-agent-plugins
description: Prepare and publish a versioned relewise-agent-plugins release, including its release pull request, synchronized marketplace payload, required Trello tracking, tag, GitHub prerelease or release, and artifact verification. Use only for releases of this repository.
---

# Release Relewise Agent Plugins

Run the repeatable two-phase release process for this repository. Resume safely when a phase was partially completed instead of duplicating branches, pull requests, Trello cards, checklist items, tags, or releases.

This is a repository-maintainer skill under `.agents/skills/`. It must never be referenced by a public plugin manifest or included in a vendor package.

## Required inputs and gates

- Require the intended semantic version. Normalize it to `v<major>.<minor>.<patch>` for the tag and `<major>.<minor>.<patch>` for `version.json`.
- Require a Trello card as described below. Trello work must use the Relewise Hub MCP, not browser automation or the public Trello API.
- Phase 1 may prepare the pull request without approval to publish.
- Phase 2 requires explicit user confirmation that the release pull request was merged. Never merge the pull request, push a release tag, replace a tag, or publish a release without that confirmation.
- Never add a pull-request reviewer automatically.

## Trello tracking

If the user supplies a Trello card, retrieve and use it. If no card is supplied, first look for an active Sprint-board card for the same repository and version; reuse an unambiguous match. Otherwise:

1. Resolve the board named `Sprint`, its `In Progress` list, and its `Integration` label by name through Relewise Hub. Do not hard-code their IDs.
2. Resolve the invoking user to exactly one member of that board and assign that member. Use authenticated identity or known user context when available; if the match is ambiguous, ask before creating the card.
3. Create the card in `In Progress`, apply `Integration`, assign the invoking user, and use the title `Agent Plugins: Release v<version>`.

Ensure the card contains exactly one incomplete checklist item named `Publish v<version> release`. Reuse an existing release checklist where practical; otherwise create a concise `Release` checklist. Do not mark the item complete during phase 1.

Keep the card description concise and preserve existing content. Record material completed steps as short bullets, including the release-preparation pull request and, after phase 2, the published release. Do not move or close the card unless separately requested.

## Phase 1: prepare

1. Inspect `README.md`, `CONTRIBUTING.md`, `version.json`, `.github/workflows/refresh-marketplace.yml`, and `.github/workflows/release.yml` so the repository remains the source of truth.
2. Verify the worktree is clean, fetch the remote, and confirm local `main` is current with `origin/main`. Confirm the requested tag and an open release pull request for the version do not already exist. When they do, inspect and resume the existing work rather than creating duplicates.
3. Create or reuse `release/v<version>` from `main`. Change only the planned version in `version.json` initially, then commit and push the branch.
4. Create or update a concise release-preparation pull request targeting `main`. Its description must include the canonical Trello card URL and explain the version change, marketplace refresh, expected release packaging, and validation. Do not add reviewers.
5. Dispatch **Refresh marketplace payload** on the release branch. Wait for its generated commit, pull it locally, and review the resulting manifest, fingerprint, runtime-version, and executable changes. A version change is a runtime input, so all supported executables are expected to rebuild.
6. Approve only the protected CI runs triggered for the generated pull-request head, then wait for every required check. Investigate failures; never weaken validation to make the release pass.
7. Verify the local branch is clean and synchronized, the pull request targets `main`, and all required checks pass. Update the Trello description and stop for the user's review and merge.

## Phase 2: publish

Proceed only after the user explicitly confirms the phase-1 pull request was merged.

1. Fetch the remote and verify the pull request is merged, its merge is reachable from `origin/main`, and `origin/main` contains the requested value in `version.json`.
2. Check whether the exact tag and GitHub release already exist. If neither exists, create the annotated tag from the verified `origin/main` commit and push that exact tag. Never move or replace an existing tag.
3. Monitor the tag-triggered **Release** workflow through completion. Derive the expected release assets and prerelease behavior from `.github/workflows/release.yml` rather than maintaining a second artifact list in this skill.
4. Verify the GitHub release uses the exact tag, has the expected prerelease status, and contains every expected asset with no missing or unexpected files. Verify downloadable artifacts have nonzero sizes.
5. Only after successful publication and artifact verification, mark `Publish v<version> release` complete and add a concise published-release bullet with its URL to the Trello card description.

## Failure and recovery

- Leave the Trello publication item incomplete whenever the workflow or release verification fails.
- Report the failed gate and preserve resumable state. Do not delete branches, tags, releases, workflow runs, or Trello content as cleanup.
- On a rerun, inspect existing state first and continue from the first incomplete verified step.

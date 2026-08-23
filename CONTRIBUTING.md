# Contributing

Thank you for improving the Relewise Agent Plugins. Contributions should preserve the repository's vendor-neutral architecture and must not include credentials, customer Dataset IDs, or customer data.

## Before you start

- Use a focused branch and pull request. Do not commit directly to `main`.
- Discuss product-level changes with Relewise before investing in a large implementation.
- Report security concerns privately as described in [SECURITY.md](SECURITY.md).
- Keep canonical plugin manifests and skills under `plugins/`; keep client-specific packaging under `vendors/`.
- Do not duplicate canonical `SKILL.md` files in vendor adapters.

## Development requirements

- .NET SDK 10
- PowerShell 7
- Python 3.11 or later for Agent Skills reference validation

Install the pinned Agent Skills validator:

```shell
python -m pip install skills-ref==0.1.1
```

## Making changes

### Agent Gateway contract

Update the checked-in contract through the repeatable script, then regenerate its derived files:

```powershell
./tools/update-agent-gateway-contract.ps1
dotnet run --project tools/generate-contract
dotnet run --project tools/generate-coverage
```

Do not edit files under `generated/` or `docs/api-coverage.md` manually.

### Agent Skills

- Name each skill directory exactly as the `name` in its `SKILL.md` frontmatter.
- Keep descriptions specific about what the skill does and when it applies.
- Put mechanical API details in generated contracts and the helper, not in skill instructions.
- Add every referenced Agent Gateway operation ID to the skill's `operations.json`.
- Use relative paths for bundled references.

### CLI and packaging

- Keep CLI output structured and deterministic.
- Never accept the PAT as a command-line argument or include it in diagnostics.
- Preserve Dataset access validation and effective Agent Gateway policy enforcement.
- Change shared behavior at its canonical source; vendor adapters should remain thin.

## Validation

Run the checks relevant to your change. The complete local validation set is:

```powershell
dotnet run --project tools/generate-contract
dotnet run --project tools/validate-skills
./tools/validate-agent-skills/validate-agent-skills.ps1
dotnet run --project tools/validate-agent-plugins
dotnet run --project tools/generate-coverage
dotnet build src/relewise-agent/relewise-agent.csproj --configuration Release
git diff --check
```

Generated files must remain unchanged after regeneration. NativeAOT and vendor packages are tested across all supported platforms in CI.

Live integration tests require Relewise's dedicated internal test configuration. External contributors are not expected to have those credentials; maintainers and CI perform that validation.

## Pull requests

Keep the title and description concise and explain:

- what changed and why;
- any user-visible or security impact;
- the validation performed;
- whether generated files, contracts, manifests, or release packaging changed.

All required CI checks must pass before merge. Contributions are licensed under the repository's [MIT License](LICENSE).

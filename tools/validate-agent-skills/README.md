# Agent Skills validation

This script validates every canonical skill under `plugins/` with the Agent Skills reference validator. The validator checks the standard `SKILL.md` structure, frontmatter, naming constraints, and the requirement that a skill's name matches its directory.

Install the pinned validator and run the script from the repository root:

```powershell
python -m pip install skills-ref==0.1.1
./tools/validate-agent-skills/validate-agent-skills.ps1
```

The existing .NET skill validator remains responsible for Relewise-specific operation references.

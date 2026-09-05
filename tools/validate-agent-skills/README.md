# Agent Skills validation

This script validates Agent Skills below a selected root with the Agent Skills reference validator. By default it validates every canonical product skill under `plugins/`. The validator checks the standard `SKILL.md` structure, frontmatter, naming constraints, and the requirement that a skill's name matches its directory.

Install the pinned validator and run the script from the repository root:

```powershell
python -m pip install skills-ref==0.1.1
./tools/validate-agent-skills/validate-agent-skills.ps1
./tools/validate-agent-skills/validate-agent-skills.ps1 -PluginsRoot .agents/skills
```

The second command validates repository-maintainer skills. These remain outside product plugin manifests and vendor packages.

The existing .NET skill validator remains responsible for Relewise-specific operation references.

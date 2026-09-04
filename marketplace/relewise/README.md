# Relewise marketplace content

## Listing

**Name:** Relewise

**Short description:** Work with your Relewise configuration, analytics and optimization using AI.

**Detailed description:**

Relewise gives your AI agent access to the Relewise Datasets your user and Personal Access Token permit. Inspect configuration, understand performance and consumption, review merchandising and Search Tools, compare Datasets, and run guided optimization workflows without finding Dataset IDs or assembling API requests manually.

Access stays within the permissions, Dataset scope, connection methods, and allowed areas configured in My Relewise.

## Example prompts

- Help me connect Relewise.
- What Relewise Datasets do I have access to?
- Review search performance for my Relewise Dataset.
- Compare search performance across two Relewise Datasets.
- Audit merchandising rules and point out conflicts or gaps.
- Show which features drive the most consumption.

## Requirements

- Access to My Relewise.
- The **Use Agent Gateway** permission for at least one Dataset.
- Agent Gateway REST enabled for that Dataset.
- A Relewise Personal Access Token scoped to the Datasets and allowed areas needed for the task.

## Personal Access Token onboarding

After installation, ask the agent **Help me connect Relewise**. The `relewise-setup` skill first checks whether authentication already works and only presents setup or repair instructions when needed.

1. In My Relewise, open **User > Personal Access Tokens**.
2. Create a token and select the smallest practical Dataset scope.
3. Store the value immediately. My Relewise shows it only once.
4. Provide it through the host agent's protected setting or secret environment mechanism. Never put it in a prompt, command argument, repository file, or transcript.
5. Regenerate or revoke the token in My Relewise if it may have been exposed.

See [Personal Access Tokens](https://docs.relewise.com/docs/myrelewise/agent-gateway/personal-access-tokens.html) and [Agent Gateway security and RBAC](https://docs.relewise.com/docs/myrelewise/agent-gateway/security-and-rbac.html).

## Support

- Documentation: https://docs.relewise.com/
- Support: https://docs.relewise.com/docs/support/
- Email: support@relewise.com
- Website: https://www.relewise.com/

## Platform preparation

- [Claude Code](platforms/claude-code.md)
- [GitHub Copilot CLI](platforms/github-copilot.md)
- [OpenAI Codex](platforms/openai-codex.md)
- [Google Gemini CLI](platforms/google-gemini.md)

The platform files record verified publication requirements and the copy or instructions ready for submission. They do not claim that a listing is already public.

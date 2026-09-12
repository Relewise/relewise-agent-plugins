# OpenAI reviewer setup: Relewise

## Account and Dataset

Provide OpenAI with a dedicated Relewise reviewer user through the secure submission channel. The account must be usable without private-network access, second-person approval, or an MFA step that requires Relewise staff during review.

Create or select a non-production review Dataset containing representative:

- Products, Product Variants, Brands, and Categories.
- Search Analytics history covering at least 30 days.
- Consumption history for Search and Recommendations.
- Merchandising rules, including enabled and disabled examples.

Grant only the minimum **Use Agent Gateway** permission and Dataset/area access needed for the test cases. Keep a second Dataset or policy configuration available for the denied-access and disabled-area tests.

## Reviewer flow

1. Install or open the submitted Relewise plugin.
2. Connect the Agent Gateway MCP server at `https://my.relewise.com/agents/mcp`.
3. Complete OAuth sign-in and Connected App consent as the reviewer user.
4. Run the positive and negative cases in `test-cases.md`.
5. Revoke the Connected App and repeat the authentication-failure case.

## Security notes

- No PAT is required for the OAuth MCP path.
- Never include PATs, OAuth client secrets, refresh tokens, or customer data in this repository or submission text.
- Agent Gateway evaluates user permissions, Dataset policy, areas, and connection method for every request.
- Relewise request logs and the AI host's own data-handling terms apply.

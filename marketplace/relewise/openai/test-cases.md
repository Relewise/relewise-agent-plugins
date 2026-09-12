# OpenAI reviewer test cases: Relewise

Use the dedicated reviewer account and sample Dataset supplied through OpenAI's secure submission process. Do not commit credentials here.

## Positive cases

1. **Connect and discover Datasets**
   - Prompt: `Help me connect Relewise, then show my accessible Datasets.`
   - Expected: OAuth consent completes; the agent calls `get_me` and lists only Datasets permitted for the reviewer.

2. **Review search performance**
   - Prompt: `Review search performance for Dataset <review-dataset> for the last 30 days.`
   - Expected: The agent uses the applicable search analytics tools and presents KPIs with the requested date range.

3. **Inspect an entity**
   - Prompt: `Find the Product named <sample-product> and show its stored properties.`
   - Expected: The agent discovers the Product, then uses the entity lookup tool without guessing IDs.

4. **Review merchandising configuration**
   - Prompt: `Audit the merchandising rules for Dataset <review-dataset> and identify conflicts or gaps.`
   - Expected: The agent lists and evaluates existing rules without changing them.

5. **Review consumption**
   - Prompt: `Show Search and Recommendations consumption for Dataset <review-dataset> for the last 30 days.`
   - Expected: The agent returns the relevant consumption summaries and clearly labels the period and Dataset.

## Negative cases

1. **Dataset access denied**
   - Prompt: `Inspect Dataset <dataset-without-access>.`
   - Expected: The request is denied; the agent does not retry through another transport or claim access.

2. **Connection method or area disabled**
   - Prompt: `Review analytics for Dataset <mcp-disabled-or-area-disabled-dataset>.`
   - Expected: The agent explains that the configured Agent Gateway policy does not allow the requested connection or area.

3. **Revoked authentication**
   - Action: Revoke the reviewer Connected App, then repeat a Dataset request.
   - Expected: The request returns an authentication failure; the agent asks the reviewer to reconnect and never requests or prints a token.

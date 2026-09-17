---
name: relewise-retail-media
metadata:
  relewise-execution-skill: relewise-agent-gateway
description: Inspect and operate Relewise Retail Media advertisers, campaigns, Display Ads, and locations. Use for configuration discovery, serving-readiness questions, and explicitly requested advertiser-state or campaign approval, schedule, and budget changes.
---

# Relewise Retail Media

Before any Agent Gateway call, activate and follow the installed `relewise-agent-gateway` skill from this plugin. Pass it the selected REST operation ID and/or related MCP tool plus validated parameters; do not resolve the CLI, choose a transport, or handle authentication in this domain skill.

## Verify Dataset access

Discover the requested Dataset with `IdentityGetCurrentUser`, then retrieve it with `CoreGetDataset`. Never invent a Dataset ID. Confirm that the effective Agent Gateway policy enables the selected transport and the `RetailMedia` Area before using a Retail Media operation.

If the Dataset is listed but Retail Media is unavailable, distinguish the two possible requirements without guessing which one applies:

- For Agent Gateway policy, follow the setup skill's [Dataset access guidance](../relewise-setup/references/dataset-access.md#dataset-listed-policy-needs-attention). Direct the user or an administrator with **Manage Agent Gateway** permission to the Dataset's **Administration > Agent Gateway** page in [My Relewise](https://my.relewise.com/) to enable the relevant connection method and **Retail Media** Allowed Area.
- If the Dataset does not expose Retail Media capability, explain that Retail Media must first be enabled for that Dataset and direct the user to [My Relewise](https://my.relewise.com/) to contact Relewise about enabling it. Do not present an Agent Gateway Area change as enabling the product capability.

After the user confirms a configuration change, retrieve the Dataset details again and verify the effective policy before continuing.

## Discover configuration

Use list operations to discover identifiers rather than guessing them. Advertiser and Campaign IDs are GUIDs; Display Ad IDs and Location Keys are strings. A Display Ad lookup also requires its owning advertiser. For every paginated list, keep filters stable and request subsequent one-based pages while `pageNumber` is below `pagination.totalPages`; valid `pageSize` values are 10 through 100.

Use the matching get operation for full configuration:

- advertisers: `RetailMediaListAdvertisers`, then `RetailMediaGetAdvertiser`;
- campaigns: `RetailMediaListCampaigns`, then `RetailMediaGetCampaign`;
- Display Ads: `RetailMediaListDisplayAds`, then `RetailMediaGetDisplayAd`;
- locations: `RetailMediaListLocations`, then `RetailMediaGetLocation`.

Parse fields ending in `Json` according to their documented SDK structure and preserve supported polymorphic `$type` metadata. Parse Display Ad Data Value `ValueJson` according to its `Type`. Do not promise lossless preservation of unknown fields or original JSON formatting.

## Update live configuration

`RetailMediaUpdateAdvertiser` and `RetailMediaUpdateCampaign` modify live configuration. Use them only when the user explicitly requests the exact change; inspection, reporting, or recommendations do not authorize mutation.

Before an update:

1. Retrieve the current advertiser or campaign and reject an archived entity.
2. Resolve ambiguity about the Dataset, entity, and intended values.
3. Inspect the selected transport's current update schema.
4. Send only explicitly intended fields. Omitted or `null` outer PATCH values preserve existing values.

Advertiser state accepts `Active` or `Inactive`. Campaign state accepts `Approved` or `Proposed`; approval alone does not guarantee serving because schedule, budget, and eligibility still apply. Supplying a schedule replaces both bounds, and omitted or `null` inner bounds clear them. Supplying a budget replaces CPM and the spending cap; use `type: cpm` and `costPerMille`, while omitted or `null` `maximumTotalCost` removes the cap. A budget uses the campaign's existing monetary unit; never infer a currency. Preserve targeting, conditions, and promotions, including `null` promotions.

After updating, report the Dataset, entity, exact changed fields, and returned state. Do not claim excluded create/delete, location or creative editing, Display Ad Type management, or Quality Score capabilities. For performance analysis or reporting, activate the dedicated `relewise-retail-media-performance-review` skill instead.

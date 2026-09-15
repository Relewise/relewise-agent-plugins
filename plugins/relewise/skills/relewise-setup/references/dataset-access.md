# Dataset access after authentication

Use this guidance when identity succeeds but no Datasets are returned, an expected Dataset is missing, or a selected Dataset's Agent Gateway policy prevents the requested work. Preserve the working authentication method and connection.

## Identify the connection

Read `authentication.method` from `get_me` or `/me` and use `authentication.displayName` when it helps the user locate the credential or Connected App. Use the returned method (`PersonalAccessToken` or `OAuth`) to select the guidance below. When metadata is unavailable, state that the method is unverified and resolve it through identity discovery before giving method-specific instructions.

## No Datasets or an expected Dataset is missing

Count Datasets across all returned Licenses. An empty collection confirms that no candidate Datasets are available through this identity; it does not identify the missing access requirement. For a missing expected Dataset, apply the same guidance while preserving access to the returned candidates.

Say: "You're authenticated with Relewise through [method/display name], but this connection currently lists no Datasets. Dataset access needs attention before we can continue." Ask which Dataset or store the user expects if it is not already clear.

- **PersonalAccessToken:** Link to [PAT Dataset Scope](https://docs.relewise.com/docs/myrelewise/agent-gateway/personal-access-tokens.html#dataset-scope). Guide the user to review the named token in My Relewise and include the intended Dataset in its scope. Explain No Datasets, Selected Datasets, or All Datasets only as relevant; prefer the scope needed for the user's work. Let the user make scope changes in My Relewise.
- **OAuth:** Link to [Manage a Connected App](https://docs.relewise.com/docs/myrelewise/agent-gateway/connected-apps.html#manage-a-connection). Guide the user to review Dataset access for the returned application's connection in My Relewise. Access changes apply to existing connections; preserve the current connection while the user adjusts access.

For either method, confirm the intended My Relewise account has Dataset access and **Use Agent Gateway** permission. An Administrator or someone with **Manage Members** can grant the relevant user permission. Link to [Security and Permissions](https://docs.relewise.com/docs/myrelewise/agent-gateway/security-and-permissions.html) when permission assistance is needed. Present these as checks unless the response establishes a specific cause.

After the user confirms access changes, repeat identity discovery through the same authenticated route. Use only returned Dataset IDs for subsequent requests.

## Dataset listed, policy needs attention

Have `relewise-core` retrieve the selected Dataset's details through the Agent Gateway skill and inspect its effective policy or returned access error. Candidate discovery alone establishes neither enabled connection methods nor permission for a capability. Report a missing policy only when the response establishes that; describe disabled methods or Areas precisely when those are the observed restriction.

Link to [Agent Gateway Configuration](https://docs.relewise.com/docs/myrelewise/agent-gateway/configuration.html). Guide the user to select the intended Dataset in My Relewise and open **Administration > Agent Gateway**. A user with **Manage Agent Gateway** can configure it:

- Enable **MCP** for the plugin's MCP connection, or **REST API** for the selected CLI/direct REST route. At least one Connection Method enables Agent Gateway.
- Enable the Allowed Areas needed for the requested task. Core is always enabled; additional Areas depend on the intended capability.

Use a concise response such as: "You're authenticated and [Dataset] is listed, but MCP is disabled for that Dataset. Someone with Manage Agent Gateway permission can enable MCP under Administration > Agent Gateway. Then I can verify access again."

Provide guidance for the relevant setting and let the user or their administrator make the access/policy change. After confirmation, refresh Dataset details and effective policy through the same route before resuming work. Keep the user's authentication choice and the Dataset's policy constraints in force.

## Completion

Report authentication and Dataset readiness separately. With no candidate Datasets, report "Authentication verified; Dataset access pending." With a policy restriction, report "Authentication verified; [Dataset] configuration needs attention." Confirm readiness only for the Dataset, connection method, and Areas actually verified. For a connection-only request without a selected Dataset, say authentication is verified and Dataset readiness remains to be checked.

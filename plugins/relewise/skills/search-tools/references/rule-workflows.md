# Search Tools rule workflows

| Configuration | Discover | Inspect | Modify |
| --- | --- | --- | --- |
| Search Index | `SearchToolsListSearchIndexes` | `SearchToolsGetSearchIndex` | Not available |
| Decompounding | `SearchToolsListDecompoundingRules` | `SearchToolsGetDecompoundingRule` | `SearchToolsPatchDecompoundingRule` |
| Redirect | `SearchToolsListRedirectRules` | `SearchToolsGetRedirectRule` | `SearchToolsPatchRedirectRule` |
| Search Result Modifier | `SearchToolsListSearchResultModifierRules` | `SearchToolsGetSearchResultModifierRule` | `SearchToolsPatchSearchResultModifierRule` |
| Search Term Modifier | `SearchToolsListSearchTermModifierRules` | `SearchToolsGetSearchTermModifierRule` | `SearchToolsPatchSearchTermModifierRule` |
| Stemming | `SearchToolsListStemmingRules` | `SearchToolsGetStemmingRule` | `SearchToolsPatchStemmingRule` |
| Synonym | `SearchToolsListSynonymRules` | Not available | Not available |

List operations return compact or paged summaries. Use the corresponding get operation before reasoning about or changing a selected rule. Synonym get-by-ID and mutation are unavailable until the upstream API supports the unified Search Tools model.

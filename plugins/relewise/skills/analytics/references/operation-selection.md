# Analytics operation selection

| User intent | Operation | Notes |
| --- | --- | --- |
| Revenue totals or trends | `AnalyticsGetRevenue` | Requires an explicit currency; use numeric measurements for calculations. |
| Overall search KPIs and timeline | `AnalyticsGetSearchOverview` | Use for aggregate performance, not term ranking. |
| Highest-volume search terms | `AnalyticsListPopularSearches` | Ranks by search count, regardless of trend. |
| Terms gaining search volume | `AnalyticsListTrendingUpSearches` | Compares the period with its preceding equivalent period. |
| Terms losing search volume | `AnalyticsListTrendingDownSearches` | Compares the period with its preceding equivalent period. |
| Terms returning no results | `AnalyticsListSearchesWithoutResults` | Indicates unmet demand. |
| Terms with results but few clicks | `AnalyticsListLowClickRateSearches` | Indicates weak result engagement, not zero results. |
| Valid search filters | `AnalyticsGetSearchFilterOptions` | Resolve language first; options depend on current selections. |

Search Analytics represents Product Search activity from identified users. Keep that scope visible when interpreting results.


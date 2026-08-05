# Stocks and Banking

*A stock watchlist on the Finnhub API, with Combine driven search and a hand drawn price chart.*

![Swift](https://img.shields.io/badge/Swift-5.0-F05138?style=flat-square&logo=swift&logoColor=white) ![UIKit](https://img.shields.io/badge/UIKit-2396F3?style=flat-square&logo=uikit&logoColor=white) ![iOS](https://img.shields.io/badge/iOS-17.2%2B-000000?style=flat-square&logo=apple&logoColor=white) ![Architecture](https://img.shields.io/badge/architecture-MVVM-6366F1?style=flat-square) ![Dependencies](https://img.shields.io/badge/Charts-16A34A?style=flat-square) ![Dependencies](https://img.shields.io/badge/FloatingPanel-8B5CF6?style=flat-square) ![Dependencies](https://img.shields.io/badge/SDWebImage-8B5CF6?style=flat-square)

## Overview

A persistent watchlist on the main screen, a debounced symbol search, a detail screen with price
history and financial metrics, and a news feed that slides up in a floating panel. Written in code
without storyboards.

## Architecture

```mermaid
flowchart TD
    WL["WatchListViewController"] --> PM["PersistanceManager<br/>watchlist in UserDefaults"]
    WL --> API["APICaller"]
    WL --> SR["SearchResultsViewController"]
    SR --> API
    WL --> FP["FloatingPanel<br/>NewsViewController"]
    FP --> API
    WL --> SD["StockDetailsViewController"]
    SD --> API
    SD --> CHART["StockChartView<br/>Charts"]
    SD --> MET["MetricCollectionViewCell"]
    API --> FH["finnhub.io/api/v1"]
```

## Search pipeline

```mermaid
sequenceDiagram
    participant U as User
    participant SB as UISearchController
    participant WL as WatchListViewController
    participant T as Combine timer
    participant API as APICaller
    participant SR as SearchResultsViewController

    U->>SB: types a query
    SB->>WL: updateSearchResults
    WL->>T: reset the debounce timer
    T-->>WL: fires after the interval
    WL->>API: search(query:)
    API-->>WL: SearchResponse
    WL->>SR: update(results)
    SR-->>U: matching symbols
```

Without the debounce every keystroke would become a request. The timer collapses a burst of typing
into one call, which is the difference between a usable free API tier and an exhausted one.

## Implementation notes

- **Combine as the spine.** The project uses Combine in over sixty places, from the search debounce to
  propagating fetched candles into the chart, rather than passing completion handlers down the stack.
- **Persistence without a database.** `PersistanceManager` stores the watchlist and a first run flag
  in `UserDefaults`, which is the right size of tool for a list of symbols.
- **Chart as a view, not a controller.** `StockChartView` takes a view model of data points and renders
  them, so the same view serves both the watchlist row and the detail header.
- **Layout animated on demand.** `UIViewPropertyAnimator` drives the panel and header transitions,
  which allows them to be reversed mid flight.
- **Formatting once.** Number and date formatters are static, since creating a `DateFormatter` per row
  is a measurable cost in a scrolling table.

## Project structure

```
StocksAndBanking/
├── Managers/       APICaller, PersistanceManager, HapticsManager
├── Models/         SearchResponse, MarketDataResponse, FinancialMetricsResponse, NewsStory
├── Controllers/    WatchList, SearchResults, StockDetails, News
├── Views/          StockChartView, StockDetailHeaderView, cells for watchlist, news and metrics
└── Others/         shared extensions and formatters
```

## Requirements

Xcode 15 or later, iOS 17.2 or later, CocoaPods for FloatingPanel, Charts and SDWebImage. A Finnhub
API key is required.

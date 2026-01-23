//
//  SearchResultsView.swift
//  Ferrite
//
//  Created by Brian Dashore on 3/28/23.
//

import SwiftUI

struct SearchResultsView: View {
    @Environment(\.esIsSearching) var isSearching
    @Environment(\.esDismissSearch) var dismissSearch

    @EnvironmentObject var scrapingModel: ScrapingViewModel
    @EnvironmentObject var navModel: NavigationViewModel
    @EnvironmentObject var pluginManager: PluginManager
    @EnvironmentObject var debridManager: DebridManager

    @AppStorage("Behavior.UsesRandomSearchText") var usesRandomSearchText: Bool = false

    @Binding var searchText: String

    var body: some View {
        let sortedResults = scrapingModel.searchResults.sorted { lhs, rhs in
            if navModel.currentSortFilter == .best {
                let lhsScore = bestScore(for: lhs)
                let rhsScore = bestScore(for: rhs)
                return navModel.currentSortOrder == .forward ? lhsScore > rhsScore : lhsScore < rhsScore
            }

            return navModel.compareSearchResult(lhs: lhs, rhs: rhs)
        }

        ForEach(sortedResults, id: \.self) { result in
            let debridIAStatus = debridManager.matchMagnetHash(result.magnet)
            if
                pluginManager.filteredInstalledSources.isEmpty ||
                pluginManager.filteredInstalledSources.contains(where: { result.source == $0.name }),
                debridManager.filteredIAStatus.isEmpty ||
                debridManager.filteredIAStatus.contains(debridIAStatus)
            {
                SearchResultButtonView(result: result)
            }
        }
        .onChange(of: searchText) { newText in
            if newText.isEmpty, isSearching {
                navModel.getSearchPrompt()
            }
        }
        .onChange(of: navModel.selectedTab) { tab in
            // Cancel the search if tab is switched while search is in progress
            if tab != .search, scrapingModel.runningSearchTask != nil {
                scrapingModel.searchResults = []
                scrapingModel.runningSearchTask?.cancel()
                scrapingModel.runningSearchTask = nil
                dismissSearch()
            }
        }
        .onChange(of: scrapingModel.searchResults) { _ in
            // Cleans up any leftover search results in the event of an abrupt cancellation
            if !isSearching {
                scrapingModel.searchResults = []
            }
        }
        .onChange(of: isSearching) { newValue in
            if !newValue {
                scrapingModel.searchResults = []
                scrapingModel.runningSearchTask?.cancel()
                scrapingModel.runningSearchTask = nil
            }
        }
    }

    private func bestScore(for result: SearchResult) -> Double {
        let iaStatus = debridManager.matchMagnetHash(result.magnet)
        let cacheScore: Double
        switch iaStatus {
        case .full:
            cacheScore = 2
        case .partial:
            cacheScore = 1
        case .none:
            cacheScore = 0
        }

        let seedersScore = Double(result.seeders ?? "") ?? 0
        let sizeScore = result.rawSize() ?? 0

        return (cacheScore * 1_000_000) + (seedersScore * 1000) + sizeScore
    }
}

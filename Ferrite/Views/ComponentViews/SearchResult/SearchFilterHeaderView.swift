//
//  SearchFilterHeaderView.swift
//  Ferrite
//
//  Created by Brian Dashore on 2/13/23.
//

import SwiftUI

struct SearchFilterHeaderView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass

    @EnvironmentObject var debridManager: DebridManager
    @EnvironmentObject var pluginManager: PluginManager
    @EnvironmentObject var navModel: NavigationViewModel

    private var horizontalInset: CGFloat {
        verticalSizeClass == .compact ? DesignTokens.Spacing.xlarge : DesignTokens.Spacing.large
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.small) {
                // MARK: - Current filters

                if !navModel.enabledFilters.isEmpty {
                    Menu {
                        Button("Clear filters", role: .destructive) {
                            navModel.enabledFilters = []
                        }
                    } label: {
                        HStack(spacing: DesignTokens.Spacing.tiny) {
                            Image(systemName: "line.3.horizontal.decrease")
                                .foregroundStyle(.primary)
                                .symbolRenderingMode(.hierarchical)

                            FilterAmountLabelView(amount: navModel.enabledFilters.count)
                        }
                        .padding(.horizontal, DesignTokens.Spacing.medium)
                        .padding(.vertical, DesignTokens.Spacing.small)
                        .frame(minHeight: DesignTokens.Interactive.minTapTarget)
                        .font(.caption.weight(.medium))
                        .liquidGlassPill(tint: Color.primary.opacity(0.03), shadow: false)
                    }
                    .buttonStyle(.plain)

                    Rectangle()
                        .fill(Color.secondary.opacity(0.18))
                        .frame(width: 1, height: DesignTokens.Interactive.minTapTarget - 12)
                }

                // MARK: - Source filter picker

                SourceFilterView()

                // MARK: - Selected debrid picker

                DebridServiceToggle()

                // MARK: - Cache status picker

                if !debridManager.enabledDebrids.isEmpty {
                    IAFilterView()
                }

                // MARK: - Sort filter picker

                SortFilterView()
            }
            .padding(.horizontal, horizontalInset)
            .padding(.vertical, DesignTokens.Spacing.tiny)
            .animation(.easeInOut, value: navModel.enabledFilters)
        }
    }
}

//
//  SearchResultInfoView.swift
//  Ferrite
//
//  Created by Brian Dashore on 7/26/22.
//

import SwiftUI

struct SearchResultInfoView: View {
    @EnvironmentObject var debridManager: DebridManager

    var result: SearchResult

    var body: some View {
        ViewThatFits(in: .horizontal) {
            infoRow

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                primaryMetadata
                secondaryMetadata
            }
        }
    }

    private var infoRow: some View {
        HStack(alignment: .center, spacing: DesignTokens.Spacing.medium) {
            primaryMetadata

            Spacer(minLength: DesignTokens.Spacing.medium)

            secondaryMetadata
        }
        .font(.caption2)
    }

    private var primaryMetadata: some View {
        HStack(spacing: DesignTokens.Spacing.small) {
            Text(result.source)
                .foregroundStyle(.secondary)

            if let size = result.size {
                metadataLabel(size, emphasis: .standard)
            }
        }
    }

    private var secondaryMetadata: some View {
        HStack(spacing: DesignTokens.Spacing.small) {
            if let seeders = result.seeders {
                metadataLabel("S: \(seeders)", emphasis: seeders > 0 ? .positive : .muted)
            }

            if let leechers = result.leechers {
                metadataLabel("L: \(leechers)", emphasis: .muted)
            }

            if let debridSource = debridManager.selectedDebridSource {
                DebridLabelView(debridSource: debridSource, magnet: result.magnet)
            }
        }
    }

    @ViewBuilder
    private func metadataLabel(_ text: String, emphasis: MetadataEmphasis) -> some View {
        Text(text)
            .foregroundStyle(emphasis.color)
            .font(.caption2.weight(emphasis == .positive ? .medium : .regular))
    }

    private enum MetadataEmphasis: Equatable {
        case standard
        case positive
        case muted

        var color: some ShapeStyle {
            switch self {
            case .standard:
                return Color.secondary
            case .positive:
                return Color.green.opacity(0.9)
            case .muted:
                return Color.tertiary
            }
        }
    }
}

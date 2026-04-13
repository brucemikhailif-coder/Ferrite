//
//  HistoryButtonView.swift
//  Ferrite
//
//  Created by Brian Dashore on 9/9/22.
//

import SwiftUI

struct HistoryButtonView: View {
    @EnvironmentObject var logManager: LoggingManager
    @EnvironmentObject var navModel: NavigationViewModel
    @EnvironmentObject var debridManager: DebridManager

    let entry: HistoryEntry

    var body: some View {
        Button {
            navModel.selectedTitle = entry.name ?? ""
            navModel.selectedBatchTitle = entry.subName ?? ""

            if let url = entry.url {
                if url.starts(with: "magnet:") {
                    navModel.selectedMagnet = Magnet(hash: nil, link: url)
                    navModel.resultFromCloud = false
                } else {
                    navModel.selectedMagnet = nil
                    debridManager.downloadUrl = url
                    navModel.resultFromCloud = true
                }

                navModel.currentChoiceSheet = .action
            } else {
                logManager.error(
                    "History: URL for name \(String(describing: entry.name)) is invalid",
                    description: "URL invalid. Cannot load this history entry. Please delete it."
                )
            }
        } label: {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.tiny) {
                    Text(entry.name ?? "Unknown title")
                        .font(DesignTokens.Typography.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(entry.subName == nil ? 2 : 1)

                    if let subName = entry.subName {
                        Text(subName)
                            .foregroundStyle(.secondary)
                            .font(DesignTokens.Typography.body)
                            .lineLimit(2)
                    }
                }

                HStack(alignment: .center, spacing: DesignTokens.Spacing.medium) {
                    Text(entry.source ?? "Unknown source")
                        .foregroundStyle(.secondary)
                        .font(DesignTokens.Typography.caption)

                    Spacer(minLength: DesignTokens.Spacing.medium)

                    statusBadge

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                        .symbolRenderingMode(.hierarchical)
                }
            }
            .padding(DesignTokens.Spacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .liquidGlassCard(interactive: true)
            .disabledAppearance(navModel.currentChoiceSheet != nil, dimmedOpacity: 0.7, animation: .easeOut(duration: 0.2))
        }
        .buttonStyle(.plain)
        .tint(.primary)
        .disableInteraction(navModel.currentChoiceSheet != nil)
    }

    private var isDirectLink: Bool {
        guard let url = entry.url?.lowercased() else {
            return false
        }

        return url.hasPrefix("https://") || url.hasPrefix("http://")
    }

    private var statusBadge: some View {
        Text(isDirectLink ? "Link" : "Magnet")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.primary)
            .padding(.horizontal, DesignTokens.Spacing.small)
            .padding(.vertical, DesignTokens.Spacing.tiny + 1)
            .liquidGlassPill(
                tint: (isDirectLink ? Color.green : Color.red).opacity(0.2),
                shadow: false
            )
    }
}

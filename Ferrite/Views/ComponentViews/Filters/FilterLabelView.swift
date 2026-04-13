//
//  FilterLabelView.swift
//  Ferrite
//
//  Created by Brian Dashore on 2/12/23.
//

import SwiftUI

struct FilterLabelView: View {
    var name: String?
    var fallbackName: String
    var count: Int?

    private var isActive: Bool {
        (count ?? 0) > 0
    }

    private var displayName: String {
        (count ?? 1) == 1 ? (name ?? fallbackName) : fallbackName
    }

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.tiny) {
            if let count, count > 1 {
                FilterAmountLabelView(amount: count)
            }

            Text(displayName)
                .lineLimit(1)
                .foregroundStyle(isActive ? .primary : .secondary)
                .fontWeight(isActive ? .semibold : .medium)

            Image(systemName: "chevron.down")
                .font(.caption2.weight(.bold))
                .foregroundStyle(isActive ? .accent : .tertiary)
                .symbolRenderingMode(.hierarchical)
        }
        .padding(.horizontal, DesignTokens.Spacing.medium)
        .padding(.vertical, DesignTokens.Spacing.small)
        .frame(minHeight: DesignTokens.Interactive.minTapTarget)
        .font(.caption)
        .liquidGlassPill(
            tint: isActive ? Color.accentColor.opacity(0.16) : Color.primary.opacity(0.03),
            shadow: false
        )
        .contentShape(Capsule())
    }
}

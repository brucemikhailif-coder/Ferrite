//
//  GlassTabBarView.swift
//  Ferrite
//
//  Created by Brian Dashore on 1/24/26.
//

import SwiftUI
import UIKit

struct GlassTabBarView: View {
    @Binding var selection: NavigationViewModel.ViewTab

    private let tabs: [(NavigationViewModel.ViewTab, String, String)] = [
        (.search, "Search", "magnifyingglass"),
        (.library, "Library", "book.closed"),
        (.add, "Download", "plus.circle"),
        (.settings, "Settings", "gear")
    ]

    var body: some View {
        HStack(spacing: DesignTokens.TabBar.itemSpacing) {
            ForEach(tabs, id: \.0) { tab in
                let isSelected = selection == tab.0

                Button {
                    let generator = UISelectionFeedbackGenerator()
                    generator.selectionChanged()

                    withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                        selection = tab.0
                    }
                } label: {
                    VStack(spacing: DesignTokens.Spacing.tiny) {
                        Image(systemName: tab.2)
                            .font(.system(size: DesignTokens.IconSize.medium, weight: isSelected ? .medium : .regular))
                            .symbolRenderingMode(.hierarchical)

                        Text(tab.1)
                            .font(.caption2)
                            .fontWeight(isSelected ? .medium : .regular)
                    }
                    .foregroundStyle(isSelected ? .primary : .secondary)
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.Interactive.minTapTarget)
                    .background {
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large, style: .continuous)
                            .fill(isSelected ? Color.primary.opacity(0.06) : .clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large, style: .continuous)
                                    .stroke(isSelected ? Color.primary.opacity(0.06) : .clear, lineWidth: DesignTokens.Stroke.ultraThin)
                            )
                            .shadow(
                                color: isSelected ? Color.black.opacity(0.015) : .clear,
                                radius: DesignTokens.Shadow.subtle.radius,
                                x: 0,
                                y: DesignTokens.Shadow.subtle.y
                            )
                    }
                    .contentShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large, style: .continuous))
                }
                .buttonStyle(PressableButtonStyle(scaleAmount: 0.97, opacityAmount: 0.98))
                .accessibilityElement(children: .combine)
                .accessibilityLabel(tab.1)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(DesignTokens.Spacing.small)
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.pill, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.pill, style: .continuous)
                        .stroke(Color.primary.opacity(0.05), lineWidth: DesignTokens.Stroke.ultraThin)
                )
                .shadow(
                    color: DesignTokens.Shadow.subtle.color,
                    radius: DesignTokens.Shadow.subtle.radius,
                    x: 0,
                    y: DesignTokens.Shadow.subtle.y
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.pill, style: .continuous))
    }
}

struct GlassTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        GlassTabBarView(selection: .constant(.search))
            .padding()
    }
}

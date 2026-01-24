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
        (.add, "Add", "plus.circle"),
        (.settings, "Settings", "gear")
    ]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(tabs, id: \.0) { tab in
                Button {
                    // subtle haptic feedback on selection
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selection = tab.0
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.2)
                            .font(.system(size: 18, weight: .semibold))
                        Text(tab.1)
                            .font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignTokens.Spacing.small)
                }
                .tint(selection == tab.0 ? .primary : .secondary)
                .background(
                    Group {
                        if selection == tab.0 {
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium)
                                .fill(Color.accentColor.opacity(0.18))
                                .overlay(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium).stroke(Color.accentColor.opacity(0.22), lineWidth: DesignTokens.Stroke.ultraThin))
                        } else {
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium)
                                .fill(.ultraThinMaterial)
                                .overlay(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium).stroke(Color.primary.opacity(0.02), lineWidth: DesignTokens.Stroke.ultraThin))
                        }
                    }
                )
                .contentShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium))
            }
        }
        .padding(DesignTokens.Spacing.small)
        .liquidGlass(cornerRadius: DesignTokens.CornerRadius.pill)
    }
}

struct GlassTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        GlassTabBarView(selection: .constant(.search))
    }
}

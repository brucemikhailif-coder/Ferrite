//
//  GlassTabBarView.swift
//  Ferrite
//
//  Created by Brian Dashore on 1/24/26.
//

import SwiftUI

struct GlassTabBarView: View {
    @Binding var selection: NavigationViewModel.ViewTab

    private let tabs: [(NavigationViewModel.ViewTab, String, String)] = [
        (.search, "Search", "magnifyingglass"),
        (.library, "Library", "book.closed"),
        (.add, "Add", "plus.circle"),
        (.plugins, "Plugins", "doc.text"),
        (.settings, "Settings", "gear")
    ]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(tabs, id: \.0) { tab in
                Button {
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
                    .padding(.vertical, 8)
                }
                .tint(selection == tab.0 ? .primary : .secondary)
                .liquidGlass(cornerRadius: 14, tint: selection == tab.0 ? .accentColor.opacity(0.25) : nil, interactive: true)
            }
        }
        .padding(8)
        .liquidGlass(cornerRadius: 20)
    }
}

struct GlassTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        GlassTabBarView(selection: .constant(.search))
    }
}

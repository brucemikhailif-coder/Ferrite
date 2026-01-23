//
//  FilterLabelView.swift
//  Ferrite
//
//  Created by Brian Dashore on 2/12/23.
//

import SwiftUI

struct FilterLabelView: View {
    @Environment(\.colorScheme) var colorScheme

    var name: String?
    var fallbackName: String
    var count: Int?

    var body: some View {
        HStack(spacing: 4) {
            if let count, count > 1 {
                FilterAmountLabelView(amount: count)
            }

            Text(count ?? 1 == 1 ? name ?? fallbackName : fallbackName)
                .opacity(count ?? 0 > 0 ? 1 : 0.6)
                .foregroundColor(count ?? 0 > 0 && colorScheme == .light ? .accentColor : .primary)

            Image(systemName: "chevron.down")
                .foregroundColor(count ?? 0 > 0 ? (colorScheme == .light ? .accentColor : .primary) : .init(uiColor: .tertiaryLabel))
        }
        .padding(.horizontal, 9)
        .padding(.vertical, count ?? 1 > 1 ? 2 : 7)
        .font(
            .caption
                .weight(.medium)
        )
        .liquidGlass(
            cornerRadius: 999,
            tint: count ?? 0 > 0 ? .accentColor.opacity(0.25) : nil,
            interactive: true
        )
    }
}

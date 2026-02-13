//
//  FilterAmountLabelView.swift
//  Ferrite
//
//  Created by Brian Dashore on 4/11/23.
//

import SwiftUI

struct FilterAmountLabelView: View {
    @Environment(\.colorScheme) var colorScheme

    var amount: Int

    var body: some View {
        Text(String(amount))
            .padding(.horizontal, DesignTokens.Spacing.small)
            .padding(.vertical, DesignTokens.Spacing.tiny)
            .foregroundColor(colorScheme == .light ? .white : .accentColor)
            .liquidGlassPill(
                tint: colorScheme == .light ? Color.accentColor.opacity(0.22) : Color.white.opacity(0.16),
                shadow: false
            )
    }
}

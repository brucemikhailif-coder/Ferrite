//
//  Tag.swift
//  Ferrite
//
//  Created by Brian Dashore on 2/7/23.
//

import SwiftUI

struct Tag: View {
    let name: String
    let color: Color?
    var horizontalPadding: CGFloat = 7
    var verticalPadding: CGFloat = 4

    var body: some View {
        Text(name.capitalizingFirstLetter())
            .font(.caption.weight(.medium))
            .foregroundStyle(.primary)
            .lineLimit(1)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .liquidGlassPill(
                tint: (color ?? Color(uiColor: .tertiaryLabel)).opacity(0.15),
                shadow: false
            )
            .accessibilityLabel(Text(name.capitalizingFirstLetter()))
    }
}

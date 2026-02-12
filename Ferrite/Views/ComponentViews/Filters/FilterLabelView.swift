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

    // Pressed state for subtle feedback on touch
    @State private var isPressed: Bool = false

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
        .liquidGlassPill(
            tint: count ?? 0 > 0 ? Color.accentColor.opacity(0.1) : nil,
            shadow: false
        )
        // Subtle pressed feedback
        .scaleEffect(isPressed ? 0.98 : 1)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isPressed)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

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
            .padding(DesignTokens.Spacing.small)
            .foregroundColor(colorScheme == .light ? .white : .accentColor)
            .background {
                Circle()
                    .foregroundColor(colorScheme == .light ? .accentColor : .white)
            }
    }
}

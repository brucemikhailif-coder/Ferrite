//
//  EmptyInstructionView.swift
//  Ferrite
//
//  Created by Brian Dashore on 9/5/22.
//

import SwiftUI

struct EmptyInstructionView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 24, weight: .semibold))

            Text(title)
                .font(.system(size: 22, weight: .semibold))

            Text(message)
                .padding(.horizontal, DesignTokens.Spacing.xlarge * 2)
                .font(.footnote)
        }
        .multilineTextAlignment(.center)
        .foregroundColor(.init(uiColor: .secondaryLabel))
        .padding(DesignTokens.Spacing.xlarge)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large))
        .overlay(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large).stroke(Color.primary.opacity(0.04), lineWidth: DesignTokens.Stroke.ultraThin))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

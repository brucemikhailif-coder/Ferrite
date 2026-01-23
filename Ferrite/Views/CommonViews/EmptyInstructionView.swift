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
                .padding(.horizontal, 50)
                .font(.footnote)
        }
        .multilineTextAlignment(.center)
        .foregroundColor(.init(uiColor: .secondaryLabel))
        .padding(20)
        .liquidGlass(cornerRadius: 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

//
//  SectionHeaderView.swift
//  Ferrite
//
//  Created by Brian Dashore on 2/15/23.
//

import SwiftUI

struct SectionHeaderView: View {
    let title: LocalizedStringKey
    var subtitle: LocalizedStringKey?

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.tiny) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)

            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .textCase(.none)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, DesignTokens.Spacing.tiny)
    }
}

struct SectionHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SectionHeaderView(title: "Section", subtitle: "Optional supporting context")
    }
}

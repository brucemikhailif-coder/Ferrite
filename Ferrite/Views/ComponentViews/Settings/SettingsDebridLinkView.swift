//
//  SettingsDebridLinkView.swift
//  Ferrite
//
//  Created by Brian Dashore on 11/27/24.
//

import SwiftUI

struct SettingsDebridLinkView: View {
    var debridSource: DebridSource

    // TODO: Use a roundabout state for now
    @State private var isLoggedIn = false

    var body: some View {
        NavigationLink {
            SettingsDebridInfoView(debridSource: debridSource)
        } label: {
            HStack {
                Text(debridSource.id)
                Spacer()
                Text(isLoggedIn ? "Enabled" : "Disabled")
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            isLoggedIn = debridSource.isLoggedIn
        }
    }
}

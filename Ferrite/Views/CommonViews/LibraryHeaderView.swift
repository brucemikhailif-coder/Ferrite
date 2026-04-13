//
//  LibraryHeaderView.swift
//  Ferrite
//
//  Created by Brian Dashore on 2/12/23.
//

import SwiftUI

struct LibraryHeaderView: View {
    @EnvironmentObject var debridManager: DebridManager

    @Binding var selectedSegment: NavigationViewModel.LibraryPickerSegment

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            SectionHeaderView(
                title: "Browse",
                subtitle: debridManager.enabledDebrids.isEmpty
                    ? "History is available. Cloud browsing requires an enabled debrid service."
                    : "Switch between history and cloud content."
            )

            Picker("Library View", selection: $selectedSegment) {
                Text("History").tag(NavigationViewModel.LibraryPickerSegment.history)

                if !debridManager.enabledDebrids.isEmpty {
                    Text("Cloud").tag(NavigationViewModel.LibraryPickerSegment.debridCloud)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal, DesignTokens.Spacing.large)
        .padding(.vertical, DesignTokens.Spacing.small)
    }
}

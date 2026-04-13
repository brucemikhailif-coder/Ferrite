//
//  LibraryPickerView.swift
//  Ferrite
//
//  Created by Brian Dashore on 2/13/23.
//

import SwiftUI

struct LibraryPickerView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass

    @EnvironmentObject var debridManager: DebridManager
    @EnvironmentObject var navModel: NavigationViewModel

    var body: some View {
        let horizontalInset: CGFloat = verticalSizeClass == .compact && UIDevice.current.hasNotch ? 47 : 0
        return LibraryHeaderView(selectedSegment: $navModel.libraryPickerSelection)
            .padding(.horizontal, horizontalInset)
    }
}

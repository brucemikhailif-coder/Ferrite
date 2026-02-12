//
//  KeyboardObserver.swift
//  Ferrite
//
//  Created by AI assistant on behalf of the user.
//

import Combine
import UIKit

final class KeyboardObserver: ObservableObject {
    @Published var isVisible: Bool = false
    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { _ in true }
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification).map { _ in false })
            .receive(on: RunLoop.main)
            .sink { [weak self] isVisible in
                self?.isVisible = isVisible
            }
            .store(in: &cancellables)
    }
}

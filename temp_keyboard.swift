//
//  Keyboard.swift
//  Ferrite
//
//  Created by AI assistant on behalf of the user.
//  Purpose: Keyboard observer utility to report keyboard height and visibility.
//

import SwiftUI
import Combine
import UIKit

/// Observes global keyboard notifications and publishes the current keyboard height and visibility.
/// - Publishes `height` which is the keyboard's vertical size (0 when hidden).
/// - Publishes `isVisible` which is true when keyboard is shown.
final class KeyboardObserver: ObservableObject {
    /// Current keyboard height in points (0 when hidden).
    @Published public private(set) var height: CGFloat = 0

    /// Whether the keyboard is visible.
    @Published public private(set) var isVisible: Bool = false

    private var cancellables = Set<AnyCancellable>()

    /// Initialize and start observing keyboard notifications.
    init() {
        // keyboardWillShow -> produce height and duration
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo }
            .map { info -> (height: CGFloat, duration: Double, curve: UInt) in
                let frame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? .zero
                let height = frame.height
                let duration = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
                let curve = (info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt) ?? 0
                return (height: height, duration: duration, curve: curve)
            }

        // keyboardWillHide -> emit zero height
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ -> (height: CGFloat, duration: Double, curve: UInt) in
                (height: 0, duration: 0.25, curve: 0)
            }

        Publishers.Merge(willShow, willHide)
            .receive(on: RunLoop.main)
            .sink { [weak self] info in
                guard let self = self else { return }
                // Animate updates to match keyboard animation timing for smoother UI adjustments
                // Use UIView animation curve if available for close match to system animation
                let animationOptions: UIView.AnimationOptions
                if info.curve != 0 {
                    animationOptions = UIView.AnimationOptions(rawValue: info.curve << 16)
                } else {
                    animationOptions = [.curveEaseOut]
                }

                UIView.animate(withDuration: info.duration, delay: 0, options: animationOptions, animations: {
                    self.height = info.height
                    self.isVisible = info.height > 0
                }, completion: nil)
            }
            .store(in: &cancellables)
    }

    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}

//
//  View.swift
//  Ferrite
//
//  Created by Brian Dashore on 8/15/22.
//

import SwiftUI

extension View {
    // Modifies properties of a view. Works the same way as a ViewModifier
    // From: https://github.com/SwiftUIX/SwiftUIX/blob/master/Sources/Intermodular/Extensions/SwiftUI/View%2B%2B.swift#L10
    func modifyViewProp(_ body: (inout Self) -> Void) -> Self {
        var result = self
        body(&result)

        return result
    }

    // MARK: Modifiers

    func disabledAppearance(_ disabled: Bool, dimmedOpacity: Double? = nil, animation: Animation? = nil) -> some View {
        modifier(DisabledAppearanceModifier(disabled: disabled, dimmedOpacity: dimmedOpacity, animation: animation))
    }

    func disableInteraction(_ disabled: Bool) -> some View {
        modifier(DisableInteractionModifier(disabled: disabled))
    }

    func inlinedList(inset: CGFloat) -> some View {
        modifier(InlinedListModifier(inset: inset))
    }

    @ViewBuilder
    func liquidGlass(
        cornerRadius: CGFloat = DesignTokens.CornerRadius.medium,
        tint: Color? = nil,
        interactive: Bool = false,
        shadow: Bool = true,
        stroke: Bool = true
    ) -> some View {
        if #available(iOS 26.0, *) {
            Group {
                if let tint {
                    if interactive {
                        glassEffect(.regular.tint(tint).interactive(), in: .rect(cornerRadius: cornerRadius))
                    } else {
                        glassEffect(.regular.tint(tint), in: .rect(cornerRadius: cornerRadius))
                    }
                } else if interactive {
                    glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
                } else {
                    glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.primary.opacity(0.06), lineWidth: stroke ? DesignTokens.Stroke.ultraThin : 0)
                    .blendMode(.overlay)
            )
            .overlay(
                // subtle top-left highlight to imply depth
                LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.06), Color.white.opacity(0.01)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .allowsHitTesting(false)
            )
            .shadow(
                color: shadow ? DesignTokens.Shadow.subtle.color : .clear,
                radius: shadow ? DesignTokens.Shadow.subtle.radius : 0,
                x: 0,
                y: shadow ? DesignTokens.Shadow.subtle.y : 0
            )
        } else {
            background(.ultraThinMaterial)
                .cornerRadius(cornerRadius)
                .overlay(RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.primary.opacity(0.04), lineWidth: stroke ? DesignTokens.Stroke.ultraThin : 0))
                .shadow(
                    color: shadow ? DesignTokens.Shadow.subtle.color : .clear,
                    radius: shadow ? DesignTokens.Shadow.subtle.radius : 0,
                    x: 0,
                    y: shadow ? DesignTokens.Shadow.subtle.y : 0
                )
        }
    }

    // MARK: - Semantic Style Wrappers for liquidGlass

    /// Card-style liquid glass with medium corner radius
    func liquidGlassCard(
        tint: Color? = nil,
        interactive: Bool = false,
        shadow: Bool = true,
        stroke: Bool = true
    ) -> some View {
        liquidGlass(cornerRadius: DesignTokens.CornerRadius.medium, tint: tint, interactive: interactive, shadow: shadow, stroke: stroke)
    }

    /// Pill-style liquid glass with fully rounded corners
    func liquidGlassPill(
        tint: Color? = nil,
        interactive: Bool = false,
        shadow: Bool = true,
        stroke: Bool = true
    ) -> some View {
        liquidGlass(cornerRadius: DesignTokens.CornerRadius.pill, tint: tint, interactive: interactive, shadow: shadow, stroke: stroke)
    }

    /// Toast-style liquid glass with small corner radius
    func liquidGlassToast(
        tint: Color? = nil,
        interactive: Bool = false,
        shadow: Bool = true,
        stroke: Bool = true
    ) -> some View {
        liquidGlass(cornerRadius: DesignTokens.CornerRadius.small, tint: tint, interactive: interactive, shadow: shadow, stroke: stroke)
    }
}

// MARK: - PressableButtonStyle
struct PressableButtonStyle: ButtonStyle {
    var scaleAmount: CGFloat = 0.98
    var opacityAmount: Double = 0.96

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            .opacity(configuration.isPressed ? opacityAmount : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

// MARK: - Cardify extension
extension View {
    @ViewBuilder
    func cardify(
        cornerRadius: CGFloat = DesignTokens.CornerRadius.medium,
        padding: CGFloat = DesignTokens.Spacing.medium,
        shadow: Bool = true,
        strokeOpacity: Double = 0.04
    ) -> some View {
        self
            .padding(padding)
            .liquidGlass(cornerRadius: cornerRadius, shadow: shadow, stroke: strokeOpacity > 0)
    }

    func applyPressableButtonStyle(scaleAmount: CGFloat = 0.98, opacityAmount: Double = 0.96) -> some View {
        self.buttonStyle(PressableButtonStyle(scaleAmount: scaleAmount, opacityAmount: opacityAmount))
    }
}

//
//  DesignTokens.swift
//  Ferrite
//
//  Centralized design tokens following SwiftUI design principles
//

import SwiftUI

/// Centralized design tokens for the Ferrite app.
///
/// Use these tokens to keep spacing, corner radii, typography, and colors consistent
/// across the codebase. Avoid hard-coded numbers in views; reference these tokens instead.
enum DesignTokens {
    // MARK: - Spacing System (Base-4/Base-8 Grid)
    
    enum Spacing {
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 20
        static let xxlarge: CGFloat = 24
        static let xxxlarge: CGFloat = 32
        static let huge: CGFloat = 40
        static let massive: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    
    enum CornerRadius {
        static let micro: CGFloat = 6
        static let small: CGFloat = 8
        static let medium: CGFloat = 10  // iOS standard for cards
        static let large: CGFloat = 12
        static let xlarge: CGFloat = 16
        static let pill: CGFloat = 999
    }
    
    // MARK: - Stroke Width
    
    enum Stroke {
        static let ultraThin: CGFloat = 0.5
        static let thin: CGFloat = 1.0
        static let medium: CGFloat = 2.0
        static let thick: CGFloat = 3.0
    }
    
    // MARK: - Shadow
    
    enum Shadow {
        static let subtle = ShadowSpec(radius: 2, y: 1, color: Color.black.opacity(0.02))
        static let medium = ShadowSpec(radius: 4, y: 2, color: Color.black.opacity(0.04))
        static let prominent = ShadowSpec(radius: 8, y: 4, color: Color.black.opacity(0.06))
        
        struct ShadowSpec {
            let radius: CGFloat
            let y: CGFloat
            let color: Color
        }
    }
    
    // MARK: - Tab Bar
    
    enum TabBar {
        static let height: CGFloat = 60
        static let horizontalPadding: CGFloat = 16
        static let bottomPadding: CGFloat = 8
        static let itemSpacing: CGFloat = 8
    }
    
    // MARK: - Typography (Limited to 6 distinct sizes for clear hierarchy)
    
    enum Typography {
        static let hero: Font = .system(size: 36, weight: .light, design: .default)
        static let title: Font = .system(size: 24, weight: .semibold, design: .default)
        static let headline: Font = .system(size: 17, weight: .semibold, design: .default)
        static let body: Font = .system(size: 15, weight: .regular, design: .default)
        static let caption: Font = .system(size: 13, weight: .regular, design: .default)
        static let label: Font = .system(size: 11, weight: .medium, design: .default)
        
        // Letter spacing for uppercase labels
        static let labelTracking: CGFloat = 1.5
        static let titleTracking: CGFloat = 0.5
    }
    
    // MARK: - Icon Sizes
    
    enum IconSize {
        static let small: CGFloat = 14
        static let medium: CGFloat = 18
        static let large: CGFloat = 22
        static let xlarge: CGFloat = 28
    }
    
    // MARK: - Interactive Elements
    
    enum Interactive {
        static let minTapTarget: CGFloat = 44
        static let buttonHeight: CGFloat = 48
        static let toggleRowPadding: CGFloat = 12
    }
}

// MARK: - View Extensions

extension View {
    /// Apply semantic system colors for cards/groups
    func cardBackground() -> some View {
        self
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: DesignTokens.CornerRadius.medium))
    }
    
    /// Standard divider with leading inset
    func standardDivider() -> some View {
        Divider()
            .padding(.leading, DesignTokens.Spacing.large)
    }
}

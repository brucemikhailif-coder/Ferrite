//
//  DebridServiceToggle.swift
//  Ferrite
//
//  Created by Claude Code on 1/24/2026.
//

import SwiftUI

struct DebridServiceToggle: View {
    @EnvironmentObject var debridManager: DebridManager

    // Get logged-in debrid sources
    private var loggedInDebridSources: [DebridSource] {
        debridManager.debridSources.filter { $0.isLoggedIn }
    }

    // Current service abbreviation for display
    private var currentServiceDisplay: String {
        if let selected = debridManager.selectedDebridSource {
            return selected.abbreviation
        }
        return "None"
    }

    // Whether the toggle should be disabled
    private var isDisabled: Bool {
        loggedInDebridSources.isEmpty
    }

    private var isActive: Bool {
        debridManager.selectedDebridSource != nil
    }

    var body: some View {
        Button(action: cycleToNextService) {
            HStack(spacing: DesignTokens.Spacing.tiny) {
                Text(currentServiceDisplay)
                    .font(.caption.weight(isActive ? .semibold : .medium))
                    .foregroundStyle(isDisabled ? .secondary : (isActive ? .primary : .secondary))

            if !isDisabled {
                Image(systemName: "chevron.forward")
                    .font(.caption2)
                    .foregroundStyle(isActive ? Color.accentColor : Color.primary.opacity(0.5))
                    .symbolRenderingMode(.hierarchical)
            }
            }
            .padding(.horizontal, DesignTokens.Spacing.medium)
            .padding(.vertical, DesignTokens.Spacing.small)
            .frame(minHeight: DesignTokens.Interactive.minTapTarget)
            .liquidGlassPill(
                tint: isDisabled ? nil : (isActive ? Color.accentColor.opacity(0.16) : Color.primary.opacity(0.03)),
                shadow: false
            )
        }
        .disabled(isDisabled)
        .accessibilityLabel("Debrid service")
        .accessibilityValue(currentServiceDisplay)
        .accessibilityHint(isDisabled ? "No other debrid services available" : "Tap to cycle through debrid services")
    }

    private func cycleToNextService() {
        guard !isDisabled else { return }

        let sources = loggedInDebridSources

        // If no source is selected, select the first one
        guard let currentSource = debridManager.selectedDebridSource else {
            debridManager.selectedDebridSource = sources.first
            return
        }

        // Find current source index
        if let currentIndex = sources.firstIndex(where: { $0.id == currentSource.id }) {
            // Check if we are at the last source, then cycle to None
            if currentIndex == sources.count - 1 {
                debridManager.selectedDebridSource = nil
            } else {
                // Otherwise select next source
                debridManager.selectedDebridSource = sources[currentIndex + 1]
            }
        } else {
            // Current source not in logged-in sources, reset to first
            debridManager.selectedDebridSource = sources.first
        }
    }
}

struct DebridServiceToggle_Previews: PreviewProvider {
    static var previews: some View {
        DebridServiceToggle()
            .environmentObject(DebridManager())
    }
}

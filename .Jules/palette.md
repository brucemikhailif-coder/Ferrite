## 2025-05-24 - Enhancing Empty States Accessibility
**Learning:** Grouping title and message text in SwiftUI empty states using `.accessibilityElement(children: .combine)` provides a much cleaner VoiceOver experience, reading the entire context in one swipe. Decorative icons should always be hidden using `.accessibilityHidden(true)` to avoid redundant SF Symbol name reads.
**Action:** Always apply accessibility grouping to empty instruction views and similar informational groupings. Use context-specific SF Symbols to provide immediate visual reinforcement of the state.

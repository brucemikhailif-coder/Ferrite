## 2024-05-24 - Contextual Empty States and Accessibility Grouping

**Learning:** When implementing "empty states" in SwiftUI, using a single reusable component like `EmptyInstructionView` is efficient, but it must be flexible enough to provide context-specific icons (SF Symbols) to remain intuitive. Additionally, for better VoiceOver support, grouping the title and message into a single accessibility element using `.accessibilityElement(children: .combine)` provides a much smoother experience than navigating through separate labels. Marking decorative icons as `.accessibilityHidden(true)` is also crucial for reducing noise.

**Action:** Always provide an icon property in reusable state views and ensure accessibility grouping is applied to related text elements to improve VoiceOver flow in Ferrite.

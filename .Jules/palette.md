## 2025-05-24 - Accessible Empty States Pattern
**Learning:** Empty states in SwiftUI should use a combination of context-specific SF Symbols and semantic text. To ensure high accessibility:
1. Hide decorative icons from VoiceOver using `.accessibilityHidden(true)`.
2. Combine title and message into a single accessibility element using `.accessibilityElement(children: .combine)` on the container.
3. Use `DesignTokens.Typography.scaled` (or similar semantic font wrappers) to ensure full support for Dynamic Type.
4. Provide a default icon (e.g., "sparkles") in the component's initializer to maintain backward compatibility while allowing customization.

**Action:** Apply this pattern to all `EmptyInstructionView` instances and ensure any new empty states follow this structure.

## 2026-01-24 - Contextual Empty States & a11y Grouping
**Learning:** Generic empty states can be confusing and provide a poor VoiceOver experience. By adding context-specific icons (SF Symbols) and grouping the title and message into a single accessibility element, we reduce cognitive load and navigation friction.
**Action:** Always use `EmptyInstructionView` with a relevant `systemName` and ensure accessibility grouping is applied to paired text elements.

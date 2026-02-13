## 2026-01-24 - Contextual Accessibility Hints for Disabled States

**Learning:** In complex forms like `AddView`, buttons are often disabled based on multiple state variables (e.g., `isProcessing`, empty input, or provider support). Simply disabling the button leaves VoiceOver users without an explanation of why the action is unavailable. Using `.accessibilityHint()` with conditional logic provides immediate, clear feedback on what the user needs to do to enable the action.

**Action:** Always apply `.accessibilityHint()` to buttons that can be disabled, explaining the specific condition (e.g., "Wait for current processing to finish" vs "Enter web links or magnets first").

## 2026-01-24 - Tactile Confirmation for Destructive & Primary Actions

**Learning:** Adding `UIImpactFeedbackGenerator(style: .light)` to small/destructive actions (like removing an item from a list) and `.medium` to primary submit actions significantly enhances the "premium" feel of the native iOS experience. It provides a non-visual confirmation that the tap was registered, which is especially helpful when the UI might have a slight delay due to async processing.

**Action:** Implement `UIImpactFeedbackGenerator` within the action closure of all interactive buttons in Ferrite, matching the intensity to the importance of the action.

## 2026-01-24 - Clean Accessibility Logic with Computed Properties

**Learning:** Complex conditional accessibility hints (using nested ternaries) can quickly become unreadable and hard to maintain in the SwiftUI view body. Moving this logic to a private computed property within the View struct improves code clarity and allows for more readable `if-else` or `switch` statements.

**Action:** Use private computed properties (e.g., `private var submitButtonHint: String`) to manage complex accessibility hint logic.

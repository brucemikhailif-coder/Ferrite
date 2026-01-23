# Liquid Glass UI Migration Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task.

**Goal:** Modernize Ferrite iOS UI by replacing solid backgrounds with semantic "Liquid Glass" materials, leveraging iOS 26+ APIs while maintaining fallback support.

**Architecture:** Use a centralized ViewModifier (`.liquidGlass`) in `Extension/View.swift` to manage glass styles. Update key UI components (`PluginCatalogButtonView`, `Tag`, `SearchResultButtonView`, `HistoryButtonView`) to use this modifier with specific parameters based on user preferences.

**Tech Stack:** SwiftUI, iOS 26+ APIs (Glass Effect), Swift 5.8

### Task 1: Update `.liquidGlass` Modifier for Semantic Styles

**Files:**
- Modify: `Ferrite/Extensions/View.swift`

**Step 1: Read existing `View.swift`**
- Understand current `.liquidGlass` implementation.

**Step 2: Update `liquidGlass` function signature**
- Add `style` parameter (enum: `.card`, `.pill`, `.toast`) or similar semantic abstraction if needed, OR just robustly support the existing `tint` and `cornerRadius`.
- Ensure it handles the new requirements: "Neutral Glass" for buttons, "Subtle/Low Opacity" for tags, "Semantic Colored Glass" for badges, "Tinted Glass Pills" for history.
- **Refinement:** The current implementation in `View.swift` already supports `tint` and `cornerRadius`. We need to ensure it supports a "low opacity" tint effectively.
- **Action:** We will verify `liquidGlass` is flexible enough. The current implementation uses `.regular` material. We might need to expose material types or rely on `tint` opacity.
- *Correction:* The user selected specific styles. We should update the modifier if it lacks granularity, but looking at `View.swift`, it accepts `tint: Color?`. We can control opacity via the Color passed in. The underlying API `glassEffect(.regular.tint(tint)...)` suggests the tint color's opacity will influence the result.
- **Plan:** No changes strictly needed to `View.swift` logic *unless* we want to add convenience semantic wrappers. For now, we will use the existing modifier with precise Color definitions in the callsites.

### Task 2: Migrate Plugin Install Button to Neutral Glass

**Files:**
- Modify: `Ferrite/Views/ComponentViews/Plugin/Buttons/PluginCatalogButtonView.swift`

**Step 1: Locate the background modifier**
- Find: `.background(colorScheme == .light ? Color(uiColor: .secondarySystemBackground) : Color(uiColor: .tertiarySystemBackground))`

**Step 2: Replace with `.liquidGlass`**
- **User Preference:** "Neutral Glass"
- **Implementation:** Remove the `.background(...)` and `.clipShape(...)`.
- **Code:**
```swift
// Replace background and clipShape with:
.liquidGlass(cornerRadius: 10, interactive: true)
```

**Step 3: Verify visual hierarchy**
- Ensure text contrast remains readable on glass.

**Step 4: Commit**
```bash
git add Ferrite/Views/ComponentViews/Plugin/Buttons/PluginCatalogButtonView.swift
git commit -m "refactor(ui): migrate plugin install button to neutral liquid glass"
```

### Task 3: Migrate Tags/Chips to Subtle Tinted Glass

**Files:**
- Modify: `Ferrite/Views/CommonViews/Tag.swift`

**Step 1: Locate the background modifier**
- Find: `.background(RoundedRectangle(cornerRadius: 5).foregroundColor(...))`

**Step 2: Replace with `.liquidGlass`**
- **User Preference:** "Subtle/Low Opacity (Recommended)" (e.g. 0.1-0.2)
- **Implementation:**
  - Logic: Use the tag's `color` property. If nil, use `tertiaryLabel`.
  - Apply opacity to the tint color.
- **Code:**
```swift
// Inside body:
// Replace .background(...) with:
.liquidGlass(
    cornerRadius: 5,
    tint: (color ?? Color(uiColor: .tertiaryLabel)).opacity(0.15)
)
```

**Step 3: Commit**
```bash
git add Ferrite/Views/CommonViews/Tag.swift
git commit -m "refactor(ui): migrate tags to subtle tinted liquid glass"
```

### Task 4: Migrate Search Result Badges to Semantic Glass

**Files:**
- Modify: `Ferrite/Views/ComponentViews/SearchResult/SearchResultButtonView.swift`

**Step 1: Locate the badge background**
- Find: `.background(Capsule().fill(Color.accentColor.opacity(0.2)))`

**Step 2: Replace with `.liquidGlass`**
- **User Preference:** "Semantic Colored Glass"
- **Implementation:**
  - Identify status colors:
    - Cached: Green
    - Batch: Blue/Default (Accent)
  - Helper property for color based on status (already partially exists in `cacheBadgeText` logic or need to derive).
  - Code refactor:
    - Create `badgeColor` computed property or logic.
    - Apply `.liquidGlass(cornerRadius: 100, tint: badgeColor.opacity(0.2))` (Use large corner radius for Capsule effect).
- **Code Logic:**
```swift
// Helper to determine color
private func badgeColor(for badgeText: String) -> Color {
    switch badgeText {
    case "Cached": return .green
    case "Batch": return .accentColor // or .blue
    default: return .secondary
    }
}

// In body:
// Replace .background(...) with:
.liquidGlass(cornerRadius: 12, tint: badgeColor(for: badge).opacity(0.2)) // Adjust radius to look like capsule
```

**Step 3: Commit**
```bash
git add Ferrite/Views/ComponentViews/SearchResult/SearchResultButtonView.swift
git commit -m "refactor(ui): migrate search badges to semantic liquid glass"
```

### Task 5: Migrate History 'DEBRID' Badge to Tinted Glass Pills

**Files:**
- Modify: `Ferrite/Views/ComponentViews/Library/HistoryButtonView.swift`

**Step 1: Locate the DEBRID badge background**
- Find: `.background { Group { ... } .cornerRadius(4) .opacity(0.5) }`

**Step 2: Replace with `.liquidGlass`**
- **User Preference:** "Tinted Glass Pills" (Red/Green)
- **Implementation:**
  - Logic: Green for HTTPS, Red for others.
  - Apply `.liquidGlass`.
- **Code:**
```swift
// Replace .background { ... } with:
.liquidGlass(
    cornerRadius: 4,
    tint: (entry.url?.starts(with: "https://") == true ? Color.green : Color.red).opacity(0.2)
)
```

**Step 3: Commit**
```bash
git add Ferrite/Views/ComponentViews/Library/HistoryButtonView.swift
git commit -m "refactor(ui): migrate history debrid badge to tinted liquid glass"
```

### Task 6: Final Verification

**Step 1: Build Project**
- Run `xcodebuild -scheme Ferrite -configuration Debug build` to ensure no syntax errors.

**Step 2: Commit All**
- If any final tweaks, commit them.

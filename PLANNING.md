# Ferrite iOS - Project Planning

This file is the active planning hub for Ferrite's Apple design language migration.

## Active Work

### Current Session
- **Status**: Auditing the SwiftUI UI surface and defining the migration path
- **Phase**: Planning
- **Focus**: Expand the earlier Liquid Glass migration into a full Apple HIG-aligned design migration

## Planning Files Structure

| File | Purpose | Status |
| ---- | ------- | ------ |
| `PLANNING.md` | Unified migration plan and execution hub | Active |
| `task_plan.md` | Detailed task tracker for the current audit/planning pass | Active |
| `findings.md` | Audit findings, evidence, and component inventory | Active |
| `progress.md` | Session progress and verification notes | Active |
| `SESSION.md` | Compact live checkpoint and next action | Active |
| `docs/plans/2026-01-24-liquid-glass-ui-migration.md` | Earlier focused Liquid Glass plan | Reference |
| `docs/plans/2026-01-24-ui-modernization.md` | Earlier modernization plan | Reference |

## Goal

Migrate Ferrite's interface from a mix of custom glass treatments, legacy row compositions, and partially modernized SwiftUI into a consistent Apple-native design system that follows the Human Interface Guidelines for:

- color and semantic surfaces
- typography and Dynamic Type
- spacing and hierarchy
- SF Symbols and accessory usage
- materials and Liquid Glass
- controls, lists, forms, and empty states
- navigation, sheets, and modal flows

## Current State Summary

### Strengths
- `DesignTokens.swift` already defines spacing, corner radii, shadows, icon sizes, and text-style-based typography.
- `Extensions/View.swift` already includes a custom Liquid Glass layer with `.glassEffect()` support on iOS 26 and fallback behavior for older OS versions.
- Main screens already use strong native containers such as `TabView`, `NavigationStack`, `List`, `Form`, and `.insetGrouped` styling.
- Search result cards and tag/pill treatments already create a modern visual foundation.

### Gaps
- Shared reusable UI is inconsistent: some areas are modern and tokenized, others still rely on manual `HStack` rows, hardcoded gray accessories, and custom negative padding.
- Several shared files are placeholders or effectively unimplemented (`SectionHeaderView`, `LibraryHeaderView`).
- Filter chips, plugin actions, history rows, and utility screens use custom visual semantics that drift from Apple-native control behavior.
- Some buttons use all-caps labels, hardcoded foreground colors, or custom filled backgrounds where native button styles would be more appropriate.
- Empty states, logs, and modal/sheet flows need a consistency pass for spacing, hierarchy, and presentation style.

## Migration Principles

1. Prefer native SwiftUI components before adding new custom wrappers.
2. Reuse `DesignTokens` and semantic system styles before introducing new constants.
3. Keep Liquid Glass as a targeted enhancement layer, not the primary answer to every UI problem.
4. Preserve current app behavior and information density where it supports Ferrite's workflow.
5. Fix reusable shared components first so feature views improve with minimal duplicated work.
6. Phase the migration so each pass is testable and visually coherent on its own.

## Target State

- Native-feeling Apple UI across tabs, lists, forms, menus, sheets, and detail flows
- Consistent semantic use of typography, color, materials, separators, and iconography
- Shared row, badge, empty-state, and filter-chip patterns
- Native glass usage where it enhances hierarchy and tactility, with graceful fallback for older iOS versions
- Reduced hardcoded styling and less view-by-view reinvention

## Component Inventory

| Area | Key Files | Current Pattern | Migration Need | Priority |
| ---- | --------- | --------------- | -------------- | -------- |
| Shared rows | `Views/CommonViews/ListRowViews.swift` | Manual `HStack` rows, hardcoded accessory colors, negative trailing padding | Replace with consistent reusable row/accessory patterns using semantic colors and spacing | High |
| Shared headers | `Views/CommonViews/SectionHeaderView.swift`, `Views/CommonViews/LibraryHeaderView.swift` | Placeholder/empty bodies | Define reusable header surfaces or remove dead abstractions | High |
| Tab bar | `Views/CommonViews/GlassTabBarView.swift` | Custom glass shell with accent-highlighted selected tab | Review against native tab patterns and modern glass container usage | High |
| Empty states | `Views/CommonViews/EmptyInstructionView.swift` | Good typography, custom icon + solid CTA | Align CTA and spacing with Apple empty-state and button conventions | Medium |
| Tags/badges | `Views/CommonViews/Tag.swift`, `Views/ComponentViews/Plugin/PluginTagsView.swift` | Custom glass pills with tinted fills | Standardize badge sizing, opacity, color semantics, and accessibility | Medium |
| Search result cards | `Views/ComponentViews/SearchResult/*` | Custom glass cards, custom cached/batch pill, dense metadata row | Refine hierarchy, status semantics, and filter interactions | High |
| Filters | `Views/ComponentViews/Filters/*` | Menu-driven filter chips with custom glass pills and pressed gestures | Standardize chip semantics and reduce manual gesture styling | High |
| Plugin catalog/installed rows | `Views/ComponentViews/Plugin/*` | Mixed native list sections with custom action pills and tag strips | Move toward native action styling and clearer list hierarchy | High |
| Library/history | `Views/ComponentViews/Library/*` | Native lists plus custom row shells and debrid badge styling | Reuse shared rows/status badges and align hierarchy | High |
| Settings utilities | `Views/ComponentViews/Settings/*` | Mostly native forms/lists with some plain list or custom inline layouts | Improve consistency, action hierarchy, and list presentation | Medium |
| Choice sheets | `Views/SheetViews/*` | Native stacks/forms/lists with some legacy row helpers | Normalize modal titles, row components, search/list behavior, and actions | Medium |

## HIG Alignment Checklist

### Color and Surfaces
- Replace hardcoded `.gray` accessory styling with semantic secondary/tertiary styling.
- Audit accent-colored fills and strokes so they indicate state instead of acting as generic decoration.
- Prefer system grouped/list/form surfaces over custom card backgrounds unless hierarchy benefits clearly.

### Typography
- Continue using text-style-based fonts.
- Reduce one-off font weight combinations where semantic styles (`headline`, `subheadline`, `caption`) already express the hierarchy.
- Check list rows and pills for readability under Dynamic Type.

### Controls and Interaction
- Prefer native button roles/styles over custom all-caps micro-buttons.
- Keep tactile glass interactions only where they add value.
- Standardize accessory affordances for links, disclosure, export, destructive actions, and toggles.

### Navigation and Presentation
- Maintain `NavigationStack` and native sheet patterns.
- Align modal titles, toolbar actions, and dismiss affordances across `ActionChoiceView`, `BatchChoiceView`, `DebridTransferBrowserView`, and plugin/settings screens.
- Review where `.sheet`, `.alert`, `.confirmationDialog`, and `Menu` are used for consistency.

### Icons and Symbols
- Audit SF Symbol usage for semantic correctness and consistency.
- Reduce decorative symbols where text hierarchy already communicates meaning.
- Use symbol weights and color only to clarify action/state.

## Migration Phases

### Phase 1: Shared Foundation
**Goal:** Fix the reusable building blocks that drive visual consistency.

Tasks:
- Define a reusable section/header strategy for list and settings surfaces.
- Replace or modernize `ListRowViews.swift` so rows use semantic accessory patterns and tokenized spacing.
- Standardize `Tag.swift` and related badge usage.
- Rework `EmptyInstructionView` CTA styling to use more native button behavior.
- Decide whether `GlassTabBarView` remains custom or is simplified toward more native structure.

Exit criteria:
- Shared rows, badges, headers, and empty states no longer depend on ad hoc padding and manual color choices.

### Phase 2: Search and Filter Experience
**Goal:** Make the app's highest-traffic surface feel fully Apple-native while preserving Ferrite's density.

Tasks:
- Refine `SearchResultButtonView` hierarchy and status badge semantics.
- Standardize `SearchResultInfoView` metadata spacing and accessory treatment.
- Update filter chip/menu views to a consistent pattern using one reusable chip style.
- Revisit the horizontal filter header spacing and divider treatment.

Exit criteria:
- Search cards, metadata, and filters share one cohesive language and behave consistently in light/dark mode.

### Phase 3: Library and Plugin Surfaces
**Goal:** Bring browsing and configuration-heavy screens into the same design system.

Tasks:
- Update history, bookmarks, cloud/download rows, and related library components to use shared row/badge foundations.
- Update plugin catalog/install/update actions to use native button semantics and title casing.
- Clean up plugin info/about/settings detail views and section hierarchy.

Exit criteria:
- Library and plugin screens look like part of the same system as search/settings, not a separate generation of UI.

### Phase 4: Settings and Modal Flows
**Goal:** Improve consistency in utility screens and action-oriented sheets.

Tasks:
- Standardize settings list/form presentation, especially logs, backups, and default-action pickers.
- Normalize `ActionChoiceView`, `BatchChoiceView`, and `DebridTransferBrowserView` modal structure.
- Review sheet sizing, toolbar actions, empty/loading states, and share/export affordances.

Exit criteria:
- Modal and utility flows share consistent titles, actions, row styling, and feedback patterns.

### Phase 5: Final Polish and Verification
**Goal:** Complete the design migration with system-level verification.

Tasks:
- Audit light/dark mode, dynamic type, and accessibility basics.
- Review remaining hardcoded colors, font overrides, and spacing exceptions.
- Decide where native iOS 26 glass can replace the custom wrapper directly.
- Run formatting and build verification.

Exit criteria:
- No remaining high-priority HIG mismatches in the audited surface areas.

## Concrete File-Level Priorities

### High Priority
- `Ferrite/Views/CommonViews/ListRowViews.swift`
- `Ferrite/Views/CommonViews/SectionHeaderView.swift`
- `Ferrite/Views/CommonViews/LibraryHeaderView.swift`
- `Ferrite/Views/CommonViews/GlassTabBarView.swift`
- `Ferrite/Views/ComponentViews/SearchResult/SearchResultButtonView.swift`
- `Ferrite/Views/ComponentViews/SearchResult/SearchFilterHeaderView.swift`
- `Ferrite/Views/ComponentViews/Filters/FilterLabelView.swift`
- `Ferrite/Views/ComponentViews/Plugin/Buttons/PluginCatalogButtonView.swift`
- `Ferrite/Views/ComponentViews/Library/HistoryButtonView.swift`

### Medium Priority
- `Ferrite/Views/CommonViews/EmptyInstructionView.swift`
- `Ferrite/Views/CommonViews/Tag.swift`
- `Ferrite/Views/ComponentViews/SearchResult/SearchResultInfoView.swift`
- `Ferrite/Views/ComponentViews/Filters/DebridServiceToggle.swift`
- `Ferrite/Views/ComponentViews/Filters/IAFilterView.swift`
- `Ferrite/Views/ComponentViews/Filters/SourceFilterView.swift`
- `Ferrite/Views/ComponentViews/Filters/SortFilterView.swift`
- `Ferrite/Views/ComponentViews/Plugin/PluginAggregateView.swift`
- `Ferrite/Views/ComponentViews/Plugin/PluginInfoView.swift`
- `Ferrite/Views/ComponentViews/Settings/SettingsLogView.swift`
- `Ferrite/Views/ComponentViews/Settings/BackupsView.swift`
- `Ferrite/Views/ComponentViews/Settings/DefaultActionPickerView.swift`
- `Ferrite/Views/SheetViews/ActionChoiceView.swift`
- `Ferrite/Views/SheetViews/BatchChoiceView.swift`
- `Ferrite/Views/SheetViews/DebridTransferBrowserView.swift`

## Recommended Next Implementation Order

1. Rebuild shared row/header/badge primitives.
2. Migrate the search filter chip system and search result cards.
3. Refactor plugin and library rows to consume the shared primitives.
4. Normalize settings and sheet/action flows.
5. Run final polish, accessibility checks, SwiftFormat, and a build.

## Verification Strategy

- Compare updated surfaces against Apple-native list/form/navigation expectations.
- Verify Dynamic Type readability for rows, pills, and metadata-heavy cards.
- Test light and dark mode for accent tints, materials, and glass fallback behavior.
- Ensure no destructive behavior changes in action sheets, context menus, or download flows.

## Success Criteria

- Shared UI primitives define the app's spacing, accessory, badge, and row behavior consistently.
- High-priority user-facing surfaces (search, filters, library, plugin management) are visually and behaviorally aligned with Apple's design language.
- Remaining custom glass usage is intentional, minimal, and backed by native/fallback behavior.
- The app continues to feel like Ferrite, but with a cleaner, more Apple-native execution.

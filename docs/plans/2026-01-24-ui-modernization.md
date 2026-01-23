# UI Modernization Design

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task.

**Goal:** Modernize the Ferrite UI by restructuring navigation, simplifying the Library, and updating the debrid service toggle.

**Architecture:** Update view hierarchy, remove unused components, and create a new modern toggle component.

**Tech Stack:** Swift 5.8, SwiftUI

### Task 1: Refactor Bottom Bar & Move Plugins

**Files:**
- Modify: `Ferrite/Views/CommonViews/GlassTabBarView.swift`
- Modify: `Ferrite/Views/MainView.swift`
- Modify: `Ferrite/ViewModels/NavigationViewModel.swift`
- Modify: `Ferrite/Views/SettingsView.swift`
- Modify: `Ferrite/Views/PluginsView.swift`

**Step 1: Update GlassTabBarView**
- Remove the `(.plugins, "Plugins", "doc.text")` tuple from the `tabs` array.
- Change `.liquidGlass(cornerRadius: 20)` to `.liquidGlass(cornerRadius: 99)` for circular/capsule corners.

**Step 2: Update MainView**
- Remove `PluginsView()` from the `TabView`.
- Remove `.tag(NavigationViewModel.ViewTab.plugins)`.

**Step 3: Update NavigationViewModel**
- Remove `.plugins` from the `ViewTab` enum.

**Step 4: Update SettingsView**
- Add a new `Section("Plugins")` near the top of the Form.
- Add `NavigationLink("Installed Plugins") { PluginsView() }` inside the new section.
- Move the existing "Plugin lists" `NavigationLink` into this section, renaming it to "Manage Repositories".

**Step 5: Refactor PluginsView**
- Remove the outer `NavigationStack` wrapper, as it will now be pushed from within Settings.
- The `navigationTitle` and toolbar should remain, as they will be displayed when pushed.

### Task 2: Simplify Library View

**Files:**
- Modify: `Ferrite/ViewModels/NavigationViewModel.swift`
- Modify: `Ferrite/Views/ComponentViews/Library/LibraryPickerView.swift`
- Modify: `Ferrite/Views/LibraryView.swift`

**Step 1: Update NavigationViewModel**
- Remove `.bookmarks` from the `LibraryPickerSegment` enum.
- Change the default value of `libraryPickerSelection` from `.bookmarks` to `.history`.

**Step 2: Update LibraryPickerView**
- Remove `Text("Bookmarks").tag(NavigationViewModel.LibraryPickerSegment.bookmarks)` from the `Picker`.

**Step 3: Update LibraryView**
- Remove the `@FetchRequest` for `Bookmark` entity.
- Remove the `.bookmarks` case from the `switch navModel.libraryPickerSelection` block.
- Remove the empty state overlay for bookmarks.

### Task 3: Create Modern Debrid Toggle

**Files:**
- Create: `Ferrite/Views/ComponentViews/Filters/DebridServiceToggle.swift`
- Modify: `Ferrite/Views/ComponentViews/Filters/SelectedDebridFilterView.swift` (or replace usage)
- Modify: `Ferrite/Views/ComponentViews/SearchResult/SearchFilterHeaderView.swift`
- Modify: `Ferrite/Views/LibraryView.swift`

**Step 1: Create DebridServiceToggle**
- Implement a new view `DebridServiceToggle`.
- Use `.liquidGlass` for a pill-shaped appearance.
- Implement cycle logic: on tap, find the current service in `debridManager.debridSources` and select the next one.
- Display the abbreviation of the current service or "None".
- Disable the button if 0 or 1 services are available.

**Step 2: Integrate DebridServiceToggle**
- Replace `SelectedDebridFilterView` with `DebridServiceToggle` in `SearchFilterHeaderView`.
- Replace `SelectedDebridFilterView` with `DebridServiceToggle` in `LibraryView`'s toolbar.

### Task 4: Verification
- Test the new navigation flow (Plugins in Settings).
- Verify the Library view defaults to History and Bookmarks are gone.
- Test the new debrid toggle's cycling behavior.
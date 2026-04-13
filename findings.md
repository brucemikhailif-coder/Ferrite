# Findings & Decisions

## Requirements
- Apply the remaining 5 UI polish fixes directly in the codebase
- Keep behavior unchanged unless needed for polish
- Reuse `DesignTokens` and shared styles where possible
- Limit edits to the listed SwiftUI files

## Assumptions
- The existing migrated glass/card styles are the baseline to align to
- Row unification should come from spacing, typography, and accessory treatment rather than introducing a new component abstraction in this pass
- Settings logs should remain list-based but can feel more elevated with subtle surface treatment

## Open Questions
- None blocking for this polish pass

## Research Findings
- `SearchFilterHeaderView` used a suspicious `xxxlarge` compact inset that felt tuned by eye rather than by token scale.
- Shared row files (`ListRowViews`, `HistoryButtonView`, `PluginCatalogButtonView`) were close stylistically but not using the same rhythm for spacing, label sizing, and accessory treatment.
- Search result cards already had a solid glass-card shell; density mainly came from tight vertical rhythm and metadata weight.
- `GlassTabBarView` still used a more assertive selected fill than the rest of the migrated glass system.
- `SettingsLogView` had the right container structure but visually read as flat/plain text rows.

## Evidence Log
| Source | What It Confirms | Confidence |
| ------ | ---------------- | ---------- |
| `Ferrite/Design/DesignTokens.swift` | Token scales support replacing hard-coded insets and normalizing row spacing | high |
| `Ferrite/Extensions/View.swift` | Existing glass helpers are sufficient for subtle surface polish without adding new abstractions | high |
| `Ferrite/Views/CommonViews/ListRowViews.swift` | Shared row affordances can be unified with a local metrics helper | high |
| `Ferrite/Views/ComponentViews/SearchResult/SearchResultButtonView.swift` | Search result density is driven by spacing and badge treatment, not structure | high |
| `Ferrite/Views/CommonViews/GlassTabBarView.swift` | Selected tab state is visually stronger than the surrounding glass styling | high |
| `Ferrite/Views/ComponentViews/Settings/SettingsLogView.swift` | Logs screen can be improved with subtle card surfaces and hierarchy cues while staying behaviorally identical | high |

## Technical Decisions
| Decision | Rationale |
| -------- | --------- |
| Replace the compact search-filter inset with `Spacing.xlarge` | It preserves a slightly roomier compact layout without the outlier jump to `xxxlarge` |
| Add a local metrics helper in `ListRowViews` | It unifies row rhythm in one place without changing public APIs |
| Soften selected states and metadata weight instead of removing affordances | The goal is polish and hierarchy tuning, not less functionality |

## Issues Encountered
| Issue | Resolution |
| ----- | ---------- |
| Delegated designer execution failed with an empty provider response | Continued directly with local reads and targeted patches |

## Resources
- `task_plan.md`
- `findings.md`
- `progress.md`
- `Ferrite/Design/DesignTokens.swift`
- `Ferrite/Extensions/View.swift`
- Target view files listed in the user request

## Visual/Browser Findings
- Not applicable for this local code polish task

## Polish Pass Notes

| File | Main Polish Change |
| ---- | ------------------ |
| `SearchFilterHeaderView.swift` | Replaced the compact-only hard-coded inset jump with a token-based large-to-xlarge rule |
| `ListRowViews.swift` | Introduced shared local row metrics for spacing, vertical padding, body typography, and accessory symbol weight |
| `HistoryButtonView.swift` | Increased row rhythm, lightened metadata styling, and added a subtle chevron affordance to match shared rows |
| `PluginCatalogButtonView.swift` | Matched text rhythm and baseline alignment more closely to other list rows while keeping the install/update CTA intact |
| `SearchResultButtonView.swift` | Increased vertical spacing and softened the cache badge tint so the title remains visually dominant |
| `SearchResultInfoView.swift` | Reduced metadata weight/size and added more breathing room between primary and secondary metadata groups |
| `GlassTabBarView.swift` | Softened selected-state fill/shadow and reduced selected font weight intensity |
| `SettingsLogView.swift` | Wrapped log entries in subtle glass cards with clearer hierarchy and expand/collapse affordance |

## Deferred Follow-Ups
| Follow-Up | Reason Deferred | Trigger to Revisit |
| --------- | --------------- | ------------------ |
| Audit screenshots or runtime previews | Not needed for initial structural migration plan | Revisit before implementation polish pass |
| Deep accessibility pass with VoiceOver-specific review | Current task is broader design migration planning | Revisit during implementation/verification |

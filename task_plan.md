# Task Plan: Apple Design Migration Polish Pass

## Goal
Apply the remaining targeted UI polish fixes for Ferrite's Apple design migration without changing behavior.

## Scope
- In scope: tokenizing the search filter inset, unifying row spacing/affordances, reducing search-result density, softening tab selected-state styling, polishing the settings log surface
- Out of scope: behavior changes, unrelated files, broad redesigns or rewrites

## Constraints
- Keep behavior unchanged unless polish requires otherwise
- Prefer small coherent edits over rewrites
- Reuse `DesignTokens` and existing shared styles wherever possible
- Do not touch unrelated files

## Success Criteria
- All requested files are updated with targeted UI polish edits
- Spacing and affordances feel more systemized across affected components
- Selected-state and metadata styling feel lighter and more aligned with the glass system

## Current Phase
Phase 4

## Current Stage
Verification

## Phases
### Phase 1: Requirements & Discovery
- [x] Confirm the requested polish targets and constraints
- [x] Review existing design tokens and glass helpers
- [x] Inspect the target views
- **Status:** complete
- **Dependencies:** none
- **Verification:** affected files and reuse opportunities identified
- **Exit Criteria:** implementation approach is clear

### Phase 2: Planning & Structure
- [x] Identify minimal edits per file
- [x] Reuse token-based spacing and existing glass affordances
- **Status:** complete
- **Dependencies:** Phase 1
- **Verification:** each requested goal has a concrete edit path
- **Exit Criteria:** ready to implement

### Phase 3: Implementation
- [x] Update target SwiftUI files with focused polish changes
- [x] Keep interaction behavior unchanged
- **Status:** complete
- **Dependencies:** Phase 2
- **Verification:** requested visual polish applied only in listed files
- **Exit Criteria:** edits are ready for review

### Phase 4: Verification
- [x] Re-read touched files after patching
- [ ] Run diagnostics on touched files if available
- [x] Record summary in findings/progress files
- **Status:** in_progress
- **Dependencies:** Phase 3
- **Verification:** edits are scoped, coherent, and compile-clean if tooling allows
- **Exit Criteria:** ready to deliver concise summary

### Phase 5: Delivery
- [ ] Deliver concise summary of files changed and polish decisions
- **Status:** pending
- **Dependencies:** Phase 4
- **Verification:** response clearly states changed files and main UI decisions
- **Exit Criteria:** handoff complete

## Decisions Made
| Decision | Rationale |
| -------- | --------- |
| Prefer token substitutions and spacing normalization over structural rewrites | The request is a polish pass, not a redesign |
| Keep search result density changes focused on typography/spacing, not content logic | Titles should become more dominant without changing behavior |

## Errors Encountered
| Error | Attempt | Resolution |
| ----- | ------- | ---------- |
| Delegated designer subagent returned an empty provider response | 1 | Continued directly with local file edits |

## Risks & Mitigations
| Risk | Impact | Mitigation | Status |
| ---- | ------ | ---------- | ------ |
| Small style changes may drift from adjacent untouched views | medium | Reuse existing tokens and glass helpers so the changes match current migrated surfaces | open |
| Diagnostics may be unavailable in this environment | low | Manually review touched files and report tooling limitation if needed | open |

## Next Action (Concrete)
- File: `Ferrite/Views/CommonViews/GlassTabBarView.swift`
- Action: Run diagnostics/manual verification across the touched polish-pass files, then deliver summary
- Why now: Implementation is complete and needs final validation before handoff

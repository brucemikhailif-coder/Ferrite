# Task Plan: Planning Refresh and Agent Configuration Alignment

## Goal
Refresh the planning documents for the next work cycle and align the repository's required-skill configuration with the skills that actually exist in this environment.

## Scope
- In scope: `task_plan.md`, `findings.md`, `progress.md`, `IMPLEMENTATION_PHASES.md`, `SESSION.md`, `AGENTS.md`
- Out of scope: application feature code, CI behavior, Xcode project settings

## Constraints
- Preserve the repository's planning-file workflow from `AGENTS.md`
- Keep the required-skill intent intact while fixing invalid or non-resolvable skill names
- Do not introduce agent instructions that point to missing local skill files

## Success Criteria
- Planning docs reflect a new active task cycle for this configuration cleanup
- `AGENTS.md` names a default skill set that can be resolved locally
- Skill-name mapping is explicit enough that later sessions do not need to guess

## Current Phase
Phase 5

## Current Stage
Delivery

## Phases
### Phase 1: Requirements & Discovery
- [x] Understand user intent
- [x] Identify constraints and requirements
- [x] Document findings in findings.md
- **Status:** complete
- **Dependencies:** none
- **Verification:** repo instructions and current planning docs reviewed
- **Exit Criteria:** configuration target identified

### Phase 2: Planning & Structure
- [x] Define technical approach
- [x] Create project structure if needed
- **Status:** complete
- **Dependencies:** Phase 1
- **Verification:** active task plan, implementation phases, and session tracker drafted
- **Exit Criteria:** implementation path is clear

### Phase 3: Implementation
- [x] Execute the plan step by step
- [x] Test incrementally
- **Status:** complete
- **Dependencies:** Phase 2
- **Verification:** `AGENTS.md` updated to use resolvable skills and explicit mappings
- **Exit Criteria:** configuration edit applied cleanly

### Phase 4: Testing & Verification
- [x] Verify all requirements met
- [x] Document test results in progress.md
- **Status:** complete
- **Dependencies:** Phase 3
- **Verification:** skill references checked against `/root/.agents/skills`
- **Exit Criteria:** docs and config are internally consistent

### Phase 5: Delivery
- [x] Review all output files
- **Status:** complete
- **Dependencies:** Phase 4
- **Verification:** deliverables match request
- **Exit Criteria:** handoff complete

## Decisions Made
| Decision | Rationale |
| -------- | --------- |
| Treat `AGENTS.md` as the configuration target | The request followed skill-loading work and the repo's default-skill section contained non-resolvable names |
| Map missing SwiftUI-related skill names to `ios-development` plus `liquid-glass` | Those are the installed local skills that cover SwiftUI guidance and Liquid Glass behavior |
| Create `IMPLEMENTATION_PHASES.md` and `SESSION.md` for this cycle | `AGENTS.md` requires them for non-trivial work |

## Errors Encountered
| Error | Attempt | Resolution |
| ----- | ------- | ---------- |
| Required skill names did not match installed local skills | 1 | Verified installed skill files and replaced the defaults with resolvable names plus an explicit mapping note |

## Risks & Mitigations
| Risk | Impact | Mitigation | Status |
| ---- | ------ | ---------- | ------ |
| Future sessions may still reference the old names from the installed-skill inventory text | medium | Added a direct mapping note in the required-skills section | open |
| Skill coverage is broader than the original names implied | low | Mapping note explains the fallback intent and when to consult the skills | open |

## Next Action (Concrete)
- File: `task_plan.md`
- Action: Start the next task cycle from Phase 1 when a new request arrives
- Why now: This configuration-alignment cycle is complete

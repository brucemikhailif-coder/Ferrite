# Implementation Phases: Planning Refresh and Agent Configuration Alignment

**Project Type**: Repository workflow and agent-configuration maintenance
**Estimated Total**: 1.5 hours

## Phase 1: Discovery
**Type**: Infrastructure
**Estimated**: 0.5 hours
**Files**: `task_plan.md`, `findings.md`, `progress.md`, `AGENTS.md`

**Tasks**:
- [x] Review the current planning documents
- [x] Inspect `AGENTS.md` for required workflow and default-skill rules
- [x] Verify the relevant locally installed skill files

**Verification Criteria**:
- [x] Configuration target identified
- [x] Missing or mismatched skill names confirmed with file evidence

**Exit Criteria**:
- Active scope and concrete configuration change are defined

## Phase 2: Planning Docs Refresh
**Type**: Infrastructure
**Estimated**: 0.5 hours
**Files**: `task_plan.md`, `findings.md`, `progress.md`, `IMPLEMENTATION_PHASES.md`, `SESSION.md`

**Tasks**:
- [x] Reset the planning docs to an active task cycle
- [x] Add implementation phases for this work
- [x] Add a compact session tracker

**Verification Criteria**:
- [x] All required planning files exist
- [x] Each file reflects the current task instead of the archived previous feature cycle

**Exit Criteria**:
- The repository can resume this task from disk without hidden context

## Phase 3: Configuration Alignment
**Type**: Infrastructure
**Estimated**: 0.5 hours
**Files**: `AGENTS.md`

**Tasks**:
- [x] Replace non-resolvable default skill names with installed local skills
- [x] Add a mapping note that explains the fallback from the original skill names
- [x] Preserve the intent of the SwiftUI/Liquid Glass guidance

**Verification Criteria**:
- [x] Every default skill named in the section corresponds to a local `SKILL.md`
- [x] Mapping note is specific enough for future sessions to follow literally

**Exit Criteria**:
- `AGENTS.md` no longer instructs agents to load missing default skills

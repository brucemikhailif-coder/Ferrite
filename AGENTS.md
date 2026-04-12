# AGENTS.md - Development Guidelines for Ferrite iOS

This file contains build commands, code style guidelines, and development practices for agentic coding agents working on the Ferrite iOS codebase.

## Project Overview

Ferrite is a native iOS application written in Swift 5.8 using SwiftUI framework with MVVM architecture and Core Data for persistence. The app features a plugin system for media search and debrid service integration.

## Build, Test, and Lint Commands

### Build Commands
```bash
# Build for development
xcodebuild -scheme Ferrite -configuration Debug build

# Build for release (archive)
xcodebuild -scheme Ferrite -configuration Release archive -archivePath build/Ferrite.xcarchive CODE_SIGN_IDENTITY= CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO

# Build from CI/CD (used in GitHub Actions)
xcodebuild -scheme Ferrite -configuration Release archive -archivePath build/Ferrite.xcarchive CODE_SIGN_IDENTITY= CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```

### Code Formatting
```bash
# Format code using SwiftFormat (must be run before commits)
swiftformat .

# Check if formatting is needed
swiftformat --lint .
```

### Testing
```bash
# Note: This project currently has minimal formal testing
# Run SwiftUI preview tests (if available)
xcodebuild test -scheme Ferrite -destination 'platform=iOS Simulator,name=iPhone 14'

# Manual testing is primarily done through debug builds
```

## Code Style Guidelines

### Swift Language Standards
- **Swift Version**: 5.8
- **Indentation**: 4 spaces (no tabs)
- **Line Length**: Prefer under 120 characters
- **Semicolons**: Never use semicolons
- **Self Keyword**: Remove `self` where possible (SwiftFormat handles this)

### File Organization
```
Views/           - SwiftUI views organized by feature
ViewModels/      - ObservableObject view models  
Models/          - Data models and structures
Protocols/       - Protocol definitions
Extensions/      - Swift extensions
DataManagement/  - Core Data stack
API/             - Network layer
Utils/           - Utility functions
```

### Type Ordering (SwiftFormat rule)
1. actor
2. class
3. enum
4. struct

### Naming Conventions
- **Classes/Structs**: PascalCase (e.g., `SearchViewModel`, `MediaItem`)
- **Functions/Variables**: camelCase (e.g., `searchResults`, `loadData()`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `API_BASE_URL`)
- **Protocols**: PascalCase, often ending with `Protocol` (e.g., `PluginProtocol`)
- **Private Members**: camelCase with leading underscore only if needed for disambiguation

### SwiftUI Patterns
- Use `@StateObject` for view models owned by views
- Use `@ObservableObject` for shared view models
- Use `@EnvironmentObject` for app-wide shared state
- Prefer SwiftUI-native components over UIKit wrappers
- Use `.swiftui-introspect` only when absolutely necessary

### Core Data Integration
- Use generated Core Data classes
- Access via `@Environment(\.managedObjectContext)`
- Follow Core Data best practices for context management
- Use `@FetchRequest` for read-only data

### Concurrency
- Use async/await for network operations
- Use `MainActor` for UI updates
- Avoid completion handlers unless required by APIs
- Use `Task` for fire-and-forget operations

### Error Handling
- Use Swift's error handling with `do-catch`
- Log errors using `LoggingManager.shared.log()`
- Provide user-friendly error messages
- Use `Result` type for complex error scenarios

### Import Organization
- Group imports by framework type:
  1. SwiftUI/UIKit imports
  2. Foundation imports  
  3. Third-party imports
  4. Local imports
- Remove unused imports (SwiftFormat handles this)

### Optional Handling
- Always use short optional binding (`?`) over force unwrapping (`!`)
- Use `guard let` for early returns with optionals
- Use `if let` for conditional optional binding
- Only force unwrap when absolutely certain of non-nil value

### Protocol-Oriented Design
- Define protocols for extensible components (Plugin, Debrid)
- Use protocol extensions for default implementations
- Prefer composition over inheritance
- Use generics where appropriate for type safety

### Code Documentation
- Use `MARK:` comments to organize code sections
- Add doc comments for public APIs using `///`
- Include parameter descriptions and return value documentation
- Document complex business logic with inline comments

### Dependencies (Swift Package Manager)
The project uses these key packages:
- **SwiftSoup**: HTML parsing
- **SwiftyJSON**: JSON parsing  
- **keychain-swift**: Secure storage
- **BetterSafariView**: Safari integration
- **swiftui-introspect**: SwiftUI view introspection

## Development Workflow

### Branch Strategy
- `default`: Stable releases
- `next`: Development branch
- Feature branches: Create from `next` for new features

### Commit Standards
- Format code with `swiftformat .` before every commit
- Use clear, descriptive commit messages
- Include relevant issue numbers in commit messages
- Build must pass before merging

### Code Review Checklist
- [ ] Code formatted with SwiftFormat
- [ ] No force unwraps of optionals
- [ ] Proper error handling implemented
- [ ] SwiftUI best practices followed
- [ ] Core Data context usage correct
- [ ] Network operations use async/await
- [ ] No hardcoded credentials or URLs
- [ ] Logging implemented for debugging

## Architecture Guidelines

### MVVM Pattern
- Views: SwiftUI views with minimal logic
- ViewModels: `ObservableObject` classes handling business logic
- Models: Data structures and Core Data entities
- Clear separation between UI and business logic

### Plugin System
- Implement `PluginProtocol` for extensible components
- Use factory pattern for plugin instantiation
- Support both Source and Action plugin types
- Handle plugin failures gracefully

### Network Layer
- Use URLSession with async/await
- Implement proper error handling and retry logic
- Cache responses where appropriate
- Handle network connectivity issues

## Security Considerations
- Store sensitive data in Keychain using `keychain-swift`
- Never log credentials or personal information
- Use HTTPS for all network requests
- Validate and sanitize user inputs
- Implement proper certificate pinning if needed

## Performance Guidelines
- Use lazy loading for large data sets
- Implement proper memory management for Core Data
- Optimize SwiftUI view updates
- Use Instruments for performance profiling
- Monitor memory usage with allocation tracking

## Testing Strategy
- Currently relies on manual testing with debug builds
- Use SwiftUI previews for UI component testing
- Test plugin integrations with real services
- Perform regression testing before releases
- Use TestFlight for beta testing

## Tools and Environment
- **Xcode**: Latest stable version
- **SwiftFormat**: For code formatting (configured)
- **Git**: Version control with standard Xcode gitignore
- **GitHub Actions**: CI/CD for automated builds
- **Swift Package Manager**: Dependency management

## Common Pitfalls to Avoid
- Don't use UIKit unless absolutely necessary
- Avoid blocking the main thread with network operations
- Don't ignore Core Data context rules
- Never commit API keys or credentials
- Avoid force unwrapping optionals
- Don't skip code formatting before commits
## Planning with Files (Manus-Style)

Use persistent markdown files as "working memory on disk" to overcome context window limitations.

### The 3-File Pattern
For every complex task, you MUST maintain:
1. `task_plan.md`: Track phases and progress.
2. `findings.md`: Store research and findings.
3. `progress.md`: Session log and test results.

### Operational Hooks
- **SessionStart**: Create all three files FIRST. Fill in the Goal section.
- **PreToolUse**: Re-read `task_plan.md` before writing code or making major decisions.
- **PostToolUse**: Update status in `task_plan.md` (pending -> in_progress -> complete).
- **2-Action Rule**: After every 2 browser/search/view operations, save findings to `findings.md`.
- **3-Strike Protocol**: If an error persists after 3 attempts (Diagnose -> Alternative -> Rethink), escalate to the user.
- **Phase Sizing Rule**: Keep each phase to work that fits one focused session (roughly 2-4 hours).
- **Verification Gate Rule**: Every phase must define explicit verification checks and a concrete exit criterion.
- **Checkpoint Rule**: At phase boundaries (or when context is full), write a checkpoint summary in `progress.md` and set a concrete next action with file path.

### Extended Planning Files
For non-trivial work, add these two companion files:
1. `IMPLEMENTATION_PHASES.md`: Phase breakdown with size limits, dependencies, and exit criteria.
2. `SESSION.md`: Compact live tracker with current phase/stage, checkpoint hash, and one concrete "Next Action".

When present, keep `task_plan.md` as the high-level plan, and treat `SESSION.md` as the live execution tracker.

## Part 3: Templates (To be created at Task Start)

### task_plan.md
```markdown
# Task Plan: [Brief Description]

## Goal
[One sentence describing the end state]

## Scope
- In scope: [List]
- Out of scope: [List]

## Constraints
- [Technical or process constraints]

## Success Criteria
- [Observable outcome 1]
- [Observable outcome 2]

## Current Phase
Phase 1

## Current Stage
Implementation

## Phases
### Phase 1: Requirements & Discovery
- [ ] Understand user intent
- [ ] Identify constraints and requirements
- [ ] Document findings in findings.md
- **Status:** in_progress
- **Dependencies:** none
- **Verification:** requirements and constraints captured
- **Exit Criteria:** findings recorded and reviewed

### Phase 2: Planning & Structure
- [ ] Define technical approach
- [ ] Create project structure if needed
- **Status:** pending
- **Dependencies:** Phase 1
- **Verification:** plan reviewed against constraints
- **Exit Criteria:** implementation path is clear

### Phase 3: Implementation
- [ ] Execute the plan step by step
- [ ] Test incrementally
- **Status:** pending
- **Dependencies:** Phase 2
- **Verification:** core behavior works locally
- **Exit Criteria:** implementation tasks complete

### Phase 4: Testing & Verification
- [ ] Verify all requirements met
- [ ] Document test results in progress.md
- **Status:** pending
- **Dependencies:** Phase 3
- **Verification:** tests/manual checks pass
- **Exit Criteria:** no unresolved high-severity issues

### Phase 5: Delivery
- [ ] Review all output files
- **Status:** pending
- **Dependencies:** Phase 4
- **Verification:** deliverables match request
- **Exit Criteria:** handoff complete

## Decisions Made
| Decision | Rationale |
| -------- | --------- |
|          |           |

## Errors Encountered
| Error | Attempt | Resolution |
| ----- | ------- | ---------- |
|       | 1       |            |

## Risks & Mitigations
| Risk | Impact | Mitigation | Status |
| ---- | ------ | ---------- | ------ |
|      |        |            | open   |

## Next Action (Concrete)
- File: `path/to/file`
- Action: [single concrete next edit or command]
- Why now: [short reason]
```

### findings.md
```markdown
# Findings & Decisions

## Requirements
<!-- Captured from user request -->

## Assumptions
<!-- Assumptions made while implementing -->

## Open Questions
<!-- Blockers or ambiguities that may require user input -->

## Research Findings
<!-- Key discoveries during exploration -->

## Evidence Log
| Source | What It Confirms | Confidence |
| ------ | ---------------- | ---------- |
|        |                  | high       |

## Technical Decisions
| Decision | Rationale |
| -------- | --------- |
|          |           |

## Issues Encountered
| Issue | Resolution |
| ----- | ---------- |
|       |            |

## Resources
<!-- URLs, file paths, API references -->

## Visual/Browser Findings
<!-- CRITICAL: Update after every 2 view/browser operations -->

## Deferred Follow-Ups
| Follow-Up | Reason Deferred | Trigger to Revisit |
| --------- | --------------- | ------------------ |
|           |                 |                    |
```

### progress.md
```markdown
# Progress Log

## Session: [DATE]

## Status Snapshot
- Current phase: [Phase X]
- Current stage: [Implementation/Verification/Debugging]
- Overall status: [on_track/blocked]
- Last checkpoint: [commit hash or N/A]

### Actions taken:
- [Itemize work done]

## Test Results
| Test | Input | Expected | Actual | Status |
| ---- | ----- | -------- | ------ | ------ |
|      |       |          |        |        |

## Verification Checklist
- [ ] Functional checks complete
- [ ] Regression risk reviewed
- [ ] Edge cases validated
- [ ] Documentation updated

## Error Log
| Timestamp | Error | Attempt | Resolution |
| --------- | ----- | ------- | ---------- |
|           |       | 1       |            |

## Checkpoints
| Time | Checkpoint | Scope | Next Action |
| ---- | ---------- | ----- | ----------- |
|      |            |       |             |

## 5-Question Reboot Check
| Question             | Answer           |
| -------------------- | ---------------- |
| Where am I?          | Phase X          |
| Where am I going?    | Remaining phases |
| What's the goal?     | [goal statement] |
| What have I learned? | See findings.md  |
| What have I done?    | See above        |

## Ready-to-Resume Block
- Open first: `task_plan.md`
- Then open: `findings.md`
- First command/edit to run: [exact next action]
```

## Required Skills for This Repository

Agents working in this repo must load these skills by default at task start:

- `deep-debug`
- `ios-development`
- `liquid-glass`

Use this local mapping when older instructions or prompts mention unavailable skill names:
- `swift-development` -> `ios-development`
- `apple-swiftui-core` -> `ios-development`
- `apple-swiftui-webkit` -> `ios-development`
- `apple-liquid-glass` -> `liquid-glass`

If a task involves SwiftUI architecture, SwiftUI components, navigation/state patterns, embedded web content, or Liquid Glass styling, these skills are mandatory and should be consulted before implementation.

### Installed Apple Skills (from `apple-skills.zip`)

- `apple-accessibility`
- `apple-app-intents`
- `apple-app-patterns`
- `apple-app-prd-architect`
- `apple-appkit-bridge`
- `apple-charts-3d`
- `apple-cross-platform`
- `apple-docs`
- `apple-foundation-models`
- `apple-global-hotkeys`
- `apple-liquid-glass`
- `apple-macos-app-structure`
- `apple-macos-distribution`
- `apple-macos-permissions`
- `apple-mapkit-geo`
- `apple-pasteboard-textinsertion`
- `apple-skill-maintainer`
- `apple-swift-lang`
- `apple-swiftdata`
- `apple-swiftui-core`
- `apple-swiftui-webkit`
- `apple-tech-stack-validator`
- `apple-testing-swift`

### Installed Skills (from URL backup zip)

- `accessibility-generator`
- `analytics-setup`
- `app-planner`
- `apple-design`
- `apple-generators`
- `apple-intelligence`
- `apple-product`
- `architecture-spec`
- `auth-flow`
- `ci-cd-setup`
- `coding-best-practices`
- `competitive-analysis`
- `deep-linking`
- `error-monitoring`
- `feature-flags`
- `foundation-models`
- `implementation-guide`
- `implementation-spec`
- `ios`
- `liquid-glass`
- `localization-setup`
- `logging-setup`
- `market-research`
- `networking-layer`
- `onboarding-generator`
- `paywall-generator`
- `persistence-setup`
- `prd-generator`
- `product-agent`
- `push-notifications`
- `release-spec`
- `review-prompt`
- `settings-screen`
- `test-generator`
- `test-spec`
- `ui-review`
- `ux-spec`
- `visual-intelligence`
- `widget-generator`

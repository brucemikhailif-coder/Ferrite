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
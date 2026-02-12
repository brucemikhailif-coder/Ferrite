# Task Plan: Ferrite SwiftUI Updates

## Goal
Implement minimal SwiftUI updates for Ferrite including:
1. Cloud management tab with segmented current/past downloads with history
2. Multi-entry Download page (multiple web links and magnets)
3. Magnet:// deep link handling
4. Liquid Glass styling throughout

## Current Phase
Phase 2: Testing & Review - In Progress

## Phases

### Phase 1: Implementation
- [x] Understand codebase structure
- [x] Add DebridCloudHistoryItem model to DebridModels.swift
- [x] Update DebridManager.swift with cloudHistory and persistence
- [x] Update DebridCloudView.swift with segmented control
- [x] Update AddView.swift for multi-entry support
- [x] Update NavigationViewModel.swift with pendingMagnetLink
- [x] Update MainView.swift for magnet:// handling
- [x] Update GlassTabBarView.swift to rename "Add" to "Download"
- [x] Update Info.plist to register magnet URL scheme
- **Status:** completed

### Phase 2: Testing & Review
- [ ] Test magnet:// deep linking
- [ ] Test multi-entry download processing
- [ ] Test cloud history persistence
- [ ] Code review
- [ ] CodeQL security check
- **Status:** pending

### Phase 3: Finalization
- [ ] Address review feedback
- [ ] Final verification
- **Status:** pending

## Progress Notes
- Found existing liquid glass modifier in View.swift
- Found DesignTokens in Design/DesignTokens.swift
- DebridCloudDownload and DebridCloudMagnet models in DebridModels.swift
- Transfer handle infrastructure already exists

# Task Plan: Cloud Management & Downloads

## Goal
Refresh the cloud management tab with current/past downloads, add a multi-entry download page, support magnet:// deep links, and align with Liquid Glass design.

## Current Phase
Phase 1: Requirements & Discovery

## Phases
### Phase 1: Requirements & Discovery
- [x] Review cloud management views and download flow
- [x] Identify navigation, AddView, and Info.plist touchpoints
- [x] Capture initial findings in findings.md
- [ ] Plan minimal UI/model updates
**Status:** in_progress

### Phase 2: Implementation
- [ ] Update cloud management tab segmented UI
- [ ] Add download input for multi-link entry
- [ ] Register magnet:// URL handling
- [ ] Refresh Liquid Glass styling
**Status:** pending

### Phase 3: Validation
- [ ] Validate behavior and capture UI screenshots
- [ ] Summarize changes and security review
**Status:** pending

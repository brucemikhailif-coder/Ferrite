# Findings & Research

## Key Files
| Area | Files | Notes |
| --- | --- | --- |
| Cloud management | Views/ComponentViews/Library/DebridCloudView.swift, CloudDownloadView.swift, CloudMagnetView.swift | Cloud list is a List with downloads and magnets; new segmented UI needed for current/past. |
| Download/Add flow | Views/AddView.swift | Previously single-entry; now supports multi-entry with TextEditor. |
| Navigation | ViewModels/NavigationViewModel.swift, Views/MainView.swift | Handles tab selection and deep links; magnet:// handling added. |
| App registration | Info.plist | ferrite:// and magnet:// URL schemes registered; torrent document type configured. |

## Implementation Notes
- Cloud history is stored as `DebridCloudHistoryItem` (Codable) in `DebridModels.swift` and persisted in UserDefaults ("Debrid.CloudHistory").
- DebridManager merges current cloud downloads/magnets into history on fetch to build a past-downloads list.
- DebridCloudView now supports a segmented control with a history list filtered by provider, search text, and current cloud IDs.
- AddView is now a Download page with multi-entry processing (web links + magnets) and multiple torrent uploads.

## Open Items
- UI screenshots still needed once a runnable iOS environment is available.

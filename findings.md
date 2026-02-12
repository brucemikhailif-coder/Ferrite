# Findings & Research

## Key Files
| Area | Files | Notes |
| --- | --- | --- |
| Cloud management | Views/ComponentViews/Library/DebridCloudView.swift, CloudDownloadView.swift, CloudMagnetView.swift | Cloud list is a List with downloads and magnets; uses liquidGlass rows. |
| Download/Add flow | Views/AddView.swift | Handles single web link, magnet, and torrent upload today. |
| Navigation | ViewModels/NavigationViewModel.swift, Views/MainView.swift | Tab selection and onOpenURL for .torrent; no magnet:// handler yet. |
| App registration | Info.plist | ferrite:// URL scheme and torrent document type configured. |

## Notes
- No existing cloud download history storage; needs new storage to show past items.
- AddView currently only supports single URL/magnet and single torrent selection.

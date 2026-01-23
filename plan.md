0) Current-state map (what we’re building on)
Tabs: MainView.swift, enum: NavigationViewModel.swift
Debrid orchestration: DebridManager.swift
Debrid protocol: Debrid.swift
Providers:
Real-Debrid: RealDebridWrapper.swift (already has /unrestrict/link, /torrents/addMagnet, /torrents/selectFiles, /torrents/info/{id})
TorBox: TorBoxWrapper.swift (already has createtorrent, mylist, requestdl)
Cloud UI:
DebridCloudView.swift
CloudDownloadView.swift
CloudMagnetView.swift
Action chooser exists: ActionChoiceView.swift
Today several places auto-run PluginManager.runDefaultAction(...) instead of showing a chooser (e.g. CloudDownloadView.swift, BatchChoiceView.swift, SearchResultButtonView.swift, HistoryButtonView.swift).
1) Architecture decision: add “Add/Transfer” capability without breaking other providers
1.1 Extend DebridSource with capability flags + optional operations
In Debrid.swift, add defaulted capabilities like:

supportsWebLinks (hoster link unrestrict / web downloads)
supportsMagnetUnrestrict
supportsTorrentUpload
supportsTransferFileListing
…and add optional async methods with default “NotImplemented” behavior so AllDebrid/Premiumize/Offcloud continue compiling.

Why: you need “show all enabled providers, disable unsupported actions” in the new Add tab.

1.2 Add new transfer models
In DebridModels.swift, introduce minimal shared models for the Add tab + browser:

DebridTransferHandle (provider id + transfer/torrent id)
DebridTransferFile (id, path/name, maybe size)
DebridUnrestrictResult (displayName, urlString, mimeType/filesize if known)
This avoids trying to force torrent-file upload through the existing getRestrictedFile(magnet:...) path.

2) Provider work (TorBox + Real-Debrid)
2.1 Real-Debrid
Implement in RealDebridWrapper.swift:

Unrestrict web links
Use existing /unrestrict/link logic (already in unrestrictFile(_:)).
Extend to accept a raw URL string (and optionally support /unrestrict/folder if you want true “browse files in link” behavior).
Unrestrict magnets
Already supported via addMagnet → selectFiles → torrentInfo → unrestrict/link on selected file link.
Upload torrent files
RD API supports PUT /torrents/addTorrent (requires host from /torrents/availableHosts), per current docs.
Implement multipart upload (reuse existing multipart helpers if present; TorBox uses FormDataBody already).
Then run selectFiles + torrentInfo to list files and unrestrict chosen one.
2.2 TorBox
In TorBoxWrapper.swift:

Magnet flow already exists (createtorrent + mylist + requestdl).
Torrent upload: requires TorBox API confirmation (endpoint + multipart field names).
Web link unrestrict / web downloads: not currently implemented (and getUserDownloads() is stubbed). This is the main unknown:
If TorBox supports hoster link unrestrict: implement it.
If TorBox only supports “web downloads” as a job type: implement add/list/browse in cloud downloads and in Add tab, and label accordingly.
Until clarified, the plan is: Add tab shows “Web link” for TorBox but disabled (capability false) or supports it only if API is confirmed.

3) New bottom tab: “Add”
3.1 Navigation plumbing
Add a new case to NavigationViewModel.ViewTab in NavigationViewModel.swift
Add a new .tabItem in MainView.swift
3.2 AddView UI (core flows)
Create AddView (new file), with:

Provider selector = all enabled providers (debridManager.enabledDebrids) with capability badges
Sections:
Web link: paste + “Process” (per provider buttons enabled/disabled)
Magnet: paste + “Add/Unrestrict”
Torrent upload:
.fileImporter for .torrent
and support open-in/share via onOpenURL routing
3.3 Open-in support for .torrent
Currently Info.plist only declares .feb. You’ll need to update Info.plist to register .torrent (document type / UTType), then in MainView.swift extend .onOpenURL to:

detect .torrent
route user to Add tab (navModel.selectedTab = .add)
store pending torrent URL in nav model or a new Add view model
4) File “viewing tools” for web links + torrents (both providers)
4.1 Torrent/magnet file browser
Create a reusable browser view (new file), patterned after BatchChoiceView.swift:

Searchable list of DebridTransferFile
Tap file → unrestrict → then present chooser sheet
4.2 Web link “browser”
For Real-Debrid:

If /unrestrict/link returns a single item: show a 1-row list anyway (still counts as “viewing tool”).
If /unrestrict/folder is used: show multiple rows.
For TorBox:

depends on what “web downloads” mean in their API; if it returns a list of files, show them similarly.
5) Make “chooser sheet” the default everywhere (no auto-run)
You already selected “Choose each time”, and the project already has ActionChoiceView + PluginManager.runDefaultAction.

Implementation direction:

Replace calls to pluginManager.runDefaultAction(...) with:
set debridManager.downloadUrl (or set navModel.selectedMagnet)
set navModel.currentChoiceSheet = .action
Primary files to update (confirmed):

SearchResultButtonView.swift
CloudDownloadView.swift
CloudMagnetView.swift
BatchChoiceView.swift
HistoryButtonView.swift
Then enhance ActionChoiceView.swift to add:

“Default action” (explicit button that calls pluginManager.runDefaultAction(...))
“Open in Safari” for http/https
keep Copy/Share/Kodi/plugin actions as-is
This matches your requirement without rewriting PluginManager.

6) Cloud management UX improvements
Incremental upgrades, minimal disruption:

Cloud > Downloads: tap should resolve to URL (if needed) then open chooser (not auto-run)
Cloud > Magnets: tap should open file browser (even if single file) → choose file → unrestrict → chooser
Add context menus: Copy/Share/Open in Safari/Delete
Consider adding a lightweight status row (cached/downloading/etc) and a “Refresh” affordance (already has pull-to-refresh)
Files involved:

DebridCloudView.swift
CloudDownloadView.swift
CloudMagnetView.swift
7) Test plan (practical)
Unit-ish tests for:
URL validation for web links/magnets
parsing .torrent intake routing (if you keep logic isolated)
Integration (manual / debug builds):
RD: unrestrict/link, addMagnet, selectFiles, torrentInfo, addTorrent
TorBox: createtorrent → mylist → requestdl; plus upload/web link once API confirmed
UI checks:
chooser sheet appears instead of auto-run in all the touchpoints above
Add tab disables unsupported actions for other providers
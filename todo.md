Implement DebridSource capability flags + new transfer models/methods

Add new Add tab (NavigationViewModel + MainView) and build AddView UI

Implement Real-Debrid: web link unrestrict, magnet unrestrict flow, torrent upload flow

Implement TorBox: web link handling, magnet unrestrict flow, torrent upload flow (or safe NotImplemented if API missing)

Add transfer browser UI to browse files for link/torrent results and wire to chooser sheet

Change app behavior to always show chooser sheet (remove auto-run default action)

Improve cloud management UX (cloud downloads + magnets browse + context actions)

Add .torrent open-in support (Info.plist + onOpenURL routing)

Sanity-check build/compilation paths (best-effort)
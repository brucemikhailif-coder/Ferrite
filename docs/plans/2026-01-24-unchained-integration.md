# Unchained Plugin Integration Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task.

**Goal:** Extend Ferrite's plugin system to support Unchained plugins by implementing a format adapter that maps Unchained JSON definitions to Ferrite's `SourceJson` format.

**Architecture:** Create an `UnchainedAdapter` service that fetches Unchained plugin repositories (JSON), parses individual plugin definitions (JSON/Unchained format), and converts them into Ferrite's `SourceJson` model. The adapter will handle regex mapping and URL construction differences.

**Tech Stack:** Swift 5.8, Codable, Regex (NSRegularExpression or Swift Regex), URLSession

### Task 1: Create Unchained Models

**Files:**
- Create: `Ferrite/Models/UnchainedModels.swift`

**Step 1: Define Unchained Plugin Models**
- Create Codable structs matching the Unchained JSON structure (based on `etree_v2.0.unchained`).
- Models needed: `UnchainedPlugin`, `UnchainedSearch`, `UnchainedDownload`, `UnchainedRegexConfig`, `UnchainedRegexPattern`.

```swift
// Ferrite/Models/UnchainedModels.swift

import Foundation

struct UnchainedPlugin: Codable {
    let engineVersion: Double
    let version: Double
    let url: String
    let name: String
    let description: String?
    let supportedCategories: [String: String]?
    let search: UnchainedSearch
    let download: UnchainedDownload

    enum CodingKeys: String, CodingKey {
        case engineVersion = "engine_version"
        case version
        case url
        case name
        case description
        case supportedCategories = "supported_categories"
        case search
        case download
    }
}

struct UnchainedSearch: Codable {
    let noCategory: String

    enum CodingKeys: String, CodingKey {
        case noCategory = "no_category"
    }
}

struct UnchainedDownload: Codable {
    let regexes: UnchainedRegexes
}

struct UnchainedRegexes: Codable {
    let name: UnchainedRegexConfig
    let seeders: UnchainedRegexConfig
    let leechers: UnchainedRegexConfig
    let size: UnchainedRegexConfig
    let torrents: UnchainedRegexConfig
}

struct UnchainedRegexConfig: Codable {
    let regexUse: String?
    let regexps: [UnchainedRegexPattern]

    enum CodingKeys: String, CodingKey {
        case regexUse = "regex_use"
        case regexps
    }
}

struct UnchainedRegexPattern: Codable {
    let regex: String
    let group: Int
    let slugType: String

    enum CodingKeys: String, CodingKey {
        case regex
        case group
        case slugType = "slug_type"
    }
}
```

**Step 2: Commit**
```bash
git add Ferrite/Models/UnchainedModels.swift
git commit -m "feat(unchained): add unchained plugin codable models"
```

### Task 2: Implement Unchained Adapter Logic

**Files:**
- Create: `Ferrite/Utils/UnchainedAdapter.swift`

**Step 1: Create Adapter Class**
- Implement `UnchainedAdapter` with a static method `adapt(unchained: UnchainedPlugin) -> SourceJson`.
- Map Unchained fields to `SourceJson`.
- **Key Logic:**
  - `name` -> `name`
  - `version` -> `version` (cast Double to Int16)
  - `description` -> `about`
  - `url` -> `website`
  - `search.no_category` -> `jsonParser.searchUrl` (convert `${query}` to `{query}`)
  - `download.regexes` -> `htmlParser` (Unchained uses regexes on HTML, so map to `SourceHtmlParserJson`).

**Step 2: Implement Regex Mapping**
- Unchained uses regexes for parsing HTML. Ferrite's `SourceHtmlParserJson` has fields like `title`, `size`, `seedLeech`, `magnet`.
- Map:
  - `regexes.name` -> `htmlParser.title`
  - `regexes.size` -> `htmlParser.size`
  - `regexes.seeders` & `leechers` -> `htmlParser.sl` (Ferrite combines them, Unchained separates. We might need a custom parser or adapter logic to combine them if Ferrite supports separate fields, or assume they are close).
  - *Correction:* Ferrite's `SourceSeedLeechJson` has `seederRegex` and `leecherRegex`. Perfect map.
  - `regexes.torrents` -> `htmlParser.magnet` (Unchained `slug_type: "append_url"` means we prepend base URL).

**Step 3: Write Implementation**

```swift
// Ferrite/Utils/UnchainedAdapter.swift

import Foundation

class UnchainedAdapter {
    static func adapt(unchained: UnchainedPlugin) -> SourceJson {
        let htmlParser = SourceHtmlParserJson(
            searchUrl: unchained.search.noCategory.replacingOccurrences(of: "${query}", with: "{query}"),
            rows: "", // Unchained doesn't strictly define rows regex, it iterates matches. Ferrite might need a row selector.
                      // If Ferrite requires a row selector, we might need to assume a broad one or leave it empty if the parser handles global regex.
                      // Looking at Unchained: it seems to run regexes globally or per page.
                      // Ferrite's HTML parser likely expects a "row" selector to isolate items first.
                      // LIMITATION: Unchained regexes seem global. We might set rows to "body" or similar if needed, or rely on global regex support.
            title: mapRegex(unchained.download.regexes.name),
            size: mapRegex(unchained.download.regexes.size),
            sl: mapSeedLeech(seeders: unchained.download.regexes.seeders, leechers: unchained.download.regexes.leechers),
            magnet: mapMagnet(unchained.download.regexes.torrents, baseUrl: unchained.url)
        )

        return SourceJson(
            name: unchained.name,
            version: Int16(unchained.version),
            minVersion: "1.0",
            about: unchained.description,
            website: unchained.url,
            htmlParser: htmlParser
        )
    }

    private static func mapRegex(_ config: UnchainedRegexConfig) -> SourceComplexQueryJson {
        // Take the first regex for now
        guard let pattern = config.regexps.first else {
            return SourceComplexQueryJson(query: "", attribute: nil, regex: nil)
        }
        return SourceComplexQueryJson(
            query: "", // Unchained is pure regex, no CSS selector. Ferrite might require CSS.
                       // If Ferrite ONLY supports CSS+Regex, this is a blocker.
                       // ASSUMPTION: Ferrite's regex field can work on the whole document if query is empty or generic.
            attribute: nil,
            regex: pattern.regex
        )
    }

    private static func mapSeedLeech(seeders: UnchainedRegexConfig, leechers: UnchainedRegexConfig) -> SourceSeedLeechJson? {
        guard let sPattern = seeders.regexps.first, let lPattern = leechers.regexps.first else { return nil }
        return SourceSeedLeechJson(
            seeders: nil, leechers: nil, combined: nil,
            seederRegex: sPattern.regex,
            leecherRegex: lPattern.regex
        )
    }

    private static func mapMagnet(_ config: UnchainedRegexConfig, baseUrl: String) -> SourceMagnetLinkJson {
        guard let pattern = config.regexps.first else {
            return SourceMagnetLinkJson(externalLinkQuery: nil, query: "", attribute: nil, regex: nil)
        }
        // Handle "append_url" logic: Ferrite might need a way to know this.
        // If Ferrite regex captures the relative URL, the parser needs to prepend base.
        // We'll pass the regex.
        return SourceMagnetLinkJson(
            externalLinkQuery: nil,
            query: "",
            attribute: nil,
            regex: pattern.regex
        )
    }
}
```

**Step 4: Commit**
```bash
git add Ferrite/Utils/UnchainedAdapter.swift
git commit -m "feat(unchained): implement unchained to sourcejson adapter"
```

### Task 3: Integrate into PluginManager

**Files:**
- Modify: `Ferrite/ViewModels/PluginManager.swift`

**Step 1: Add Unchained Fetch Method**
- Add `func fetchUnchainedPluginList(url: URL)` to `PluginManager`.
- This function will:
  1. Fetch the `repository.json` (Unchained repo index).
  2. Parse it to find plugin definition URLs.
  3. Fetch each plugin definition.
  4. Use `UnchainedAdapter` to convert to `SourceJson`.
  5. Append to `availableSources`.

**Step 2: Update `fetchPluginsFromUrl`**
- Modify `fetchPluginsFromUrl` to detect if the URL is an Unchained repository (maybe check extension `.json` vs Ferrite's structure, or try decoding Unchained format if Ferrite decode fails).
- Or add a dedicated "Add Unchained Repo" UI flow (simpler).
- For now, let's try to detect in `fetchPluginList`.

**Step 3: Commit**
```bash
git add Ferrite/ViewModels/PluginManager.swift
git commit -m "feat(unchained): integrate unchained fetch logic into plugin manager"
```

### Task 4: UI for Unchained Repos (Optional/MVP)

**Files:**
- Modify: `Ferrite/Views/ComponentViews/Settings/PluginList/PluginListEditorView.swift` (or where lists are added)

**Step 1: Add Unchained Option**
- When adding a repo, allow user to specify "Type: Ferrite / Unchained".
- Or auto-detect.

**Step 2: Commit**
```bash
git add Ferrite/Views/ComponentViews/Settings/PluginList/PluginListEditorView.swift
git commit -m "feat(ui): add support for adding unchained repositories"
```

### Task 5: Final Verification

**Step 1: Mock Test**
- Create a unit test `Tests/UnchainedAdapterTests.swift` (if tests exist) or a temporary run check.
- Instantiate `UnchainedAdapter` with the sample `etree` JSON.
- Verify `SourceJson` output.

**Step 2: Commit**
```bash
git add .
git commit -m "test: verify unchained adapter"
```

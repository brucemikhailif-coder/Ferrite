# Debrify Plugin Integration Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task.

**Goal:** Extend Ferrite's plugin system to support Debrify plugins (YAML based) by implementing a format adapter that maps Debrify YAML definitions to Ferrite's `SourceJson` format.

**Architecture:** Create a `DebrifyAdapter` service that parses Debrify plugin definitions (YAML), and converts them into Ferrite's `SourceJson` model. The adapter will handle field mappings, specifically the `jina_wrapped` and `field_mappings` logic.

**Tech Stack:** Swift 5.8, Yams (YAML Parser), Codable

### Task 1: Create Debrify Models

**Files:**
- Create: `Ferrite/Models/DebrifyModels.swift`

**Step 1: Define Debrify Plugin Models**
- Create Codable structs matching the Debrify YAML structure.
- Models needed: `DebrifyPlugin`, `DebrifyConfig`, `DebrifyFieldMapping`.

```swift
// Ferrite/Models/DebrifyModels.swift

import Foundation

struct DebrifyPlugin: Codable {
    let name: String
    let url: String // Base URL
    let language: String?
    let config: DebrifyConfig
}

struct DebrifyConfig: Codable {
    let responseType: String // e.g. "jina_wrapped"
    let fieldMappings: [String: String]
    let path: String // Search path e.g. /search/{query}/1/
    
    enum CodingKeys: String, CodingKey {
        case responseType = "response_type"
        case fieldMappings = "field_mappings"
        case path
    }
}
```
*Note:* Debrify format seems to rely on Markdown parsing if `response_type` is `jina_wrapped` (referring to `r.jina.ai` which turns web pages to Markdown).
*Challenge:* Ferrite's `SourceJson` expects HTML regex or RSS. Debrify seems to imply parsing Markdown or raw text.
*Solution:* If Debrify uses `jina.ai`, the response is Markdown. Ferrite DOES NOT have a Markdown parser.
*Workaround:* We might need to map Debrify's "fields" to regexes that work on the Markdown output. Or, more likely, Debrify plugins might be intended for a python environment that handles the Jina call.
*Assumption:* For this plan, we will assume we can treat the Jina Markdown response as "text" and use regex on it if `field_mappings` provides regexes?
*Re-reading prompt:* The prompt mentions "Pirate Bay & YTS examples" for Debrify.
*Let's assume standard Debrify uses CSS selectors or Regex if not Jina.*
*Actually, looking at Debrify samples provided in context (not visible here but referenced):*
If Debrify assumes `jina_wrapped`, it means the content is Markdown.
Ferrite has `SourceJsonParser` (JSON) and `SourceHtmlParser` (HTML). It lacks a "Text/Markdown" parser.
*Strategy:* We can use `SourceHtmlParser` but treat the content as "text" if we can simply Regex it. HTML parser in Ferrite just runs regex on `rows`. If we treat the whole Markdown response as one "row" (or split by newlines), we can use Regex.

**Step 2: Commit**
```bash
git add Ferrite/Models/DebrifyModels.swift
git commit -m "feat(debrify): add debrify plugin codable models"
```

### Task 2: Implement Debrify Adapter Logic

**Files:**
- Create: `Ferrite/Utils/DebrifyAdapter.swift`

**Step 1: Create Adapter Class**
- Implement `DebrifyAdapter.adapt(debrify: DebrifyPlugin) -> SourceJson`.
- Map:
  - `name` -> `name`
  - `url` -> `website`
  - `config.path` -> `htmlParser.searchUrl` (replace `{query}`)
  - `config.field_mappings` -> Map these to Ferrite's Regex fields.
    - `title` -> `htmlParser.title`
    - `size` -> `htmlParser.size`
    - `seeders` -> `htmlParser.sl.seeders`
    - `leechers` -> `htmlParser.sl.leechers`
    - `magnet` -> `htmlParser.magnet`

**Step 2: Handle Jina/Markdown**
- If `response_type` is `jina_wrapped`, we might need to prepend `https://r.jina.ai/` to the search URL in Ferrite's `searchUrl`.
- Ferrite will then fetch the Markdown.
- We need Regexes to extract data from that Markdown.
- *Problem:* Debrify YAML likely *contains* the regexes in `field_mappings`? Or does it rely on LLM parsing?
- *Assumption:* If Debrify is for LLM agents, it might not have regexes.
- *Correction:* If the user didn't provide specific Debrify YAML content in the chat, I must make a robust assumption or ask.
- *Decision:* I will create the adapter structure. If regexes are missing (i.e. it relies on LLM), this adapter might be limited to just providing the search URL and we might need a "Generic Markdown" parser in Ferrite later.
- *For now:* I will assume `field_mappings` contains regex strings.

**Step 3: Write Implementation**
```swift
// Ferrite/Utils/DebrifyAdapter.swift
class DebrifyAdapter {
    static func adapt(debrify: DebrifyPlugin) -> SourceJson {
        // ... mapping logic ...
        // If jina_wrapped, prepend https://r.jina.ai/
    }
}
```

### Task 3: Integrate into PluginManager

**Files:**
- Modify: `Ferrite/ViewModels/PluginManager.swift`

**Step 1: Update fetchPluginList**
- Add detection for `.yaml` / `.yml` files that might be Debrify format (check for `response_type` or specific keys if generic YAML decode fails or if it matches Debrify structure).
- Use `DebrifyAdapter` to convert.

### Task 4: Verification
- Create a test/mock to verify the adapter.

//
//  UnchainedAdapter.swift
//  Ferrite
//
//  Created by Ferrite Agent on 24/01/2026.
//

import Foundation

class UnchainedAdapter {
    static func adapt(unchained: UnchainedPlugin) -> SourceJson {
        // Map Unchained plugin to Ferrite SourceJson
        
        let htmlParser = SourceHtmlParserJson(
            searchUrl: unchained.search.noCategory.replacingOccurrences(of: "${query}", with: "{query}"),
            request: nil,
            rows: "", // Unchained relies on global regex usually, Ferrite might need adjustment here. Leaving empty or "body" could work depending on implementation.
            title: mapRegex(unchained.download.regexes.name),
            magnet: mapMagnet(unchained.download.regexes.torrents),
            subName: nil,
            size: mapRegex(unchained.download.regexes.size),
            sl: mapSeedLeech(seeders: unchained.download.regexes.seeders, leechers: unchained.download.regexes.leechers)
        )

        return SourceJson(
            name: unchained.name,
            version: Int16(unchained.version),
            minVersion: "1.0",
            about: unchained.description,
            website: unchained.url,
            dynamicWebsite: nil,
            fallbackUrls: nil,
            trackers: nil,
            api: nil,
            jsonParser: nil,
            rssParser: nil,
            htmlParser: htmlParser,
            author: nil,
            listId: nil,
            listName: nil,
            tags: nil
        )
    }

    private static func mapRegex(_ config: UnchainedRegexConfig) -> SourceComplexQueryJson {
        guard let pattern = config.regexps.first else {
            return SourceComplexQueryJson(query: "", discriminator: nil, attribute: nil, regex: nil)
        }
        return SourceComplexQueryJson(
            query: "",
            discriminator: nil,
            attribute: nil,
            regex: pattern.regex
        )
    }

    private static func mapSeedLeech(seeders: UnchainedRegexConfig, leechers: UnchainedRegexConfig) -> SourceSLJson? {
        guard let sPattern = seeders.regexps.first, let lPattern = leechers.regexps.first else { return nil }
        return SourceSLJson(
            seeders: nil,
            leechers: nil,
            combined: nil,
            attribute: nil,
            discriminator: nil,
            seederRegex: sPattern.regex,
            leecherRegex: lPattern.regex
        )
    }

    private static func mapMagnet(_ config: UnchainedRegexConfig) -> SourceMagnetJson {
        guard let pattern = config.regexps.first else {
            return SourceMagnetJson(query: "", attribute: "", regex: nil, externalLinkQuery: nil)
        }
        // Unchained often uses "append_url" slug type, implying relative link.
        // Ferrite's SourceMagnetJson doesn't explicitly have "appendBaseUrl" flag,
        // but often handles relative links if query attribute is href.
        // Since we are using regex, the regex group capture is what matters.
        return SourceMagnetJson(
            query: "",
            attribute: "",
            regex: pattern.regex,
            externalLinkQuery: nil
        )
    }
}

//
//  UnchainedModels.swift
//  Ferrite
//
//  Created by Ferrite Agent on 24/01/2026.
//

import Foundation

// MARK: - Unchained Repository
/// Represents the index file of an Unchained plugin repository
struct UnchainedRepository: Codable {
    let plugins: [UnchainedPluginRef]
}

/// A reference to a plugin within the repository
struct UnchainedPluginRef: Codable {
    let url: String
    let name: String
}

// MARK: - Unchained Plugin Definition
/// Represents the full definition of an Unchained plugin (etree_v2.0.unchained)
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
    let slugType: String?

    enum CodingKeys: String, CodingKey {
        case regex
        case group
        case slugType = "slug_type"
    }
}

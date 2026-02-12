//
//  DebridModels.swift
//  Ferrite
//
//  Created by Brian Dashore on 6/2/24.
//

import Foundation

struct DebridIA: Hashable, Sendable {
    let magnet: Magnet
    let expiryTimeStamp: Double
    var files: [DebridIAFile]
}

struct DebridIAFile: Hashable, Sendable {
    let id: Int
    let name: String
    let streamUrlString: String?
    let batchIds: [Int]

    init(id: Int, name: String, streamUrlString: String? = nil, batchIds: [Int] = []) {
        self.id = id
        self.name = name
        self.streamUrlString = streamUrlString
        self.batchIds = batchIds
    }
}

struct DebridCloudDownload: Hashable, Sendable {
    let id: String
    let fileName: String
    let link: String
}

struct DebridCloudMagnet: Hashable, Sendable, Identifiable {
    let id: String
    let fileName: String
    let status: String
    let hash: String
    let links: [String]
}

/// Model for tracking cloud download/magnet history
struct DebridCloudHistoryItem: Codable, Hashable, Identifiable {
    let id: String
    let providerId: String
    let kind: DebridTransferKind
    let name: String
    let linkOrHash: String
    let dateAdded: Date
    
    init(id: String, providerId: String, kind: DebridTransferKind, name: String, linkOrHash: String, dateAdded: Date = Date()) {
        self.id = id
        self.providerId = providerId
        self.kind = kind
        self.name = name
        self.linkOrHash = linkOrHash
        self.dateAdded = dateAdded
    }
    
    var historyKey: String {
        "\(providerId)_\(kind.rawValue)_\(id)"
    }
}

enum DebridTransferKind: String, Codable, Sendable {
    case torrent
    case webDownload
}

struct DebridTransferHandle: Hashable, Sendable {
    let id: String
    let kind: DebridTransferKind
}

struct DebridTransferFile: Hashable, Sendable {
    let id: String
    let name: String
    let path: String?
    let size: Int?
    let link: String?

    init(id: String, name: String, path: String? = nil, size: Int? = nil, link: String? = nil) {
        self.id = id
        self.name = name
        self.path = path
        self.size = size
        self.link = link
    }
}

struct DebridUnrestrictResult: Hashable, Sendable {
    let name: String
    let urlString: String
    let size: Int?
    let mimeType: String?
}

enum DebridError: Error {
    case InvalidUrl
    case InvalidPostBody
    case InvalidResponse
    case InvalidToken
    case EmptyData
    case EmptyUserMagnets
    case IsCaching
    case FailedRequest(description: String)
    case AuthQuery(description: String)
    case NotImplemented
}

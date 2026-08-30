//
//  TorBoxModels.swift
//  Ferrite
//
//  Created by Brian Dashore on 6/11/24.
//

import Foundation

extension TorBox {
    struct TBResponse<TBData: Decodable>: Decodable {
        let success: Bool
        let detail: String
        let data: TBData?

        enum CodingKeys: String, CodingKey {
            case success, detail, data
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            success = try container.decode(Bool.self, forKey: .success)
            detail = try container.decode(String.self, forKey: .detail)

            // TorBox's /torrents/mylist endpoint changes the shape of `data`
            // when an `id` filter is supplied: list requests return an array,
            // while `?id=<torrent_id>` returns one torrent object. Ferrite's
            // TorBox wrapper intentionally exposes both as an array to callers,
            // so normalize the single-object form here instead of letting the
            // entire download fail with Array-vs-dictionary DecodingError.
            if TBData.self == [MyTorrentListResponse].self,
               let singleTorrent = try? container.decode(MyTorrentListResponse.self, forKey: .data)
            {
                data = [singleTorrent] as? TBData
            } else {
                data = try container.decodeIfPresent(TBData.self, forKey: .data)
            }
        }
    }

    // MARK: - InstantAvailability

    enum InstantAvailabilityData: Codable {
        case links([InstantAvailabilityDataObject])
        case failure(InstantAvailabilityDataFailure)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            // Only continue if the data is a List which indicates a success
            if let linkArray = try? container.decode([InstantAvailabilityDataObject].self) {
                self = .links(linkArray)
            } else {
                let value = try container.decode(InstantAvailabilityDataFailure.self)
                self = .failure(value)
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case let .links(array):
                try container.encode(array)
            case let .failure(value):
                try container.encode(value)
            }
        }
    }

    struct InstantAvailabilityDataObject: Codable, Sendable {
        let name: String
        let size: Int
        let hash: String
        let files: [InstantAvailabilityFile]
    }

    struct InstantAvailabilityFile: Codable, Sendable {
        let name: String
        let size: Int
    }

    struct InstantAvailabilityDataFailure: Codable, Sendable {
        let data: Bool
    }

    struct CreateTorrentResponse: Codable, Sendable {
        let hash: String
        let torrentId: Int
        let authId: String

        enum CodingKeys: String, CodingKey {
            case hash
            case torrentId = "torrent_id"
            case authId = "auth_id"
        }
    }

    struct MyTorrentListResponse: Codable, Sendable {
        let id: Int
        let hash: String
        let name: String
        let downloadState: String
        let files: [MyTorrentListFile]

        enum CodingKeys: String, CodingKey {
            case id, hash, name, files
            case downloadState = "download_state"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(Int.self, forKey: .id)
            hash = try container.decode(String.self, forKey: .hash)
            name = try container.decode(String.self, forKey: .name)
            downloadState = try container.decode(String.self, forKey: .downloadState)
            // TorBox may return `files: null` for some torrent records. Treat that as
            // an empty file list so one record cannot make the entire /mylist response fail.
            files = try container.decodeIfPresent([MyTorrentListFile].self, forKey: .files) ?? []
        }
    }

    struct MyTorrentListFile: Codable, Sendable {
        let id: Int
        let hash: String
        let name: String
        let shortName: String

        enum CodingKeys: String, CodingKey {
            case id, hash, name
            case shortName = "short_name"
        }
    }

    typealias RequestDLResponse = String
    typealias RequestWebDLResponse = String

    struct ControlTorrentRequest: Codable, Sendable {
        let torrentId: String
        let operation: String

        enum CodingKeys: String, CodingKey {
            case operation
            case torrentId = "torrent_id"
        }
    }

    struct ControlWebDownloadRequest: Codable, Sendable {
        let webdownloadId: String
        let operation: String

        enum CodingKeys: String, CodingKey {
            case operation
            case webdownloadId = "webdownload_id"
        }
    }

    struct WebDownloadCreateResponse: Decodable, Sendable {
        let id: Int?

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let webdownloadId = try container.decodeIfPresent(Int.self, forKey: .webdownloadId) {
                id = webdownloadId
            } else if let webdlId = try container.decodeIfPresent(Int.self, forKey: .webdlId) {
                id = webdlId
            } else if let fallbackId = try container.decodeIfPresent(Int.self, forKey: .id) {
                id = fallbackId
            } else {
                id = nil
            }
        }

        enum CodingKeys: String, CodingKey {
            case webdownloadId = "webdownload_id"
            case webdlId = "webdl_id"
            case id
        }
    }

    struct WebDownloadListResponse: Decodable, Sendable {
        let id: Int?
        let name: String?
        let downloadState: String?
        let size: Int?
        let link: String?

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decodeIfPresent(Int.self, forKey: .id)
            name = try container.decodeIfPresent(String.self, forKey: .name)
                ?? container.decodeIfPresent(String.self, forKey: .fileName)
            downloadState = try container.decodeIfPresent(String.self, forKey: .downloadState)
                ?? container.decodeIfPresent(String.self, forKey: .state)
            size = try container.decodeIfPresent(Int.self, forKey: .size)
            link = try container.decodeIfPresent(String.self, forKey: .link)
                ?? container.decodeIfPresent(String.self, forKey: .download)
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case fileName = "file_name"
            case downloadState = "download_state"
            case state
            case size
            case link
            case download
        }
    }
}

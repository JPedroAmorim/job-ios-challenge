//
//  TileModel.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 26/11/22.
//

import Foundation

struct TileModel: Codable {
    let id: Int
    let name: String
    let posterImageURL: URL?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case image
    }

    enum ImageCodingKeys: String, CodingKey {
        case original
    }

    // MARK: - Encodable Conformance

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)

        var imageContainer = container.nestedContainer(keyedBy: ImageCodingKeys.self, forKey: .image)
        try imageContainer.encode(posterImageURL, forKey: .original)
    }

    // MARK: - Decodable Conformance

    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        let imageContainer = try? rootContainer.nestedContainer(keyedBy: ImageCodingKeys.self, forKey: .image)

        self.name = try rootContainer.decode(String.self, forKey: .name)
        self.id = try rootContainer.decode(Int.self, forKey: .id)
        self.posterImageURL = try imageContainer?.decode(URL.self, forKey: .original)
    }

    init(id: Int, name: String, posterImageURL: URL?) {
        self.id = id
        self.name = name
        self.posterImageURL = posterImageURL
    }
}

// MARK: - Extra Protocol Conformance

extension TileModel: Equatable, Identifiable { }

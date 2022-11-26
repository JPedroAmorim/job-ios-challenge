//
//  EpisodeModel.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 25/11/22.
//

import Foundation

struct EpisodeModel: Decodable, Identifiable {
    let id: Int
    let name: String
    let posterImageURL: URL
    let number: Int
    let season: Int
    let summary: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case image
        case number
        case season
        case summary
    }

    enum ImageCodingKeys: String, CodingKey {
        case medium
    }

    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        let imageContainer = try rootContainer.nestedContainer(keyedBy: ImageCodingKeys.self, forKey: .image)

        self.id = try rootContainer.decode(Int.self, forKey: .id)
        self.name = try rootContainer.decode(String.self, forKey: .name)
        self.posterImageURL = try imageContainer.decode(URL.self, forKey: .medium)
        self.number = try rootContainer.decode(Int.self, forKey: .number)
        self.season = try rootContainer.decode(Int.self, forKey: .season)
        self.summary = try rootContainer.decode(String.self, forKey: .summary)
    }
}

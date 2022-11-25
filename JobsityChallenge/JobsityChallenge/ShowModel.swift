//
//  ShowModel.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 25/11/22.
//

import Foundation

struct ShowModel: Decodable, Identifiable {
    let id: Int
    let name: String
    let posterImageURL: URL

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case image
    }

    enum ImageCodingKeys: String, CodingKey {
        case medium
    }

    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        let imageContainer = try rootContainer.nestedContainer(keyedBy: ImageCodingKeys.self, forKey: .image)

        self.name = try rootContainer.decode(String.self, forKey: .name)
        self.id = try rootContainer.decode(Int.self, forKey: .id)
        self.posterImageURL = try imageContainer.decode(URL.self, forKey: .medium)
    }
}

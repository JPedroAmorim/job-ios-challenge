//
//  PersonDetailsModel.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 27/11/22.
//

import Foundation

struct PersonDetailsModel: Decodable {
    let show: TileModel

    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
    }

    enum EmbeddedCodingKeys: String, CodingKey {
        case show
    }

    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        let embeddedContainer = try rootContainer.nestedContainer(keyedBy: EmbeddedCodingKeys.self, forKey: .embedded)
        self.show = try embeddedContainer.decode(TileModel.self, forKey: .show)
    }
}

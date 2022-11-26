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
    let genres: [String]
    let airTime: String
    let airDays: [String]
    let summary: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case image
        case genres
        case schedule
        case summary
    }

    enum ImageCodingKeys: String, CodingKey {
        case original
    }

    enum ScheduleCodingKeys: String, CodingKey {
        case time
        case days
    }

    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        let imageContainer = try rootContainer.nestedContainer(keyedBy: ImageCodingKeys.self, forKey: .image)
        let scheduleCotnainer = try rootContainer.nestedContainer(keyedBy: ScheduleCodingKeys.self, forKey: .schedule)

        self.name = try rootContainer.decode(String.self, forKey: .name)
        self.id = try rootContainer.decode(Int.self, forKey: .id)
        self.posterImageURL = try imageContainer.decode(URL.self, forKey: .original)
        self.genres = try rootContainer.decode([String].self, forKey: .genres)
        self.airTime = try scheduleCotnainer.decode(String.self, forKey: .time)
        self.airDays = try scheduleCotnainer.decode([String].self, forKey: .days)
        self.summary = try rootContainer.decode(String.self, forKey: .summary)
    }

    init(
        id: Int,
        name: String,
        posterImageURL: URL,
        genres: [String],
        airTime: String,
        airDays: [String],
        summary: String
    ) {
        self.id = id
        self.name = name
        self.posterImageURL = posterImageURL
        self.genres = genres
        self.airTime = airTime
        self.airDays = airDays
        self.summary = summary
    }
}

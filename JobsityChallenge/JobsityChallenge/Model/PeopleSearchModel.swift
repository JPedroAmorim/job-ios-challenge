//
//  PeopleSearchModel.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 27/11/22.
//

import Foundation

struct PeopleSearchModel: Decodable {
    let score: Double
    let person: TileModel
}

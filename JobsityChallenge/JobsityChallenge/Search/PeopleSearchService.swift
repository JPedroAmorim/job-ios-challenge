//
//  PeopleSearchService.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 27/11/22.
//

import Foundation

class PeopleSearchService: BaseSearchService, SearchServiceProtocol {
    func getTiles(for searchTerm: String) async throws -> [TileModel] {
        let sanitizedSearchTerm = try sanitizeSearchTerm(searchTerm: searchTerm)

        let endpointSuffix = "search/people?q=\(sanitizedSearchTerm)"

        let fetchedData = try await fetch(using: endpointSuffix, decoding: PeopleSearchModel.self)

        let people = fetchedData.map { $0.person }

        return people
    }
}

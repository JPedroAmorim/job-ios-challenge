//
//  ShowSearchService.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 27/11/22.
//

import Foundation

class ShowSearchService: BaseSearchService, SearchServiceProtocol {
    func getTiles(for searchTerm: String) async throws -> [TileModel] {
        let sanitizedSearchTerm = try sanitizeSearchTerm(searchTerm: searchTerm)

        let fetchedData = try await fetch(using: sanitizedSearchTerm, decoding: ShowSearchModel.self)

        let shows = fetchedData.map { $0.show }

        return shows
    }
}

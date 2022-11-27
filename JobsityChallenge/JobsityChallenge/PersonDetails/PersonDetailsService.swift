//
//  PersonDetailsService.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 27/11/22.
//

import Foundation

protocol PersonDetailsServiceProtocol {
    func getShows(for personId: String) async throws -> [TileModel]
}

struct PersonDetailsService: PersonDetailsServiceProtocol {
    func getShows(for personId: String) async throws -> [TileModel] {
        let endpointSuffix = "people/\(personId)/castcredits?embed=show"

        guard let url = URL(string: Environment.baseEndpoint + endpointSuffix) else {
            throw PersonDetailsServiceError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        let fetchedData = try JSONDecoder().decode([PersonDetailsModel].self, from: data)

        let shows = fetchedData.map { $0.show }

        return shows
    }
}

extension PersonDetailsService {
    enum PersonDetailsServiceError: Error {
        case invalidURL
    }
}

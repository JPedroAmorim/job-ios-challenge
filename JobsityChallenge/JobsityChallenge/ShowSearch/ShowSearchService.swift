//
//  ShowSearchService.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 27/11/22.
//

import Foundation

protocol ShowSearchServiceProtocol {
    func getShows(for searchTerm: String) async throws -> [ShowTileModel]
}

struct ShowSearchService: ShowSearchServiceProtocol {
    func getShows(for searchTerm: String) async throws -> [ShowTileModel] {
        guard let sanitizedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw ShowSearchServiceError.invalidURL
        }

        let endpointSuffix = "search/shows?q=\(sanitizedSearchTerm)"

        guard let url = URL(string: Environment.baseEndpoint + endpointSuffix) else {
            throw ShowSearchServiceError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        guard let fetchedData = try? JSONDecoder().decode([SearchShowModel].self, from: data) else {
            return []
        }

        let shows = fetchedData.map { $0.show }

        return shows
    }
}

extension ShowSearchService {
    enum ShowSearchServiceError: Error {
        case invalidURL
    }
}

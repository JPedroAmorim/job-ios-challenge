//
//  SearchService.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 27/11/22.
//

import Foundation

protocol SearchServiceProtocol {
    func getShows(for searchTerm: String) async throws -> [TileModel]
}

struct SearchService: SearchServiceProtocol {
    func getShows(for searchTerm: String) async throws -> [TileModel] {
        guard let sanitizedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw SearchServiceError.invalidURL
        }

        let endpointSuffix = "search/shows?q=\(sanitizedSearchTerm)"

        guard let url = URL(string: Environment.baseEndpoint + endpointSuffix) else {
            throw SearchServiceError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        guard let fetchedData = try? JSONDecoder().decode([SearchShowModel].self, from: data) else {
            return []
        }

        let shows = fetchedData.map { $0.show }

        return shows
    }
}

extension SearchService {
    enum SearchServiceError: Error {
        case invalidURL
    }
}

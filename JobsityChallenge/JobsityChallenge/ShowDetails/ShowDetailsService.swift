//
//  ShowDetailsService.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 25/11/22.
//

import Foundation

protocol ShowDetailsServiceProtocol {
    func getEpisodes(for showId: String) async throws -> [EpisodeModel]
}

struct ShowDetailsService: ShowDetailsServiceProtocol {
    func getEpisodes(for showId: String) async throws -> [EpisodeModel] {
        let endpointSuffix = "shows/\(showId)/episodes"

        guard let url = URL(string: Environment.baseEndpoint + endpointSuffix) else {
            throw ShowDetailsServiceError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        let episodes = try JSONDecoder().decode([EpisodeModel].self, from: data)
        return episodes
    }
}

extension ShowDetailsService {
    enum ShowDetailsServiceError: Error {
        case invalidURL
    }
}

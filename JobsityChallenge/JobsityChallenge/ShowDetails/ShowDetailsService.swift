//
//  ShowDetailsService.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 25/11/22.
//

import Foundation

protocol ShowDetailsServiceProtocol {
    func getShowAndEpisodes(for showId: String) async throws -> ShowDetailsService.Payload
}

struct ShowDetailsService: ShowDetailsServiceProtocol {
    func getShowAndEpisodes(for showId: String) async throws -> Payload {
        let show = try await fetch(for: "shows/\(showId)", decoding: ShowModel.self)
        let episodes = try await fetch(for: "shows/\(showId)/episodes", decoding: [EpisodeModel].self)

        return .init(show: show, episodes: episodes)
    }

    private func fetch<T: Decodable>(for endpointSuffix: String, decoding: T.Type) async throws -> T {
        guard let url = URL(string: Environment.baseEndpoint + endpointSuffix) else {
            throw ShowDetailsServiceError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        let show = try JSONDecoder().decode(T.self, from: data)
        return show
    }
}

extension ShowDetailsService {
    enum ShowDetailsServiceError: Error {
        case invalidURL
    }
}

extension ShowDetailsService {
    struct Payload {
        let show: ShowModel
        let episodes: [EpisodeModel]
    }
}

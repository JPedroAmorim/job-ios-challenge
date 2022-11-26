//
//  ShowListingService.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 25/11/22.
//

import Foundation

protocol ShowListingServiceProtocol {
    func getShows() async throws -> [ShowModel]
}

struct ShowListingService: ShowListingServiceProtocol {
    enum ShowListingServiceError: Error {
        case invalidURL
    }

    func getShows() async throws -> [ShowModel] {
        // TODO: Implement pagination
        let endpointSuffix = "shows?page=0"

        guard let url = URL(string: Environment.baseEndpoint + endpointSuffix) else {
            throw ShowListingServiceError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        let shows = try JSONDecoder().decode([ShowModel].self, from: data)
        return shows
    }
}

//
//  ShowListingService.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 25/11/22.
//

import Foundation

protocol ShowListingServiceProtocol {
    func getShows() async throws -> [ShowTileModel]
}

class ShowListingService: ShowListingServiceProtocol {
    private var pageCount = 0
    private var shows: [ShowTileModel] = []

    func getShows() async throws -> [ShowTileModel] {
        let endpointSuffix = "shows?page=\(pageCount)"

        pageCount += 1

        guard let url = URL(string: Environment.baseEndpoint + endpointSuffix) else {
            throw ShowListingServiceError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        // Per documentation, TV Maze API will return a 404 when the end of the list is reached
        guard let response = response as? HTTPURLResponse, response.statusCode != 404 else {
            return shows
        }

        // Protection against corrupted data from server-side
        guard let fetchedShows = try? JSONDecoder().decode([ShowTileModel].self, from: data) else {
            throw ShowListingServiceError.corruptedPage
        }

        shows += fetchedShows

        return shows
    }
}

extension ShowListingService {
    enum ShowListingServiceError: Error {
        case invalidURL
        case corruptedPage
    }
}

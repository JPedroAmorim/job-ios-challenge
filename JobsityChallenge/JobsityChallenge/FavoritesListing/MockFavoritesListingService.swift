//
//  MockFavoritesListingService.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 27/11/22.
//

import Foundation

struct MockFavoritesListingService: FavoritesListingServiceProtocol {
    private static func getMockShows() throws -> [ShowTileModel] {
        guard
            let posterURL = URL(string: "https://static.tvmaze.com/uploads/images/medium_landscape/1/4388.jpg")
        else {
            throw MockFavoritesListingServiceError.invalidURL
        }

        return [
            .init(id: 0, name: "Sample Show #1", posterImageURL: posterURL),
            .init(id: 1, name: "Sample Show #2", posterImageURL: posterURL)
        ]
    }

    func getFavoriteShows() throws -> [ShowTileModel] {
        return try Self.getMockShows()
    }

    func saveShow(show: ShowTileModel) throws {
        // no-op
    }

    func removeFromFavorites(show: ShowTileModel) throws {
        // no-op
    }

    func isFavorite(show: ShowTileModel) throws -> Bool {
        return true
    }

    private func save(shows: [ShowTileModel]) throws {
        // no-op
    }
}

extension MockFavoritesListingService {
    enum MockFavoritesListingServiceError: Error {
        case invalidURL
    }
}

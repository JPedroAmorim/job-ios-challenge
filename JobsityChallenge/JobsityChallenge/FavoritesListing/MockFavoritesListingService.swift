//
//  MockFavoritesListingService.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 27/11/22.
//

import Foundation

struct MockFavoritesListingService: FavoritesListingServiceProtocol {
    private static func getMockShows() throws -> [TileModel] {
        return [
            .init(id: 0, name: "Sample Show #1", posterImageURL: URL.sampleURL()),
            .init(id: 1, name: "Sample Show #2", posterImageURL: URL.sampleURL())
        ]
    }

    func getFavoriteShows() throws -> [TileModel] {
        return try Self.getMockShows()
    }

    func saveShow(show: TileModel) throws {
        // no-op
    }

    func removeFromFavorites(show: TileModel) throws {
        // no-op
    }

    func isFavorite(show: TileModel) throws -> Bool {
        return true
    }

    private func save(shows: [TileModel]) throws {
        // no-op
    }
}

extension MockFavoritesListingService {
    enum MockFavoritesListingServiceError: Error {
        case invalidURL
    }
}

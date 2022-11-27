//
//  FavoritesListingService.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 27/11/22.
//

import Foundation

protocol FavoritesListingServiceProtocol {
    func saveShow(show: TileModel) throws
    func getFavoriteShows() throws -> [TileModel]
    func removeFromFavorites(show: TileModel) throws
    func isFavorite(show: TileModel) throws -> Bool
}

struct FavoritesListingService: FavoritesListingServiceProtocol {
    private static let favoritesKey = "favorites"
    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()

    private let storage: UserDefaults

    init(storage: UserDefaults = UserDefaults.standard) {
        self.storage = storage
    }

    func getFavoriteShows() throws -> [TileModel] {
        guard let data = storage.data(forKey: Self.favoritesKey) else {
            // No entries yet, initialize with an empty array
            let shows: [TileModel] = []
            let showsData = try Self.encoder.encode(shows)
            storage.set(showsData, forKey: Self.favoritesKey)

            return []
        }

        let shows = try Self.decoder.decode([TileModel].self, from: data)

        return shows
    }

    func saveShow(show: TileModel) throws {
        var shows = try getFavoriteShows()
        shows += [show]
        try save(shows: shows)
    }

    func removeFromFavorites(show: TileModel) throws {
        var shows = try getFavoriteShows()
        shows.removeAll(where: { $0 == show })
        try save(shows: shows)
    }

    func isFavorite(show: TileModel) throws -> Bool {
        let shows = try getFavoriteShows()
        return shows.contains(where: { $0 == show })
    }

    private func save(shows: [TileModel]) throws {
        let showsData = try Self.encoder.encode(shows)
        storage.set(showsData, forKey: Self.favoritesKey)
    }
}

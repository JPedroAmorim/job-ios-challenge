//
//  JobsityChallengeTests.swift
//  JobsityChallengeTests
//
//  Created by João Pedro de Amorim on 25/11/22.
//

import XCTest
@testable import JobsityChallenge

final class JobsityChallengeTests: XCTestCase {
    private var userDefaults: UserDefaults = {
        guard let userDefaults = UserDefaults(suiteName: #file) else {
            fatalError("Unable to set mock UserDefaults for testing")
        }

        return userDefaults
    }()

    private let testTileModel: TileModel = .init(id: 0, name: "Test", posterImageURL: URL.sampleURL())

    override func setUp() async throws {
        userDefaults.removePersistentDomain(forName: #file)
    }

    func testShowModelDecoding_whenPassedValidJSON_shouldSuccessfullyDecode() {
        testDecoding(for: "ShowResponseFixture", decoding: ShowModel.self)
    }

    func testEpisodeModelDecoding_whenPassedValidJSON_shouldSuccessfullyDecode() {
        testDecoding(for: "EpisodesResponseFixture", decoding: [EpisodeModel].self)
    }

    func testTileModelDecoding_whenPassedValidJSON_shouldSuccessfullyDecode() {
        testDecoding(for: "ShowsResponseFixture", decoding: [TileModel].self)
    }

    func testFavoritesListingService_whenFetchingForTheFirstTime_returnsEmptyArray() {
        // Given
        let service = FavoritesListingService(storage: userDefaults)

        // When
        do {
            let result = try service.getFavoriteShows()

            // Then
            XCTAssertEqual(result, [])
        } catch {
            XCTFail("Unable to get favorite shows Error(\(String(describing: error)))")
        }
    }

    func testFavoritesListingService_whenSave_doesNotThrow() {
        // Given
        let service = FavoritesListingService(storage: userDefaults)

        // When
        do {
            try service.saveShow(show: testTileModel)
            // Then (no throw = Success)
        } catch {
            XCTFail("Unable to save show Error(\(String(describing: error)))")
        }
    }

    func testFavoritesListingService_whenGet_returnsCorrectly() {
        // Given
        let service = FavoritesListingService(storage: userDefaults)

        // When
        do {
            try service.saveShow(show: testTileModel)
            let result = try service.getFavoriteShows()

            // Then
            XCTAssertEqual(result, [testTileModel])
        } catch {
            XCTFail("Unable to get show Error(\(String(describing: error)))")
        }
    }

    func testFavoritesListingService_whenRemove_returnsCorrectly() {
        // Given
        let service = FavoritesListingService(storage: userDefaults)

        // When
        do {
            try service.saveShow(show: testTileModel)
            try service.removeFromFavorites(show: testTileModel)
            let result = try service.getFavoriteShows()

            // Then
            XCTAssertEqual(result, [])
        } catch {
            XCTFail("Unable to delete show Error(\(String(describing: error)))")
        }
    }

    func testFavoritesListingService_whenIsFavorite_returnsCorrectly() {
        // Given
        let service = FavoritesListingService(storage: userDefaults)

        // When
        do {
            try service.saveShow(show: testTileModel)
            let result = try service.isFavorite(show: testTileModel)

            // Then
            XCTAssertTrue(result)
        } catch {
            XCTFail("Unable to determine if show is in favorites list Error(\(String(describing: error)))")
        }
    }
}

// MARK: - Helper Methods

extension JobsityChallengeTests {
    private func testDecoding<T: Decodable>(for fixture: String, decoding: T.Type) {
        let decoder = JSONDecoder()
        let fixtureData = getFixtureData(for: fixture)

        do {
            _ = try decoder.decode(T.self, from: fixtureData)
        } catch {
            XCTFail("Decoding failed with error Error(\(String(describing: error)))")
        }
    }

    private func getFixtureData(for filename: String) -> Data {
        guard let path = Bundle(for: type(of: self)).path(forResource: filename, ofType: "json") else {
            fatalError("\(filename).json not found in the test bundle")
        }

        guard let jsonString = try? String(contentsOfFile: path, encoding: .utf8) else {
            fatalError("Unable to convert \(filename).json to String")
        }

        guard let jsonData = jsonString.data(using: .utf8) else {
            fatalError("Unable to convert \(filename).json to Data")
        }

        return jsonData
    }
}

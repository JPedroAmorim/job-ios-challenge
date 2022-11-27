//
//  JobsityChallengeTests.swift
//  JobsityChallengeTests
//
//  Created by João Pedro de Amorim on 25/11/22.
//

import XCTest
@testable import JobsityChallenge

final class JobsityChallengeTests: XCTestCase {
    func testShowModelDecoding_whenPassedValidJSON_shouldSuccessfullyDecode() {
        testDecoding(for: "ShowResponseFixture", decoding: ShowModel.self)
    }

    func testEpisodeModelDecoding_whenPassedValidJSON_shouldSuccessfullyDecode() {
        testDecoding(for: "EpisodesResponseFixture", decoding: [EpisodeModel].self)
    }

    func testShowTileModelDecoding_whenPassedValidJSON_shouldSuccessfullyDecode() {
        testDecoding(for: "ShowsResponseFixture", decoding: [ShowTileModel].self)
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
            XCTFail("Decoding failed with error \(String(describing: error))")
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

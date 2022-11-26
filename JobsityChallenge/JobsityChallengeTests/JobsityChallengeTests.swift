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
        let decoder = JSONDecoder()
        let fixtureData = getFixtureData(for: "ShowsResponseFixture")

        do {
            _ = try decoder.decode([ShowModel].self, from: fixtureData)
        } catch {
            XCTFail("Decoding failed with error \(String(describing: error))")
        }
    }

    func testEpisodeModelDecoding_whenPassedValidJSON_shouldSuccessfullyDecode() {
        let decoder = JSONDecoder()
        let fixtureData = getFixtureData(for: "EpisodesResponseFixture")

        do {
            _ = try decoder.decode([EpisodeModel].self, from: fixtureData)
        } catch {
            XCTFail("Decoding failed with error \(String(describing: error))")
        }
    }
}

extension JobsityChallengeTests {
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

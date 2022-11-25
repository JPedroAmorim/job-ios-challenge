//
//  JobsityChallengeTests.swift
//  JobsityChallengeTests
//
//  Created by João Pedro de Amorim on 25/11/22.
//

import XCTest
@testable import JobsityChallenge

final class JobsityChallengeTests: XCTestCase {
    private var jsonShowsResponseData: Data {
        guard let path = Bundle(for: type(of: self)).path(forResource: "ShowsResponseFixture", ofType: "json") else {
            fatalError("ShowsResponseFixture.json not found in the test bundle")
        }

        guard let jsonString = try? String(contentsOfFile: path, encoding: .utf8) else {
            fatalError("Unable to convert ShowResponseFixture.json to String")
        }

        guard let jsonData = jsonString.data(using: .utf8) else {
            fatalError("Unable to convert UnitTestData.json to Data")
        }
        return jsonData
    }

    func testShowModelDecoding_whenPassedValidJSON_shouldSuccessfullyDecode() {
        let decoder = JSONDecoder()

        do {
            _ = try decoder.decode([ShowModel].self, from: jsonShowsResponseData)
        } catch {
            XCTFail("Decoding failed with error \(String(describing: error))")
        }
    }
}

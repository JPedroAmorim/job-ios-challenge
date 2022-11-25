//
//  Environment.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 25/11/22.
//

import Foundation

enum Environment {
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Unable to retrieve main bundle's info dictionary")
        }

        return dict
    }()

    private static func retrieveKey(key: String) -> String {
        guard let retrievedKey = infoDictionary[key] as? String else {
            fatalError("Unable to retrieve \(key) from main bundle's info dictionary")
        }

        return retrievedKey
    }

    static let baseEndpoint = retrieveKey(key: "BaseEndpoint")
}

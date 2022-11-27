//
//  BaseSearchServiceProtocol.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 27/11/22.
//

import Foundation

class BaseSearchService {
    func sanitizeSearchTerm(searchTerm: String) throws -> String {
        guard let sanitizedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw BaseSearchServiceError.invalidURL
        }

        return sanitizedSearchTerm
    }

    func fetch<T: Decodable>(using endpointSuffix: String, decoding: T.Type) async throws -> [T] {
        guard let url = URL(string: Environment.baseEndpoint + endpointSuffix) else {
            throw BaseSearchServiceError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        let fetchedData = try JSONDecoder().decode([T].self, from: data)

        return fetchedData
    }
}

extension BaseSearchService {
    enum BaseSearchServiceError: Error {
        case invalidURL
    }
}

//
//  SearchServiceProtocol.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 27/11/22.
//

import Foundation

protocol SearchServiceProtocol {
    func getTiles(for searchTerm: String) async throws -> [TileModel]
}

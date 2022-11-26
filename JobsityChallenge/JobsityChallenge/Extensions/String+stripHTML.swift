//
//  String+stripHTML.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 25/11/22.
//

import Foundation

extension String {
    func stripHTML() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
}

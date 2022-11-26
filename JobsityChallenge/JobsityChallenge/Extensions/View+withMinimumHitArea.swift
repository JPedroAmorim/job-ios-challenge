//
//  View+withMinimumHitArea.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 26/11/22.
//

import SwiftUI

extension View {
    func withMinimumHitArea(width: CGFloat = 44, height: CGFloat = 44) -> some View {
        frame(minWidth: width, minHeight: height)
            .contentShape(Rectangle())
    }
}

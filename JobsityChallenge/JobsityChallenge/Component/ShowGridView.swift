//
//  ShowGridView.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 27/11/22.
//

import SwiftUI

struct ShowGridView<Content: View>: View {
    let content: () -> Content

    private var gridItems: [GridItem] {
        Array(repeating: .init(.flexible()), count: Constants.numberOfRows)
    }

    var body: some View {
        LazyVGrid(columns: gridItems) {
            content()
        }
    }
}

extension ShowGridView {
    enum Constants {
        // Static stored properties are not supported in Generic types, so it can't be a let constant
        static var numberOfRows: Int { 3 }
    }
}

struct ShowGridView_Previews: PreviewProvider {
    static let rectangleDimensions: CGSize = .init(width: 50, height: 50)

    static var previews: some View {
        ShowGridView {
            Rectangle()
                .frame(width: rectangleDimensions.width, height: rectangleDimensions.height)
                .foregroundColor(.red)
        }
    }
}

//
//  PosterImage.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 27/11/22.
//

import SwiftUI

struct TileView: View {
    let model: TileModel
    let onTap: (TileModel) -> Void

    var body: some View {
        VStack(spacing: Constants.spacing) {
            PosterImage(url: model.posterImageURL, contentMode: .fit)
                .frame(width: Constants.posterImageDimensions.width, height: Constants.posterImageDimensions.height)
            Text(model.name)
                .fontWeight(.thin)
                .lineLimit(Constants.lineLimit)
        }
        .onTapGesture {
            onTap(model)
        }
    }
}

extension TileView {
    enum Constants {
        static let spacing: CGFloat = 10
        static let lineLimit: Int = 1
        static let posterImageDimensions: CGSize = .init(width: 120, height: 120)
    }
}

struct TileView_Previews: PreviewProvider {
    static let debugTile: TileModel = .init(id: 0, name: "SampleShow", posterImageURL: URL.sampleURL())
    static var previews: some View {
        TileView(model: debugTile) { _ in }
    }
}

//
//  PosterImage.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 27/11/22.
//

import SwiftUI

struct ShowTileView: View {
    let show: ShowTileModel
    let onTap: (ShowTileModel) -> Void

    var body: some View {
        VStack(spacing: Constants.spacing) {
            PosterImage(url: show.posterImageURL, contentMode: .fit)
                .frame(width: Constants.posterImageDimensions.width, height: Constants.posterImageDimensions.height)
            Text(show.name)
                .fontWeight(.thin)
                .lineLimit(Constants.lineLimit)
        }
        .onTapGesture {
            onTap(show)
        }
    }
}

extension ShowTileView {
    enum Constants {
        static let spacing: CGFloat = 10
        static let lineLimit: Int = 1
        static let posterImageDimensions: CGSize = .init(width: 120, height: 120)
    }
}

struct ShowTileView_Previews: PreviewProvider {
    static var debugShowTile: ShowTileModel? = {
        guard
            let posterURL = URL(string: "https://static.tvmaze.com/uploads/images/medium_portrait/1/4600.jpg")
        else {
            return nil
        }

        return .init(id: 0, name: "SampleShow", posterImageURL: posterURL)
    }()

    static var previews: some View {
        if let debugShowTile = debugShowTile {
            ShowTileView(show: debugShowTile) { _ in }
        }
    }
}

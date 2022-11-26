//
//  PosterImage.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 25/11/22.
//

import SwiftUI

struct PosterImage: View {
    let url: URL

    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .cornerRadius(Constants.cornerRadius)
        } placeholder: {
            Color.gray
        }
    }
}

extension PosterImage {
    enum Constants {
        static let cornerRadius: CGFloat = 20
    }
}

struct PosterImage_Previews: PreviewProvider {
    static var previews: some View {
        if let url = URL(string: "https://static.tvmaze.com/uploads/images/medium_portrait/1/4600.jpg") {
            PosterImage(url: url)
        }
    }
}

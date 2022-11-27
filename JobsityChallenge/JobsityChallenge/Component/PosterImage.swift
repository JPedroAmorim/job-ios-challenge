//
//  PosterImage.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 25/11/22.
//

import SwiftUI

struct PosterImage: View {
    let url: URL?
    let contentMode: ContentMode
    let cornerRadius: CGFloat

    init(url: URL?, contentMode: ContentMode = .fill, cornerRadius: CGFloat = .zero) {
        self.url = url
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        if let url = url {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .cornerRadius(cornerRadius)
            } placeholder: {
                Color.gray
            }
        } else {
            Color.gray
        }
    }
}

struct PosterImage_Previews: PreviewProvider {
    static var previews: some View {
        PosterImage(url: URL.sampleURL())
    }
}

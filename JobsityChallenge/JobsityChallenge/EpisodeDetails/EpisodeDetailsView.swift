//
//  EpisodeDetailsView.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 26/11/22.
//

import SwiftUI

struct EpisodeDetailsView: View {
    let episode: EpisodeModel

    var body: some View {
        VStack(spacing: Constants.elementSpacing) {
            PosterImage(url: episode.posterImageURL)
                .frame(width: Constants.posterImageDimensions.width, height: Constants.posterImageDimensions.height)
                .padding(.vertical, Constants.posterImagePadding)

            renderEpisodeInformation()
            Spacer()
        }
    }

    @ViewBuilder private func renderEpisodeInformation() -> some View {
        Text(episode.name)
            .font(.title)
        VStack(alignment: .leading, spacing: Constants.textElementSpacing) {
            Text("Number: \(episode.number)")
            Text("Season: \(episode.season)")
            Text("Summary: \(episode.summary.stripHTML())")
        }
        .font(.subheadline)
        .padding(.horizontal, Constants.textElementPadding)
    }
}

extension EpisodeDetailsView {
    enum Constants {
        static let elementSpacing: CGFloat = 10
        static let posterImageDimensions: CGSize = .init(width: 200, height: 20)
        static let posterImagePadding: CGFloat = 40
        static let textElementSpacing: CGFloat = 20
        static let textElementPadding: CGFloat = 30
    }
}

struct EpisodeDetailsView_Previews: PreviewProvider {
    static var debugEpisode: EpisodeModel? = {
        guard let sampleURL = URL(string: "https://static.tvmaze.com/uploads/images/medium_landscape/1/4388.jpg") else {
            return nil
        }

        return .init(id: 1, name: "Sample", posterImageURL: sampleURL, number: 2, season: 1, summary: "Sample Summary")
    }()

    static var previews: some View {
        if let debugEpisode = debugEpisode {
            EpisodeDetailsView(episode: debugEpisode)
        }
    }
}

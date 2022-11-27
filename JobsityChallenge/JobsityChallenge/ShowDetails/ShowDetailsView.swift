//
//  ShowDetailsView.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 25/11/22.
//

import SwiftUI

struct ShowDetailsView: View {
    @ObservedObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        switch viewModel.state {
        case .success(let data):
            renderShowDetails(viewData: data)
        case .loading:
            ProgressView()
        case .error(let error):
            Text("Unable to fetch show details with error(\(String(describing: error))")
        }
    }

    @ViewBuilder private func renderShowDetails(viewData: ViewModel.ViewData) -> some View {
        List {
            Section {
                VStack(spacing: Constants.elementSpacing) {
                    PosterImage(url: viewData.show.posterImageURL)
                        .frame(width: Constants.posterImageDimensions.width,
                               height: Constants.posterImageDimensions.height)
                        .padding(.vertical, Constants.posterImagePadding)
                    renderShowInformation(for: viewData.show)
                }
            }
            renderEpisodesBySeason(from: viewData.episodesBySeason)
        }
    }

    @ViewBuilder private func renderShowInformation(for show: ShowModel) -> some View {
        VStack(alignment: .leading, spacing: Constants.elementSpacing) {
            Text(show.name)
                .font(.title)
            Group {
                Text("Air time: \(show.airTime)")
                Text("Air days: \(show.airDays.joined(separator: Constants.separator))")
                Text("Genres: \(show.genres.joined(separator: Constants.separator))")
                Text("Summary: \(show.summary.stripHTML())")
            }
            .font(.caption)
        }
        .padding(.horizontal, Constants.textHorizontalPadding)
    }

    @ViewBuilder private func renderEpisodesBySeason(from episodesBySeason: ViewModel.EpisodesBySeason) -> some View {
        ForEach(episodesBySeason.keys.sorted(by: <), id: \.self) { season in
            Section("Season \(season)") {
                ForEach(episodesBySeason[season, default: []]) { episode in
                    renderEpisode(from: episode)
                }
            }
        }
    }

    @ViewBuilder private func renderEpisode(from episode: EpisodeModel) -> some View {
        Button(
            action: { viewModel.onTapEpisode(episode) },
            label: {
                Text(episode.name)
                    .foregroundColor(.black)
                    .withMinimumHitArea()
            })
    }
}

extension ShowDetailsView {
    class ViewModel: ObservableObject {
        @Published var state: State = .loading

        let show: ShowTileModel
        let onTapEpisode: (EpisodeModel) -> Void

        private let service: ShowDetailsServiceProtocol

        init(
            show: ShowTileModel,
            service: ShowDetailsServiceProtocol = ShowDetailsService(),
            onTapEpisode: @escaping (EpisodeModel) -> Void
        ) {
            self.show = show
            self.service = service
            self.onTapEpisode = onTapEpisode
            fetchData()
        }

        private func fetchData() {
            Task {
                do {
                    let data = try await service.getShowAndEpisodes(for: String(show.id))
                    handleSuccess(with: data)
                } catch {
                    handleError(error: error)
                }
            }
        }

        private func handleSuccess(with data: ShowDetailsService.Payload) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                let episodesBySeason = self.makeEpisodesBySeason(from: data.episodes)
                let viewData: ViewData = .init(show: data.show, episodesBySeason: episodesBySeason)
                self.state = .success(viewData)
            }
        }

        private func handleError(error: Error) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                self.state = .error(error)
            }
        }

        private func makeEpisodesBySeason(from episodes: [EpisodeModel]) -> EpisodesBySeason {
            return episodes.reduce(into: [:]) { acc, episode in
                acc[episode.season, default: []].append(episode)
            }
        }
    }
}

extension ShowDetailsView.ViewModel {
    struct ViewData {
        let show: ShowModel
        let episodesBySeason: EpisodesBySeason
    }
}

extension ShowDetailsView.ViewModel {
    typealias EpisodesBySeason = [Int: [EpisodeModel]]
}

extension ShowDetailsView.ViewModel {
    enum State {
        case success(ViewData)
        case loading
        case error(Error)
    }
}

extension ShowDetailsView {
    enum Constants {
        static let elementSpacing: CGFloat = 20
        static let separator: String = ", "
        static let posterImageDimensions: CGSize = .init(width: 110, height: 130)
        static let posterImagePadding: CGFloat = 30
        static let textHorizontalPadding: CGFloat = 20
    }
}

struct ShowDetailsView_Previews: PreviewProvider {
    static var debugShow: ShowTileModel? = {
        guard let sampleURL = URL(string: "https://static.tvmaze.com/uploads/images/medium_landscape/1/4388.jpg") else {
            return nil
        }

        return .init(id: 1, name: "Sample Show", posterImageURL: sampleURL)
    }()

    static var previews: some View {
        if let debugShow = debugShow {
            ShowDetailsView(
                viewModel: .init(show: debugShow, service: MockService()) { _ in }
            )
        }
    }
}

extension ShowDetailsView_Previews {
    struct MockService: ShowDetailsServiceProtocol {
        func getShowAndEpisodes(for showId: String) async throws -> ShowDetailsService.Payload {
            guard
                let posterURL = URL(string: "https://static.tvmaze.com/uploads/images/medium_portrait/1/4600.jpg")
            else {
                throw ShowDetailsService.ShowDetailsServiceError.invalidURL
            }

            let debugShow: ShowModel = .init(
                id: 0,
                name: "Sample Show",
                posterImageURL: posterURL,
                genres: ["Drama", "Horror"],
                airTime: "22h",
                airDays: ["Monday"],
                summary: "Sample Summary"
            )

            let debugEpisodes: [EpisodeModel] = [
                .init(id: 0, name: "Episode #1", posterImageURL: posterURL, number: 1, season: 1, summary: "Sample"),
                .init(id: 1, name: "Episode #2", posterImageURL: posterURL, number: 2, season: 1, summary: "Sample")
            ]

            return .init(show: debugShow, episodes: debugEpisodes)
        }
    }
}

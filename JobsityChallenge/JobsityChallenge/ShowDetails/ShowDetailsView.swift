//
//  ShowDetailsView.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 25/11/22.
//

import SwiftUI
import OSLog

struct ShowDetailsView: View {
    @ObservedObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        switch viewModel.state {
        case .success(let data):
            renderShowDetails(viewData: data)
                .alert(item: $viewModel.favoriteAlertInfo) { info in
                    Alert(title: Text(info.title), message: Text(info.message))
                }
        case .loading:
            ProgressView()
        case .error:
            ErrorStateView(onRetry: { viewModel.fetchData() })
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
            .font(.subheadline)

            renderFavoriteButton()
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
                    .withMinimumHitArea()
            })
    }

    @ViewBuilder private func renderFavoriteButton() -> some View {
        if viewModel.isShowFavorite {
            Button("Remove from favorites", action: handleRemoveShowFromFavorites)
        } else {
            Button("Add to favorites", action: handleSaveShowToFavorites)
        }
    }

    private func handleRemoveShowFromFavorites() {
        DispatchQueue.main.async {
            do {
                try viewModel.favoritesService.removeFromFavorites(show: viewModel.show)
                viewModel.favoriteAlertInfo = .init(title: "Success", message: "Removed show from favorites")
            } catch {
                viewModel.favoriteAlertInfo = .init(title: "Error", message: "Unable to remove show")
            }
        }
    }

    private func handleSaveShowToFavorites() {
        DispatchQueue.main.async {
            do {
                try viewModel.favoritesService.saveShow(show: viewModel.show)
                viewModel.favoriteAlertInfo = .init(title: "Success", message: "Added show to favorites")
            } catch {
                viewModel.favoriteAlertInfo = .init(title: "Error", message: "Unable to add show")
            }
        }
    }
}

extension ShowDetailsView {
    class ViewModel: ObservableObject {
        @Published var state: State = .loading
        @Published var favoriteAlertInfo: AlertInfo?

        let show: TileModel
        let onTapEpisode: (EpisodeModel) -> Void

        private let service: ShowDetailsServiceProtocol

        let favoritesService: FavoritesListingServiceProtocol

        var isShowFavorite: Bool {
            let isFavorite = try? favoritesService.isFavorite(show: show)
            return isFavorite ?? false
        }

        init(
            show: TileModel,
            service: ShowDetailsServiceProtocol = ShowDetailsService(),
            favoritesService: FavoritesListingServiceProtocol = FavoritesListingService(),
            onTapEpisode: @escaping (EpisodeModel) -> Void
        ) {
            self.show = show
            self.service = service
            self.favoritesService = favoritesService
            self.onTapEpisode = onTapEpisode
            fetchData()
        }

        func fetchData() {
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
                os_log(.debug, "ShowDetailsView error occurred Error(\(String(describing: error)))")
                self.state = .error
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
    struct AlertInfo: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }
}

extension ShowDetailsView.ViewModel {
    enum State {
        case success(ViewData)
        case loading
        case error
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
    static var debugShow: TileModel = .init(id: 0, name: "SampleShow", posterImageURL: URL.sampleURL())

    static var previews: some View {
        ShowDetailsView(
            viewModel: .init(
                show: debugShow,
                service: MockService(),
                favoritesService: MockFavoritesListingService()
            ) { _ in }
        )
    }
}

extension ShowDetailsView_Previews {
    struct MockService: ShowDetailsServiceProtocol {
        func getShowAndEpisodes(for showId: String) async throws -> ShowDetailsService.Payload {
            guard
                let posterURL = URL.sampleURL()
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

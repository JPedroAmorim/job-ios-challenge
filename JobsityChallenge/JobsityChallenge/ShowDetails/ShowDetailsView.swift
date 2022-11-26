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
            renderShowDetails(episodesBySeason: data)
        case .loading:
            ProgressView()
        case .error(let error):
            Text("Unable to fetch show details with error(\(String(describing: error))")
        }
    }

    @ViewBuilder private func renderShowDetails(episodesBySeason: ViewModel.EpisodesBySeason) -> some View {
        List {
            Section {
                VStack(spacing: Constants.elementSpacing) {
                    PosterImage(url: viewModel.show.posterImageURL)
                        .frame(width: Constants.posterImageDimensions.width,
                               height: Constants.posterImageDimensions.height)
                    renderShowInformation()
                }
            }
            renderEpisodesBySeason(from: episodesBySeason)
        }
    }

    @ViewBuilder private func renderShowInformation() -> some View {
        VStack(alignment: .leading, spacing: Constants.elementSpacing) {
            Text(viewModel.show.name)
                .font(.title)
            Group {
                Text("Air time: \(viewModel.show.airTime)")
                Text("Air days: \(viewModel.show.airDays.joined(separator: Constants.separator))")
                Text("Genres: \(viewModel.show.genres.joined(separator: Constants.separator))")
                Text("Summary: \(viewModel.show.summary.stripHTML())")
            }
            .font(.caption)
        }
        .padding(.horizontal, Constants.textHorizontalPadding)
    }

    @ViewBuilder private func renderEpisodesBySeason(from episodesBySeason: ViewModel.EpisodesBySeason) -> some View {
        ForEach(episodesBySeason.keys.sorted(by: <), id: \.self) { season in
            Section("Season \(season)") {
                ForEach(episodesBySeason[season, default: []]) { episode in
                    Text(episode.name)
                }
            }
        }
    }
}

extension ShowDetailsView {
    class ViewModel: ObservableObject {
        @Published var state: State = .loading

        let show: ShowModel
        private let service: ShowDetailsServiceProtocol

        init(show: ShowModel, service: ShowDetailsServiceProtocol = ShowDetailsService()) {
            self.show = show
            self.service = service
            fetchData()
        }

        private func fetchData() {
            Task {
                do {
                    let data = try await service.getEpisodes(for: String(show.id))
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }

                        let episodesBySeason = self.makeEpisodesBySeason(from: data)
                        self.state = .success(episodesBySeason)
                    }
                } catch {
                    state = .error(error)
                }
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
    typealias EpisodesBySeason = [Int: [EpisodeModel]]
}

extension ShowDetailsView.ViewModel {
    enum State {
        case success(EpisodesBySeason)
        case loading
        case error(Error)
    }
}

extension ShowDetailsView {
    enum Constants {
        static let elementSpacing: CGFloat = 20
        static let separator: String = ", "
        static let posterImageDimensions: CGSize = .init(width: 60, height: 60)
        static let textHorizontalPadding: CGFloat = 20
    }
}

struct ShowDetailsView_Previews: PreviewProvider {
    static var debugShow: ShowModel? = {
        guard let sampleURL = URL(string: "https://static.tvmaze.com/uploads/images/medium_landscape/1/4388.jpg") else {
            return nil
        }

        return .init(id: 1,
                     name: "Sample Show",
                     posterImageURL: sampleURL,
                     genres: ["Drama", "Horror"],
                     airTime: "22:00",
                     airDays: ["Monday", "Friday"],
                     summary: "Sample Summary")
    }()

    static var previews: some View {
        if let debugShow = Self.debugShow {
            ShowDetailsView(viewModel: .init(show: debugShow, service: MockService()))
        }
    }
}

extension ShowDetailsView_Previews {
    struct MockService: ShowDetailsServiceProtocol {
        func getEpisodes(for showId: String) async throws -> [EpisodeModel] {
            let json =
            """
             {
                "id": 1,
                "name": "Pilot",
                "season": 1,
                "image": {
                  "medium": "https://static.tvmaze.com/uploads/images/medium_landscape/1/4388.jpg",
                },
                "summary": "First Sample Summary"
              },
              {
                "id": 2,
                "name": "The Fire",
                "season": 1,
                "number": 2,
                "image": {
                  "medium": "https://static.tvmaze.com/uploads/images/medium_landscape/1/4389.jpg",
                },
                "summary": "Second Sample summary"
              }
            ]
            """

            guard let debug = try? JSONDecoder().decode([EpisodeModel].self, from: Data(json.utf8)) else {
                return []
            }

            return debug
        }
    }
}

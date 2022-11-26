//
//  ShowListingView.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 25/11/22.
//

import SwiftUI

struct ShowListingView: View {
    @ObservedObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        switch viewModel.state {
        case .success(let data):
            List {
                ForEach(data) { show in
                    renderCell(from: show)
                        .onTapGesture {
                            viewModel.onTapShow(show)
                        }
                }
            }
        case .loading:
            ProgressView()
        case .error(let error):
            Text("Unable to fetch shows with error(\(String(describing: error))")
        }
    }

    @ViewBuilder private func renderCell(from show: ShowModel) -> some View {
        HStack(spacing: Constants.cellSpacing) {
            PosterImage(url: show.posterImageURL)
                  .frame(width: Constants.posterImageDimensions.width, height: Constants.posterImageDimensions.height)
            Text(show.name)
        }
    }
}

extension ShowListingView {
    class ViewModel: ObservableObject {
        @Published var state: State = .loading

        let onTapShow: (ShowModel) -> Void
        private let service: ShowListingServiceProtocol

        init(service: ShowListingServiceProtocol = ShowListingService(), onTapShow: @escaping (ShowModel) -> Void) {
            self.service = service
            self.onTapShow = onTapShow
            fetchData()
        }

        private func fetchData() {
            Task {
                do {
                    let data = try await service.getShows()
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }

                        self.state = .success(data)
                    }
                } catch {
                    state = .error(error)
                }
            }
        }
    }
}

extension ShowListingView.ViewModel {
    enum State {
        case success([ShowModel])
        case loading
        case error(Error)
    }
}

extension ShowListingView {
    enum Constants {
        static let cellSpacing: CGFloat = 10
        static let cellCornerRadius: CGFloat = 20
        static let posterImageDimensions: CGSize = .init(width: 90, height: 80)
    }
}

struct ShowListingView_Previews: PreviewProvider {

    static var previews: some View {
        ShowListingView(
            viewModel: .init(service: MockService()) { _ in }
        )
    }
}

extension ShowListingView_Previews {
    struct MockService: ShowListingServiceProtocol {
        func getShows() async throws -> [ShowModel] {
            let json =
            """
            [
              {
                "id": 250,
                "name": "Kirby Buckets",
                "image": {
                  "medium": "https://static.tvmaze.com/uploads/images/medium_portrait/1/4600.jpg"
                },
                "genres": ["Comedy"],
                "schedule": { "time": "22:00", "days": ["Thursday"] },
                "summary": "Sample summary"
              },
              {
                "id": 251,
                "name": "Downton Abbey",
                "image": {
                  "medium": "https://static.tvmaze.com/uploads/images/medium_portrait/1/4601.jpg"
                },
                "genres": ["Drama"],
                "schedule": { "time": "22:00", "days": ["Friday"] },
                "summary": "Sample summary"
              }
            ]
            """

            guard let debug = try? JSONDecoder().decode([ShowModel].self, from: Data(json.utf8)) else {
                return []
            }

            return debug
        }
    }
}

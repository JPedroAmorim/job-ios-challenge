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
            ScrollView {
                renderGrid(from: data)
            }
            .navigationTitle("Shows")
        case .loading:
            ProgressView()
        case .error(let error):
            Text("Unable to fetch shows with error(\(String(describing: error))")
        }
    }

    @ViewBuilder private func renderGrid(from data: [ShowTileModel]) -> some View {
        ShowGridView {
            Group {
                ForEach(data) { show in
                    ShowTileView(show: show, onTap: viewModel.onTapShow)
                }
                // Fetch more shows when user reaches the end of the current data, creating an infinite scroll
                ProgressView()
                    .onAppear {
                        viewModel.fetchData()
                    }
            }
        }
    }
}

extension ShowListingView {
    class ViewModel: ObservableObject {
        @Published var state: State = .loading

        let onTapShow: (ShowTileModel) -> Void
        private let service: ShowListingServiceProtocol

        init(service: ShowListingServiceProtocol = ShowListingService(), onTapShow: @escaping (ShowTileModel) -> Void) {
            self.service = service
            self.onTapShow = onTapShow
            fetchData()
        }

        func fetchData() {
            Task {
                do {
                    let data = try await service.getShows()
                    handleSuccess(with: data)
                } catch {
                    handleError(error: error)
                }
            }
        }

        private func handleSuccess(with data: [ShowTileModel]) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                self.state = .success(data)
            }
        }

        private func handleError(error: Error) {
            if case .corruptedPage = error as? ShowListingService.ShowListingServiceError {
                // Go to next non-corrupted page after a throttling period
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + Constants.corruptedPageRequestThrottlePeriod
                ) { [weak self] in
                    guard let self = self else { return }
                    self.fetchData()
                }

                return
            }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                self.state = .error(error)
            }
        }
    }
}

extension ShowListingView.ViewModel {
    enum State {
        case success([ShowTileModel])
        case loading
        case error(Error)
    }
}

extension ShowListingView {
    enum Constants {
        static let corruptedPageRequestThrottlePeriod: TimeInterval = 0.75
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
        func getShows() async throws -> [ShowTileModel] {
            guard
                let posterURL = URL(string: "https://static.tvmaze.com/uploads/images/medium_portrait/1/4600.jpg")
            else {
                throw ShowListingService.ShowListingServiceError.invalidURL
            }

            return [
                .init(id: 0, name: "Sample Show #1", posterImageURL: posterURL),
                .init(id: 1, name: "Sample Show #2", posterImageURL: posterURL)
            ]
        }
    }
}

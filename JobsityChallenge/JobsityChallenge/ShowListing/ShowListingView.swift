//
//  ShowListingView.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 25/11/22.
//

import SwiftUI
import OSLog

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
        case .error:
            ErrorStateView(onRetry: viewModel.fetchData)
        }
    }

    @ViewBuilder private func renderGrid(from data: [TileModel]) -> some View {
        GridView {
            Group {
                ForEach(data) { show in
                    TileView(model: show, onTap: viewModel.onTapShow)
                }
                // Fetch more shows when user reaches the end of the current data, creating an infinite scroll
                ProgressView()
                    .onAppear(perform: viewModel.fetchData)
            }
        }
    }
}

extension ShowListingView {
    class ViewModel: ObservableObject {
        @Published private(set) var state: State = .loading

        let onTapShow: (TileModel) -> Void
        private let service: ShowListingServiceProtocol

        init(service: ShowListingServiceProtocol = ShowListingService(), onTapShow: @escaping (TileModel) -> Void) {
            self.service = service
            self.onTapShow = onTapShow
            fetchData()
        }

        func fetchData() {
            state = .loading

            Task {
                do {
                    let data = try await service.getShows()
                    handleSuccess(with: data)
                } catch {
                    handleError(error: error)
                }
            }
        }

        private func handleSuccess(with data: [TileModel]) {
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
                os_log(.debug, "ShowListingView error occurred Error(\(String(describing: error)))")
                self.state = .error
            }
        }
    }
}

extension ShowListingView.ViewModel {
    enum State {
        case success([TileModel])
        case loading
        case error
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
        func getShows() async throws -> [TileModel] {
            return [
                .init(id: 0, name: "Sample Show #1", posterImageURL: URL.sampleURL()),
                .init(id: 1, name: "Sample Show #2", posterImageURL: URL.sampleURL())
            ]
        }
    }
}

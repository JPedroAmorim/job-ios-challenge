//
//  ShowSearchView.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 27/11/22.
//

import Combine
import SwiftUI

struct ShowSearchView: View {
    @ObservedObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        renderSearchWrapper {
            renderBasedOnState()
        }
        .navigationTitle("Search")
    }

    @ViewBuilder private func renderSearchBar() -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .border(.gray)
            HStack {
                Image(systemName: Constants.searchSystemIconIdentifier)
                TextField("Search", text: $viewModel.searchTerm)
            }
            .foregroundColor(.gray)
            .padding(.leading, Constants.searchBarPadding)
        }
        .frame(height: Constants.searchBarHeight)
        .padding(.horizontal, Constants.searchBarPadding)
    }

    @ViewBuilder private func renderSearchWrapper<Content: View>(content: () -> Content) -> some View {
        VStack(spacing: Constants.wrapperSpacing) {
            renderSearchBar()
            content()
            Spacer()
        }
    }

    @ViewBuilder private func renderGrid(from data: [ShowTileModel]) -> some View {
        ShowGridView {
            ForEach(data) { show in
                ShowTileView(show: show, onTap: viewModel.onTapShow)
            }
        }
    }

    @ViewBuilder private func renderBasedOnState() -> some View {
        switch viewModel.state {
        case .idle:
            EmptyView()
        case .success(let data):
            ScrollView {
                renderGrid(from: data)
            }
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        case .error(let error):
            Text("Unable to fetch shows with error(\(String(describing: error))")
        }
    }
}

extension ShowSearchView {
    class ViewModel: ObservableObject {
        @Published var searchTerm: String = ""
        @Published var state: State = .idle

        let onTapShow: (ShowTileModel) -> Void
        private let service: ShowSearchServiceProtocol

        private var disposeBag = Set<AnyCancellable>()

        init(service: ShowSearchServiceProtocol = ShowSearchService(), onTapShow: @escaping (ShowTileModel) -> Void) {
            self.service = service
            self.onTapShow = onTapShow

            $searchTerm
                .dropFirst()
                .debounce(for: .seconds(Constants.searchDebouncePeriod), scheduler: RunLoop.main)
                .sink { [weak self] term in
                    guard let self = self else { return }
                    self.fetchData(for: term)
                }
                .store(in: &disposeBag)
        }

        func fetchData(for searchTerm: String) {
            guard !searchTerm.isEmpty else {
                self.state = .idle
                return
            }

            self.state = .loading

            Task {
                do {
                    let data = try await service.getShows(for: searchTerm)
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
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                self.state = .error(error)
            }
        }
    }
}

extension ShowSearchView.ViewModel {
    enum State {
        case idle
        case success([ShowTileModel])
        case loading
        case error(Error)
    }
}

extension ShowSearchView {
    enum Constants {
        static let searchDebouncePeriod: TimeInterval = 0.35
        static let searchSystemIconIdentifier = "magnifyingglass"
        static let searchBarPadding: CGFloat = 10
        static let searchBarHeight: CGFloat = 40
        static let wrapperSpacing: CGFloat = 20
    }
}

struct ShowSearchView_Previews: PreviewProvider {
    static var previews: some View {
        ShowSearchView(
            viewModel: .init(service: MockService()) { _ in }
        )
    }
}

extension ShowSearchView_Previews {
    struct MockService: ShowSearchServiceProtocol {
        func getShows(for searchTerm: String) async throws -> [ShowTileModel] {
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

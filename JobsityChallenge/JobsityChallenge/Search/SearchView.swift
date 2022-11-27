//
//  SearchView.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 27/11/22.
//

import Combine
import SwiftUI
import OSLog

struct SearchView: View {
    @ObservedObject private var viewModel: ViewModel
    @FocusState private var textFieldState: TextFieldState?

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
                    .focused($textFieldState, equals: .focused)
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
        .onTapGesture {
            textFieldState = nil // Dismiss keyboard on tap
        }
        .onDisappear {
            textFieldState = nil // Dismiss keyboard on view's dismissal
        }
    }

    @ViewBuilder private func renderGrid(from data: [TileModel]) -> some View {
        GridView {
            ForEach(data) { show in
                TileView(show: show, onTap: viewModel.onTapShow)
            }
        }
    }

    @ViewBuilder private func renderBasedOnState() -> some View {
        switch viewModel.state {
        case .idle:
            // Done in order to catch keyboard dismissal tap gesture
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .success(let data):
            ScrollView {
                renderGrid(from: data)
            }
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        case .error:
            ErrorStateView(onRetry: { viewModel.fetchData(for: viewModel.searchTerm) })
        }
    }
}

extension SearchView {
    class ViewModel: ObservableObject {
        @Published var searchTerm: String = ""
        @Published var state: State = .idle

        let onTapShow: (TileModel) -> Void
        private let service: SearchServiceProtocol

        private var disposeBag = Set<AnyCancellable>()

        init(service: SearchServiceProtocol = SearchService(), onTapShow: @escaping (TileModel) -> Void) {
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
                state = .idle
                return
            }

            state = .loading

            Task {
                do {
                    let data = try await service.getShows(for: searchTerm)
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
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                os_log(.debug, "SearchView error occurred Error(\(String(describing: error)))")
                self.state = .error
            }
        }
    }
}

extension SearchView.ViewModel {
    enum State {
        case idle
        case success([TileModel])
        case loading
        case error
    }
}

extension SearchView {
    enum Constants {
        static let searchDebouncePeriod: TimeInterval = 0.35
        static let searchSystemIconIdentifier = "magnifyingglass"
        static let searchBarPadding: CGFloat = 10
        static let searchBarHeight: CGFloat = 40
        static let wrapperSpacing: CGFloat = 20
    }
}

extension SearchView {
    enum TextFieldState: Hashable {
        case focused
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(
            viewModel: .init(service: MockService()) { _ in }
        )
    }
}

extension SearchView_Previews {
    struct MockService: SearchServiceProtocol {
        func getShows(for searchTerm: String) async throws -> [TileModel] {
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
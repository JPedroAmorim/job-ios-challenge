//
//  FavoritesListingView.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 27/11/22.
//

import SwiftUI
import OSLog

struct FavoritesListingView: View {
    @ObservedObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        renderBasedOnState()
            .onAppear {
                viewModel.fetchData()
            }
            .navigationTitle("Favorites")
    }

    @ViewBuilder private func renderBasedOnState() -> some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case .success(let favorites):
            renderFavorites(from: favorites)
        case .empty:
            Text(Constants.emptyListUserFriendlyMessage)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
        case .error:
            ErrorStateView(onRetry: { viewModel.fetchData() })
        }
    }

    @ViewBuilder private func renderFavorites(from favorites: ViewModel.FavoritesByAlphabeticalOrder) -> some View {
        ScrollView {
            GridView {
                ForEach(favorites.keys.sorted(by: <), id: \.self) { character in
                    Section(String(character)) {
                        ForEach(favorites[character, default: []]) { show in
                            TileView(model: show, onTap: viewModel.onTapShow)
                        }
                    }
                }
            }
        }
    }
}

extension FavoritesListingView {
    class ViewModel: ObservableObject {
        @Published var state: State = .loading

        let onTapShow: (TileModel) -> Void

        private let service: FavoritesListingServiceProtocol

        init(
            service: FavoritesListingServiceProtocol = FavoritesListingService(),
            onTapShow: @escaping (TileModel) -> Void
        ) {
            self.service = service
            self.onTapShow = onTapShow
            fetchData()
        }

        func fetchData() {
            state = .loading

            do {
                let shows = try service.getFavoriteShows()

                guard !shows.isEmpty else {
                    state = .empty
                    return
                }

                let favorites = makeFavoritesByAlphabeticalOrder(from: shows)
                state = .success(favorites)
            } catch {
                os_log(.debug, "FavoritesListingView error ocurred Error(\(String(describing: error)))")
                state = .error
            }
        }

        private func makeFavoritesByAlphabeticalOrder(from shows: [TileModel]) -> FavoritesByAlphabeticalOrder {
            return shows.reduce(into: [:]) { acc, show in
                if let firstCharacter = show.name.first {
                    acc[firstCharacter, default: []].append(show)
                }
            }
        }
    }
}

extension FavoritesListingView {
    enum Constants {
        static let emptyListUserFriendlyMessage = "You don't have favorites yet! :("
    }
}

extension FavoritesListingView.ViewModel {
    enum State {
        case success(FavoritesByAlphabeticalOrder)
        case loading
        case error
        case empty
    }
}

extension FavoritesListingView.ViewModel {
    typealias FavoritesByAlphabeticalOrder = [Character: [TileModel]]
}

struct FavoritesListingView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesListingView(viewModel: .init(service: MockFavoritesListingService()) { _ in })
    }
}

//
//  AppCoordinator.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 25/11/22.
//

import SwiftUI

class AppCoordinator {

    // MARK: - Properties

    private let tabBarController = UITabBarController()
    private lazy var onTapShow: (ShowTileModel) -> Void = { [weak self] show in
        guard let self = self else { return }
        self.navigateToShowDetails(for: show)
    }
    // MARK: - Public API

    var rootViewController: UIViewController {
        return tabBarController
    }

    private var currentNavigationController: UINavigationController? {
        tabBarController.selectedViewController as? UINavigationController
    }

    // MARK: - Methods

    func start() {
        let showListingController = setupShowListing()
        showListingController.tabBarItem = .init(tabBarSystemItem: .featured, tag: 0)

        let searchController = setupShowSearch()
        searchController.tabBarItem = .init(tabBarSystemItem: .search, tag: 1)

        let favoritesController = setupFavorites()
        favoritesController.tabBarItem = .init(tabBarSystemItem: .favorites, tag: 2)

        tabBarController.viewControllers = [showListingController, searchController, favoritesController]
    }

    func setupShowListing() -> UINavigationController {
        let navigationController = UINavigationController()

        let showListingViewModel: ShowListingView.ViewModel = .init(onTapShow: onTapShow)

        let showListingHostingController = UIHostingController(
            rootView: ShowListingView(viewModel: showListingViewModel)
        )

        navigationController.setViewControllers([showListingHostingController], animated: false)
        return navigationController
    }

    func setupShowSearch() -> UINavigationController {
        let navigationController = UINavigationController()

        let showSearchViewModel: ShowSearchView.ViewModel = .init(onTapShow: onTapShow)

        let showSearchHostingController = UIHostingController(rootView: ShowSearchView(viewModel: showSearchViewModel))

        navigationController.setViewControllers([showSearchHostingController], animated: false)
        return navigationController
    }

    private func setupFavorites() -> UINavigationController {
        let navigationController = UINavigationController()

        let favoritesViewModel: FavoritesListingView.ViewModel = .init(onTapShow: onTapShow)

        let favoritesHostingController = UIHostingController(
            rootView: FavoritesListingView(viewModel: favoritesViewModel)
        )

        navigationController.setViewControllers([favoritesHostingController], animated: false)
        return navigationController
    }

    func navigateToShowDetails(for show: ShowTileModel) {
        let onTapEpisode: (EpisodeModel) -> Void = { [weak self] episode in
            guard let self = self else { return }
            self.navigateToEpisodeDetails(for: episode)
        }

        let showDetailsViewModel: ShowDetailsView.ViewModel = .init(show: show, onTapEpisode: onTapEpisode)

        let showDetailsHostingController = UIHostingController(
            rootView: ShowDetailsView(viewModel: showDetailsViewModel)
        )

        currentNavigationController?.pushViewController(showDetailsHostingController, animated: true)
    }

    func navigateToEpisodeDetails(for episode: EpisodeModel) {
        let episodeDetailsHostingController = UIHostingController(rootView: EpisodeDetailsView(episode: episode))
        currentNavigationController?.pushViewController(episodeDetailsHostingController, animated: true)
    }
}

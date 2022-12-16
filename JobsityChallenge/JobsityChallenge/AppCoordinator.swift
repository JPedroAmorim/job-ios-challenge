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

    private lazy var onTapShow: (TileModel) -> Void = { [weak self] show in
        guard let self = self else { return }
        self.navigateToShowDetails(for: show)
    }

    private lazy var onTapPerson: (TileModel) -> Void = { [weak self] person in
        guard let self = self else { return }
        self.navigateToPersonDetails(for: person)
    }

    private var currentNavigationController: UINavigationController? {
        tabBarController.selectedViewController as? UINavigationController
    }

    // MARK: - Public API

    var rootViewController: UIViewController {
        return tabBarController
    }

    // MARK: - Methods

    func start() {
        let showListingController = setupShowListing()
        showListingController.tabBarItem = .init(tabBarSystemItem: .featured, tag: 0)

        let showSearchController = setupSearch(
            title: "Show Search",
            service: ShowSearchService(),
            onTapTile: onTapShow
        )
        showSearchController.tabBarItem = .init(tabBarSystemItem: .search, tag: 1)

        let peopleSearchController = setupSearch(
            title: "People Search",
            service: PeopleSearchService(),
            onTapTile: onTapPerson
        )
        peopleSearchController.tabBarItem = .init(tabBarSystemItem: .search, tag: 2)

        let favoritesController = setupFavorites()
        favoritesController.tabBarItem = .init(tabBarSystemItem: .favorites, tag: 3)

        tabBarController.viewControllers = [
            showListingController,
            showSearchController,
            peopleSearchController,
            favoritesController
        ]
    }

   private func setupShowListing() -> UINavigationController {
        let navigationController = UINavigationController()

        let showListingViewModel: ShowListingView.ViewModel = .init(onTapShow: onTapShow)

        let showListingHostingController = UIHostingController(
            rootView: ShowListingView(viewModel: showListingViewModel)
        )

        navigationController.setViewControllers([showListingHostingController], animated: false)
        return navigationController
    }

    private func setupSearch(
        title: String,
        service: SearchServiceProtocol,
        onTapTile: @escaping (TileModel) -> Void
    ) -> UINavigationController {
        let navigationController = UINavigationController()

        let searchViewModel: SearchView.ViewModel = .init(
            title: title,
            service: service,
            onTapTile: onTapTile
        )

        let searchHostingController = UIHostingController(rootView: SearchView(viewModel: searchViewModel))

        navigationController.setViewControllers([searchHostingController], animated: false)
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

    private func navigateToShowDetails(for show: TileModel) {
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

    private func navigateToEpisodeDetails(for episode: EpisodeModel) {
        let episodeDetailsHostingController = UIHostingController(rootView: EpisodeDetailsView(episode: episode))
        currentNavigationController?.pushViewController(episodeDetailsHostingController, animated: true)
    }

    private func navigateToPersonDetails(for person: TileModel) {
        let personDetailsViewModel = PersonDetailsView.ViewModel(person: person, onTapShow: onTapShow)

        let personDetailsHostingController = UIHostingController(
            rootView: PersonDetailsView(viewModel: personDetailsViewModel)
        )

        currentNavigationController?.pushViewController(personDetailsHostingController, animated: true)
    }
}

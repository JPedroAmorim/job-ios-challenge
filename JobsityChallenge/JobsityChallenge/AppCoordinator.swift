//
//  AppCoordinator.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 25/11/22.
//

import SwiftUI

class AppCoordinator {

    // MARK: - Properties

    private let navigationController = UINavigationController()

    // MARK: - Public API

    var rootViewController: UIViewController {
        return navigationController
    }

    // MARK: - Methods

    func start() {
        let onTapShow: (ShowModel) -> Void = { [weak self] show in
            guard let self = self else { return }
            self.navigateToShowDetails(for: show)
        }

        let showListingViewModel: ShowListingView.ViewModel = .init(onTapShow: onTapShow)

        let showListingHostingController = UIHostingController(
            rootView: ShowListingView(viewModel: showListingViewModel)
        )

        navigationController.setViewControllers([showListingHostingController], animated: false)
    }

    func navigateToShowDetails(for show: ShowModel) {
        let onTapEpisode: (EpisodeModel) -> Void = { [weak self] episode in
            guard let self = self else { return }
            self.navigateToEpisodeDetails(for: episode)
        }

        let showDetailsViewModel: ShowDetailsView.ViewModel = .init(show: show, onTapEpisode: onTapEpisode)

        let showDetailsHostingController = UIHostingController(
            rootView: ShowDetailsView(viewModel: showDetailsViewModel)
        )

        navigationController.pushViewController(showDetailsHostingController, animated: true)
    }

    func navigateToEpisodeDetails(for episode: EpisodeModel) {
        let episodeDetailsHostingController = UIHostingController(rootView: EpisodeDetailsView(episode: episode))
        navigationController.pushViewController(episodeDetailsHostingController, animated: true)
    }
}

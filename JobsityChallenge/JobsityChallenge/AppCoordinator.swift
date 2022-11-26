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
        let showListingHostingController = UIHostingController(rootView: ShowListingView(viewModel: .init()))
        navigationController.setViewControllers([showListingHostingController], animated: false)
    }
}

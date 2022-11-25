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
        let helloWorldViewController = UIHostingController(rootView: HelloWorldView())
        navigationController.setViewControllers([helloWorldViewController], animated: false)
    }
}

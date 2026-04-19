//
//  MainCoordinator.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - MainCoordinator

/// Управляет главным флоу приложения.
/// Создаёт три экрана (Progress, Today, Settings) и передаёт их в MainViewController.
/// MainViewController управляет переключением между ними через кастомный таб бар.
final class MainCoordinator: Coordinator {

    // MARK: - Public properties

    var onLogout: (() -> Void)?

    // MARK: - Private properties

    private let navigationController: UINavigationController

    // MARK: - Initialization

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

// MARK: - MainCoordinator + Coordinator

extension MainCoordinator {

    func start() {
        let mainViewController = buildMainViewController()
        mainViewController.onLogout = onLogout
        /// Переход без анимации — экран онбординга просто заменяется главным.
        navigationController.setViewControllers([mainViewController], animated: false)
    }
}

// MARK: - MainCoordinator + Setup

private extension MainCoordinator {

    /// Собирает MainViewController с тремя дочерними VC.
    /// Каждый VC получает свою ViewModel через протокол.
    func buildMainViewController() -> MainViewController {
        let progressVC = ProgressViewController(viewModel: ProgressViewModel())
        let todayVC = TodayViewController(viewModel: TodayViewModel())
        let settingsVC = SettingsViewController(viewModel: SettingsViewModel())

        return MainViewController(viewControllers: [progressVC, todayVC, settingsVC])
    }
}

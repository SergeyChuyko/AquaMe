//
//  AppCoordinator.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - AppCoordinator

/// Корневой координатор — единственная точка входа в навигацию приложения.
/// Решает, что показать первым: онбординг или главный экран.
/// Хранится в SceneDelegate, чтобы жить всё время жизни сцены.
final class AppCoordinator: Coordinator {

    // MARK: - Private properties

    private let window: UIWindow
    private let navigationController: UINavigationController

    // MARK: - Initialization

    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
        /// Скрываем стандартный nav bar — вся навигация управляется координаторами и кастомным UI.
        navigationController.setNavigationBarHidden(true, animated: false)
    }
}

// MARK: - AppCoordinator + Coordinator

extension AppCoordinator {

    func start() {
        /// Показываем экран приветствия — пользователь заполняет данные профиля.
        showGreeting()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}

// MARK: - AppCoordinator + Setup

private extension AppCoordinator {

    /// Показывает экран приветствия (заполнение профиля).
    /// Когда пользователь нажмёт Get Started — запустим главный флоу через showMain().
    func showGreeting() {
        let viewModel = GreetingViewModel()
        let viewController = GreetingViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }

    /// Запускает главный флоу с таб баром.
    /// В будущем: сначала проверять завершён ли онбординг (флаг в UserDefaults).
    func showMain() {
        let coordinator = MainCoordinator(navigationController: navigationController)
        coordinator.start()
    }
}

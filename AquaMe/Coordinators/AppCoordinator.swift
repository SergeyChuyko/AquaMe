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
        showAuth()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}

// MARK: - AppCoordinator + Setup

private extension AppCoordinator {

    func showAuth() {
        let viewModel = AuthViewModel()
        let viewController = AuthViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }

    /// Показывает экран онбординга.
    /// Устанавливает колбэк `onFinish` — когда пользователь нажмёт "Начать", запустим главный флоу.
    func showOnboarding() {
        let viewModel = OnboardingViewModel()
        viewModel.onFinish = { [weak self] in
            self?.showMain()
        }
        let viewController = OnboardingViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }

    /// Запускает главный флоу с таб баром.
    /// В будущем: сначала проверять завершён ли онбординг (флаг в UserDefaults).
    func showMain() {
        let coordinator = MainCoordinator(navigationController: navigationController)
        coordinator.start()
    }
}

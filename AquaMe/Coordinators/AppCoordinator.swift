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
        if AuthService.shared.isLoggedIn {
            showTest()
        } else {
            showAuth()
        }
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}

// MARK: - AppCoordinator + Setup

private extension AppCoordinator {

    func showAuth() {
        let viewModel = AuthViewModel()
        viewModel.onLoginSuccess = { [weak self] in
            self?.showTest()
        }
        viewModel.onRegisterTapped = { [weak self] in
            self?.showRegister()
        }
        let viewController = AuthViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }

    func showRegister() {
        let viewModel = RegisterViewModel()
        viewModel.onRegisterSuccess = { [weak self] in
            self?.showGreeting()
        }
        let viewController = RegisterViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    func showGreeting() {
        let viewModel = GreetingViewModel()
        viewModel.onNext = { [weak self] name, age, weight in
            self?.showGoal(name: name, age: age, weight: weight)
        }
        viewModel.onLogout = { [weak self] in
            self?.showAuth()
        }
        let viewController = GreetingViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: true)
    }

    func showGoal(name: String, age: Int, weight: Double) {
        let viewModel = GoalViewModel(name: name, age: age, weight: weight)
        viewModel.onGetStarted = { [weak self] in
            self?.showMain()
        }
        let viewController = GoalViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    func showOnboarding() {
        let viewModel = OnboardingViewModel()
        viewModel.onFinish = { [weak self] in
            self?.showTest()
        }
        let viewController = OnboardingViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }

    func showTest() {
        let viewController = TestViewController()
        viewController.onLogout = { [weak self] in
            self?.showAuth()
        }
        navigationController.setViewControllers([viewController], animated: true)
    }

    func showMain() {
        let coordinator = MainCoordinator(navigationController: navigationController)
        coordinator.onLogout = { [weak self] in
            self?.showAuth()
        }
        coordinator.start()
    }
}

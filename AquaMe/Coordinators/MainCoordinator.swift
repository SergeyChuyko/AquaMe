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
        mainViewController.onEditProfile = { [weak self] in
            self?.showEditProfile()
        }
        /// Переход без анимации — экран онбординга просто заменяется главным.
        navigationController.setViewControllers([mainViewController], animated: false)
    }
}

// MARK: - MainCoordinator + Setup

private extension MainCoordinator {

    /// Собирает MainViewController с тремя дочерними VC.
    /// Profile открывается боттом-шитом из четвёртой кнопки таб-бара, а не отдельной страницей.
    func buildMainViewController() -> MainViewController {
        let progressVC = ProgressViewController(viewModel: ProgressViewModel())
        let todayVC = TodayViewController(viewModel: TodayViewModel())
        let settingsVC = SettingsViewController(viewModel: SettingsViewModel())

        return MainViewController(viewControllers: [progressVC, todayVC, settingsVC])
    }

    func showEditProfile() {
        ProfileService.shared.loadProfile { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success(let profile):
                    let viewModel = GreetingViewModel(profile: profile)
                    viewModel.onNext = { [weak self] name, age, weight, avatarPath in
                        self?.showGoal(
                            name: name,
                            age: age,
                            weight: weight,
                            avatarPath: avatarPath,
                            initialGoal: profile.goal,
                            memberSince: profile.memberSince
                        )
                    }
                    viewModel.onLogout = self.onLogout
                    let viewController = GreetingViewController(viewModel: viewModel)
                    self.navigationController.pushViewController(viewController, animated: true)

                case .failure:
                    break
                }
            }
        }
    }

    func showGoal(
        name: String,
        age: Int,
        weight: Double,
        avatarPath: String?,
        initialGoal: UserProfile.Goal? = nil,
        memberSince: Date = Date()
    ) {
        let viewModel = GoalViewModel(
            name: name,
            age: age,
            weight: weight,
            avatarPath: avatarPath,
            isEditing: true,
            initialGoal: initialGoal,
            memberSince: memberSince
        )
        viewModel.onGetStarted = { [weak self] in
            self?.start()
        }
        let viewController = GoalViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}

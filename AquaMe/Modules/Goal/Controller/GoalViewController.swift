//
//  GoalViewController.swift
//  AquaMe
//
//  Created by Sergey on 04.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - GoalViewController

/// Контроллер экрана выбора цели — второй шаг онбординга.
/// Пользователь выбирает свою цель: Stay healthy / Lose weight / Stay active.
/// Не содержит логики — только отображает GoalView и передаёт события во ViewModel.
final class GoalViewController: UIViewController {

    // MARK: - Private properties

    /// GoalView полностью заменяет стандартную UIView контроллера.
    private lazy var goalView: GoalView = {
        let view = GoalView()
        view.delegate = self

        return view
    }()

    /// ViewModel хранится через протокол — контроллер не знает о конкретной реализации.
    private var viewModel: GoalViewModelProtocol

    // MARK: - Initialization

    init(viewModel: GoalViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupBindings()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func loadView() {
        /// Устанавливаем GoalView как корневую вью контроллера — она занимает весь экран.
        view = goalView
    }
}

// MARK: - GoalViewController + GoalViewDelegate

extension GoalViewController: GoalViewDelegate {

    func goalViewDidTapBack(_ view: GoalView) {
        navigationController?.popViewController(animated: true)
    }

    func goalViewDidTapGetStarted(_ view: GoalView) {
        guard let goal = view.selectedGoal else {
            showAlert(message: "Выберите цель")
            return
        }
        viewModel.didTapGetStarted(goal: goal)
    }
}

// MARK: - GoalViewController + Setup

private extension GoalViewController {

    func setupBindings() {
        viewModel.onError = { [weak self] message in
            self?.showAlert(message: message)
        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

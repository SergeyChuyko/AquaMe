//
//  GreetingViewController.swift
//  AquaMe
//
//  Created by Sergey on 30.03.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - GreetingViewController

/// Контроллер экрана приветствия — показывается при первом запуске приложения.
/// Пользователь заполняет данные профиля: фото, имя, возраст, вес, цель.
/// Не содержит логики — только отображает GreetingView и передаёт события во ViewModel.
final class GreetingViewController: UIViewController {

    // MARK: - Private properties

    /// GreetingView полностью заменяет стандартную UIView контроллера.
    private lazy var greetingView: GreetingView = {
        let view = GreetingView()
        view.delegate = self

        return view
    }()

    /// ViewModel хранится через протокол — контроллер не знает о конкретной реализации.
    private var viewModel: GreetingViewModelProtocol

    // MARK: - Initialization

    init(viewModel: GreetingViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func loadView() {
        /// Устанавливаем GreetingView как корневую вью контроллера — она занимает весь экран.
        view = greetingView
    }
}

// MARK: - GreetingViewController + GreetingViewDelegate

extension GreetingViewController: GreetingViewDelegate {

}

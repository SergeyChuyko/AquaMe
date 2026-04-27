//
//  OnboardingViewController.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - OnboardingViewController

/// View controller экрана онбординга.
/// Показывается при первом запуске приложения.
/// Содержит кнопку перехода на главный экран.
final class OnboardingViewController: UIViewController {

    // MARK: - Private properties

    private lazy var onboardingView: OnboardingView = {
        let view = OnboardingView()
        view.delegate = self

        return view
    }()

    private var viewModel: OnboardingViewModelProtocol

    // MARK: - Initialization

    init(viewModel: OnboardingViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func loadView() {
        view = onboardingView
    }
}

// MARK: - OnboardingViewController + OnboardingViewDelegate

extension OnboardingViewController: OnboardingViewDelegate {

    /// Пользователь нажал "Начать" — сообщаем ViewModel.
    func onboardingViewDidTapStart(_ view: OnboardingView) {
        viewModel.didTapStart()
    }
}

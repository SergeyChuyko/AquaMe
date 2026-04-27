//
//  OnboardingView.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - OnboardingViewDelegate

/// Получает события из OnboardingView и передаёт их во ViewController.
protocol OnboardingViewDelegate: AnyObject {

    /// Вызывается когда пользователь нажал кнопку "Начать".
    func onboardingViewDidTapStart(_ view: OnboardingView)
}

// MARK: - OnboardingView

/// Вью экрана онбординга.
/// Заготовка: фиолетовый фон и кнопка перехода на главный экран.
final class OnboardingView: UIView {

    // MARK: - Private enums

    private enum Constants {

        static let buttonHeight: CGFloat = 52
        static let buttonHorizontalPadding: CGFloat = 24
        static let buttonBottomPadding: CGFloat = 60
        static let cornerRadius: CGFloat = 16
    }

    // MARK: - Public properties

    weak var delegate: OnboardingViewDelegate?

    // MARK: - Private properties

    /// Кнопка перехода к главному экрану.
    private lazy var startButton: UIButton = {
        let action = UIAction { [weak self] _ in
            guard let self else { return }
            didTapStartButton()
        }
        let button = UIButton(primaryAction: action)
        button.setTitle("Начать", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.systemPurple, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = Constants.cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - OnboardingView + Actions

private extension OnboardingView {

    func didTapStartButton() {
        delegate?.onboardingViewDidTapStart(self)
    }
}

// MARK: - OnboardingView + Setup

private extension OnboardingView {

    func setup() {
        setupViews()
        setupConstraints()
    }

    func setupViews() {
        /// Фиолетовый фон — временная заготовка для онбординга.
        backgroundColor = .systemPurple
        addSubview(startButton)
    }

    func setupConstraints() {
        setupConstraintsForStartButton()
    }

    func setupConstraintsForStartButton() {
        NSLayoutConstraint.activate([
            startButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.buttonHorizontalPadding),
            startButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.buttonHorizontalPadding),
            startButton.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.bottomAnchor,
                constant: -Constants.buttonBottomPadding
            ),
            startButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
        ])
    }
}

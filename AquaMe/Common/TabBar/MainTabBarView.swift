//
//  MainTabBarView.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - MainTabBarViewDelegate

/// Уведомляет контейнер о смене вкладки пользователем.
protocol MainTabBarViewDelegate: AnyObject {

    /// Вызывается когда пользователь нажал на одну из вкладок таб бара.
    func mainTabBarView(_ view: MainTabBarView, didSelectTab tab: MainTabBarView.Tab)
}

// MARK: - MainTabBarView

/// Кастомный таб бар с тремя вкладками: Progress, Today (центральная), Settings.
/// Центральная вкладка Today чуть больше остальных по иконке.
final class MainTabBarView: UIView {

    // MARK: - Tab

    /// Перечисление вкладок таб бара.
    /// Используется чтобы не оперировать голыми индексами (0, 1, 2) — только .progress, .today, .settings.
    enum Tab: Int {
        case progress = 0
        case today = 1
        case settings = 2
    }

    // MARK: - Private enums

    private enum Constants {
        static let iconSize: CGFloat = 24
        static let centerIconSize: CGFloat = 30
        static let barHeight: CGFloat = 49
        static let separatorHeight: CGFloat = 0.5
    }

    // MARK: - Public properties

    weak var delegate: MainTabBarViewDelegate?

    // MARK: - Private properties

    private lazy var progressButton: UIButton = {
        let action = UIAction { [weak self] _ in
            guard let self else { return }
            didTapTab(.progress)
        }
        let button = UIButton(primaryAction: action)
        let config = UIImage.SymbolConfiguration(pointSize: Constants.iconSize, weight: .medium)
        button.setImage(UIImage(systemName: "chart.bar.fill", withConfiguration: config), for: .normal)
        button.tintColor = .systemGray

        return button
    }()

    private lazy var todayButton: UIButton = {
        let action = UIAction { [weak self] _ in
            guard let self else { return }
            didTapTab(.today)
        }
        let button = UIButton(primaryAction: action)
        let config = UIImage.SymbolConfiguration(pointSize: Constants.centerIconSize, weight: .medium)
        button.setImage(UIImage(systemName: "drop.fill", withConfiguration: config), for: .normal)
        button.tintColor = .systemGray

        return button
    }()

    private lazy var settingsButton: UIButton = {
        let action = UIAction { [weak self] _ in
            guard let self else { return }
            didTapTab(.settings)
        }
        let button = UIButton(primaryAction: action)
        let config = UIImage.SymbolConfiguration(pointSize: Constants.iconSize, weight: .medium)
        button.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: config), for: .normal)
        button.tintColor = .systemGray

        return button
    }()

    /// Горизонтальный стек для трёх кнопок.
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [progressButton, todayButton, settingsButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }()

    /// Тонкая линия-разделитель сверху таб бара.
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - MainTabBarView + Public methods

extension MainTabBarView {

    /// Обновляет визуальное состояние кнопок — выделяет активную вкладку.
    func selectTab(_ tab: Tab) {
        [progressButton, todayButton, settingsButton].enumerated().forEach { index, button in
            let isSelected = index == tab.rawValue
            button.tintColor = isSelected ? .systemBlue : .systemGray
        }
    }
}

// MARK: - MainTabBarView + Actions

private extension MainTabBarView {

    func didTapTab(_ tab: Tab) {
        selectTab(tab)
        delegate?.mainTabBarView(self, didSelectTab: tab)
    }
}

// MARK: - MainTabBarView + Setup

private extension MainTabBarView {

    func setup() {
        setupViews()
        setupConstraints()
    }

    func setupViews() {
        backgroundColor = .systemBackground
        addSubview(separatorView)
        addSubview(stackView)
    }

    func setupConstraints() {
        setupConstraintsForSeparatorView()
        setupConstraintsForStackView()
    }

    func setupConstraintsForSeparatorView() {
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: Constants.separatorHeight),
        ])
    }

    func setupConstraintsForStackView() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: Constants.barHeight),
        ])
    }
}

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
    }

    // MARK: - Public properties

    weak var delegate: MainTabBarViewDelegate?

    // MARK: - Private properties

    private lazy var progressButton: UIButton = makeButton(
        image: "chart.bar.fill",
        size: Constants.iconSize,
        tab: .progress
    )

    private lazy var todayButton: UIButton = makeButton(
        image: "drop.fill",
        size: Constants.centerIconSize,
        tab: .today
    )

    private lazy var settingsButton: UIButton = makeButton(
        image: "gearshape.fill",
        size: Constants.iconSize,
        tab: .settings
    )

    /// Горизонтальный стек для трёх кнопок.
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [progressButton, todayButton, settingsButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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

// MARK: - MainTabBarView + Setup

private extension MainTabBarView {

    func setup() {
        setupView()
        setupConstraints()
    }

    func setupView() {
        backgroundColor = .systemBackground
        /// Тонкая линия-разделитель сверху таб бара.
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)
        addSubview(stackView)

        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: topAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: Constants.barHeight),
        ])
    }

    /// Создаёт кнопку вкладки с системной иконкой.
    func makeButton(image: String, size: CGFloat, tab: Tab) -> UIButton {
        let action = UIAction { [weak self] _ in
            guard let self else { return }
            selectTab(tab)
            delegate?.mainTabBarView(self, didSelectTab: tab)
        }
        let button = UIButton(primaryAction: action)
        let config = UIImage.SymbolConfiguration(pointSize: size, weight: .medium)
        button.setImage(UIImage(systemName: image, withConfiguration: config), for: .normal)
        button.tintColor = .systemGray
        return button
    }
}

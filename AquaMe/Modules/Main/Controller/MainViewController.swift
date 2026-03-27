//
//  MainViewController.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - MainViewController

/// Контейнер для трёх дочерних view controller-ов с кастомным таб баром.
/// Управляет переключением между экранами Progress, Today и Settings.
/// Не содержит бизнес-логики — только управление дочерними VC.
final class MainViewController: UIViewController {

    // MARK: - Private enums

    private enum Constants {
        /// Высота таб бара без учёта safe area снизу.
        static let tabBarHeight: CGFloat = 49
    }

    // MARK: - Private properties

    /// Дочерние view controller-ы в порядке: Progress, Today, Settings.
    private let pages: [UIViewController]

    /// Индекс текущей активной вкладки. По умолчанию Today (индекс 1).
    private var currentIndex: Int = 1

    private lazy var tabBarView: MainTabBarView = {
        let view = MainTabBarView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// Контейнер для вью дочерних VC — занимает всё пространство выше таб бара.
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Initialization

    /// - Parameter viewControllers: Массив из трёх VC: [ProgressVC, TodayVC, SettingsVC].
    init(viewControllers: [UIViewController]) {
        self.pages = viewControllers
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

// MARK: - MainViewController + MainTabBarViewDelegate

extension MainViewController: MainTabBarViewDelegate {

    /// Переключает на выбранную вкладку.
    func mainTabBarView(_ view: MainTabBarView, didSelectTab tab: MainTabBarView.Tab) {
        showPage(at: tab.rawValue)
    }
}

// MARK: - MainViewController + Setup

private extension MainViewController {

    func setup() {
        setupView()
        setupConstraints()
        setupChildViewControllers()
        showPage(at: currentIndex)
    }

    func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(contentView)
        view.addSubview(tabBarView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            /// Контент занимает всё пространство выше таб бара.
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: tabBarView.topAnchor),

            /// Таб бар прижат к низу экрана, высота = barHeight + safe area.
            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBarView.heightAnchor.constraint(
                equalToConstant: Constants.tabBarHeight + (view.window?.safeAreaInsets.bottom ?? 34)
            ),
        ])
    }

    /// Встраивает все дочерние VC в contentView (hidden по умолчанию).
    /// Правильный способ добавления дочерних VC: addChild → addSubview → didMove.
    func setupChildViewControllers() {
        pages.forEach { vc in
            addChild(vc)
            contentView.addSubview(vc.view)
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                vc.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                vc.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                vc.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                vc.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ])
            vc.didMove(toParent: self)
            vc.view.isHidden = true
        }
    }

    /// Показывает страницу по индексу, скрывает остальные.
    func showPage(at index: Int) {
        guard index < pages.count else { return }
        pages[currentIndex].view.isHidden = true
        currentIndex = index
        pages[currentIndex].view.isHidden = false
        tabBarView.selectTab(MainTabBarView.Tab(rawValue: index) ?? .today)
    }
}

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
        static let profileSheetHeight: CGFloat = 480
    }

    // MARK: - Public properties

    var onLogout: (() -> Void)?
    var onEditProfile: (() -> Void)?

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

    private lazy var navigationBar: CUINavigationBar = {
        let bar = CUINavigationBar(
            title: "AquaMe",
            rightIcon: UIImage(systemName: "rectangle.portrait.and.arrow.right")
        )
        bar.rightButtonTintColor = .systemRed
        bar.onTapRight = { [weak self] in
            self?.handleLogoutTap()
        }

        return bar
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

    func mainTabBarViewDidTapProfile(_ view: MainTabBarView) {
        handleProfileTap()
    }
}

// MARK: - MainViewController + Setup

private extension MainViewController {

    func setup() {
        setupViews()
        setupConstraints()
        setupChildViewControllers()
        showPage(at: currentIndex)
    }

    func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(navigationBar)
        view.addSubview(contentView)
        view.addSubview(tabBarView)
    }

    func setupConstraints() {
        setupConstraintsForNavigationBar()
        setupConstraintsForContentView()
        setupConstraintsForTabBarView()
    }

    func setupConstraintsForNavigationBar() {
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    func setupConstraintsForContentView() {
        NSLayoutConstraint.activate([
            /// Контент занимает всё пространство выше таб бара.
            contentView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: tabBarView.topAnchor),
        ])
    }

    func setupConstraintsForTabBarView() {
        NSLayoutConstraint.activate([
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
            setupConstraintsForChildViewController(vc)
            vc.didMove(toParent: self)
            vc.view.isHidden = true
        }
    }

    func setupConstraintsForChildViewController(_ vc: UIViewController) {
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            vc.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            vc.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    func handleLogoutTap() {
        try? AuthService.shared.signOut()
        onLogout?()
    }

    func handleProfileTap() {
        let viewModel = ProfileSheetViewModel()
        let sheetVC = ProfileSheetViewController(viewModel: viewModel)
        sheetVC.onEditProfile = { [weak self] in
            self?.onEditProfile?()
        }

        if let sheet = sheetVC.sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom { _ in
                Constants.profileSheetHeight
            }
            sheet.detents = [customDetent]
            sheet.prefersGrabberVisible = true
        }

        present(sheetVC, animated: true)
    }

    /// Показывает страницу по индексу, скрывает остальные.
    func showPage(at index: Int) {
        guard index < pages.count else { return }

        pages[currentIndex].view.isHidden = true
        currentIndex = index
        pages[currentIndex].view.isHidden = false
        tabBarView.selectTab(MainTabBarView.Tab(rawValue: index) ?? .today)
        navigationBar.configure(
            title: title(for: index),
            rightIcon: UIImage(systemName: "rectangle.portrait.and.arrow.right")
        )
    }

    func title(for index: Int) -> String {
        switch MainTabBarView.Tab(rawValue: index) {
        case .progress: return "Progress"
        case .settings: return "Settings"
        default: return "AquaMe"
        }
    }
}

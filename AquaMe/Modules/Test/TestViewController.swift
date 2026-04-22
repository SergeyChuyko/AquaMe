//
//  TestViewController.swift
//  AquaMe
//
//  Created by Friday on 19.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - TestViewController

final class TestViewController: UIViewController {

    // MARK: - Public properties

    var onLogout: (() -> Void)?

    // MARK: - Private properties

    private lazy var navigationBar: CUINavigationBar = {
        let bar = CUINavigationBar(
            title: "Home",
            rightIcon: UIImage(systemName: "rectangle.portrait.and.arrow.right")
        )
        bar.rightButtonTintColor = .systemRed
        bar.onTapRight = { [weak self] in
            self?.handleLogoutTap()
        }

        return bar
    }()

    private lazy var logoutButton: UIButton = {
        let action = UIAction { [weak self] _ in
            self?.handleLogoutTap()
        }
        let button = UIButton(primaryAction: action)
        button.setTitle("Выйти", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 14
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

// MARK: - TestViewController + Setup

private extension TestViewController {

    func setup() {
        setupViews()
        setupConstraints()
    }

    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(navigationBar)
        view.addSubview(logoutButton)
    }

    func setupConstraints() {
        setupConstraintsForNavigationBar()
        setupConstraintsForLogoutButton()
    }

    func setupConstraintsForNavigationBar() {
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    func setupConstraintsForLogoutButton() {
        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 200),
            logoutButton.heightAnchor.constraint(equalToConstant: 56),
        ])
    }

    func handleLogoutTap() {
        try? AuthService.shared.signOut()
        onLogout?()
    }
}

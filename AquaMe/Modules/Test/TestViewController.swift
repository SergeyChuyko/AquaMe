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

    private lazy var logoutButton: UIButton = {
        let action = UIAction { [weak self] _ in
            try? AuthService.shared.signOut()
            self?.onLogout?()
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
        view.backgroundColor = .white
        view.addSubview(logoutButton)

        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 200),
            logoutButton.heightAnchor.constraint(equalToConstant: 56),
        ])
    }
}

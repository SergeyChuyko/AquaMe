//
//  AuthViewController.swift
//  AquaMe
//
//  Created by Sergey on 04.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - AuthViewController

final class AuthViewController: UIViewController {

    // MARK: - Private properties

    private lazy var authView: AuthView = {
        let view = AuthView()
        view.delegate = self

        return view
    }()

    private var viewModel: AuthViewModelProtocol

    // MARK: - Initialization

    init(viewModel: AuthViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func loadView() {
        view = authView
    }
}

// MARK: - AuthViewController + AuthViewDelegate

extension AuthViewController: AuthViewDelegate {

    func authViewDidTapLogin(_ view: AuthView) {
        viewModel.didTapLogin()
    }

    func authViewDidTapRegister(_ view: AuthView) {
        viewModel.didTapRegister()
    }
}

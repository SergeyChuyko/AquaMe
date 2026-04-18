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
        setupBindings()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func loadView() {
        view = authView
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        additionalSafeAreaInsets.bottom = view.safeAreaInsets.bottom == 0 ? 8 : 0
    }
}

// MARK: - AuthViewController + AuthViewDelegate

extension AuthViewController: AuthViewDelegate {

    func authViewDidTapLogin(_ view: AuthView) {
        view.setLoginLoading(true)
        viewModel.didTapLogin(
            email: view.email ?? "",
            password: view.password ?? ""
        )
    }

    func authViewDidTapForgotPassword(_ view: AuthView) {
        // TODO: navigate to forgot password
    }

    func authViewDidTapApple(_ view: AuthView) {
        // TODO: handle Apple sign-in
    }

    func authViewDidTapGoogle(_ view: AuthView) {
        viewModel.didTapGoogle(from: self)
    }

    func authViewDidTapRegister(_ view: AuthView) {
        viewModel.didTapRegister()
    }
}

// MARK: - AuthViewController + Setup

private extension AuthViewController {

    func setupBindings() {
        viewModel.onError = { [weak self] message in
            self?.authView.setLoginLoading(false)
            self?.showAlert(message: message)
        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

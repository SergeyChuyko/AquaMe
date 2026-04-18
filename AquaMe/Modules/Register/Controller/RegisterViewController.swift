//
//  RegisterViewController.swift
//  AquaMe
//
//  Created by Sergey on 04.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - RegisterViewController

final class RegisterViewController: UIViewController {

    // MARK: - Private properties

    private lazy var registerView: RegisterView = {
        let view = RegisterView()
        view.delegate = self

        return view
    }()

    private var viewModel: RegisterViewModelProtocol

    // MARK: - Initialization

    init(viewModel: RegisterViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupBindings()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func loadView() {
        view = registerView
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        additionalSafeAreaInsets.bottom = view.safeAreaInsets.bottom == 0 ? 8 : 0
    }
}

// MARK: - RegisterViewController + RegisterViewDelegate

extension RegisterViewController: RegisterViewDelegate {

    func registerViewDidTapBack(_ view: RegisterView) {
        navigationController?.popViewController(animated: true)
    }

    func registerViewDidTapRegister(_ view: RegisterView) {
        view.setRegisterLoading(true)
        viewModel.didTapRegister(
            email: view.email ?? "",
            password: view.password ?? "",
            confirmPassword: view.confirmPassword ?? ""
        )
    }

    func registerViewDidTapLogin(_ view: RegisterView) {
        viewModel.didTapLogin()
        navigationController?.popViewController(animated: true)
    }

    func registerViewDidTapApple(_ view: RegisterView) {
        // TODO: handle Apple sign-in
    }

    func registerViewDidTapGoogle(_ view: RegisterView) {
        AuthService.shared.signInWithGoogle(presenting: self) { [weak self] result in
            switch result {
            case .success:
                self?.viewModel.onRegisterSuccess?()

            case .failure(let error):
                if (error as NSError).code == -5 { return }
                self?.showAlert(message: error.localizedDescription)
            }
        }
    }
}

// MARK: - RegisterViewController + Setup

private extension RegisterViewController {

    func setupBindings() {
        viewModel.onError = { [weak self] message in
            self?.registerView.setRegisterLoading(false)
            self?.showAlert(message: message)
        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

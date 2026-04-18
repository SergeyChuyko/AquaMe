//
//  AuthViewModel.swift
//  AquaMe
//
//  Created by Sergey on 04.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - AuthViewModel

final class AuthViewModel: AuthViewModelProtocol {

    // MARK: - Public properties

    var onLoginSuccess: (() -> Void)?
    var onRegisterTapped: (() -> Void)?
    var onError: ((String) -> Void)?

    // MARK: - Private properties

    private let authService: AuthServiceProtocol

    // MARK: - Initialization

    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }

    // MARK: - AuthViewModelProtocol

    func didTapLogin(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            onError?("Заполните все поля")
            return
        }

        authService.signIn(email: email, password: password) { [weak self] result in
            switch result {
            case .success:
                self?.onLoginSuccess?()

            case .failure(let error):
                self?.onError?(error.localizedDescription)
            }
        }
    }

    func didTapGoogle(from viewController: UIViewController) {
        authService.signInWithGoogle(presenting: viewController) { [weak self] result in
            switch result {
            case .success:
                self?.onLoginSuccess?()

            case .failure(let error):
                if (error as NSError).code == -5 { return }
                self?.onError?(error.localizedDescription)
            }
        }
    }

    func didTapRegister() {
        onRegisterTapped?()
    }
}

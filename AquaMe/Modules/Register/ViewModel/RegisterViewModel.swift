//
//  RegisterViewModel.swift
//  AquaMe
//
//  Created by Sergey on 04.04.2026.
//  Copyright © 2026. All rights reserved.
//

// MARK: - RegisterViewModel

final class RegisterViewModel: RegisterViewModelProtocol {

    // MARK: - Public properties

    var onRegisterSuccess: (() -> Void)?
    var onError: ((String) -> Void)?

    // MARK: - Private properties

    private let authService: AuthServiceProtocol

    // MARK: - Initialization

    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }

    // MARK: - RegisterViewModelProtocol

    func didTapRegister(email: String, password: String, confirmPassword: String) {
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            onError?("Заполните все поля")
            return
        }

        guard password == confirmPassword else {
            onError?("Пароли не совпадают")
            return
        }

        guard password.count >= 6 else {
            onError?("Пароль должен содержать минимум 6 символов")
            return
        }

        authService.register(email: email, password: password) { [weak self] result in
            switch result {
            case .success:
                self?.onRegisterSuccess?()

            case .failure(let error):
                self?.onError?(error.localizedDescription)
            }
        }
    }

    func didTapLogin() {}
}

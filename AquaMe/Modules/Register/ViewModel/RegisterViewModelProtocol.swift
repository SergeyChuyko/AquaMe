//
//  RegisterViewModelProtocol.swift
//  AquaMe
//
//  Created by Sergey on 04.04.2026.
//  Copyright © 2026. All rights reserved.
//

// MARK: - RegisterViewModelProtocol

protocol RegisterViewModelProtocol: AnyObject {

    var onRegisterSuccess: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }

    func didTapRegister(email: String, password: String, confirmPassword: String)
    func didTapLogin()
}

//
//  AuthViewModelProtocol.swift
//  AquaMe
//
//  Created by Sergey on 04.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - AuthViewModelProtocol

protocol AuthViewModelProtocol: AnyObject {

    var onLoginSuccess: (() -> Void)? { get set }
    var onRegisterTapped: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }

    func didTapLogin(email: String, password: String)
    func didTapGoogle(from viewController: UIViewController)
    func didTapRegister()
}

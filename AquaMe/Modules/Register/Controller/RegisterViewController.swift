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
        viewModel.didTapRegister()
    }

    func registerViewDidTapLogin(_ view: RegisterView) {
        viewModel.didTapLogin()
        navigationController?.popViewController(animated: true)
    }

    func registerViewDidTapApple(_ view: RegisterView) {
        // TODO: handle Apple sign-in
    }

    func registerViewDidTapGoogle(_ view: RegisterView) {
        // TODO: handle Google sign-in
    }
}

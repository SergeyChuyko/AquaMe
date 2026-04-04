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
}

// MARK: - RegisterViewController + RegisterViewDelegate

extension RegisterViewController: RegisterViewDelegate {

    func registerViewDidTapRegister(_ view: RegisterView) {
        viewModel.didTapRegister()
    }

    func registerViewDidTapLogin(_ view: RegisterView) {
        viewModel.didTapLogin()
    }
}

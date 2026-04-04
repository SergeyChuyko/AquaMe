//
//  RegisterView.swift
//  AquaMe
//
//  Created by Sergey on 04.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - RegisterViewDelegate

protocol RegisterViewDelegate: AnyObject {

    func registerViewDidTapRegister(_ view: RegisterView)
    func registerViewDidTapLogin(_ view: RegisterView)
}

// MARK: - RegisterView

final class RegisterView: UIView {

    // MARK: - Public properties

    weak var delegate: RegisterViewDelegate?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - RegisterView + Setup

private extension RegisterView {

    func setup() {
        backgroundColor = .white
    }
}

//
//  AuthView.swift
//  AquaMe
//
//  Created by Sergey on 04.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - AuthViewDelegate

protocol AuthViewDelegate: AnyObject {

    func authViewDidTapLogin(_ view: AuthView)
    func authViewDidTapRegister(_ view: AuthView)
}

// MARK: - AuthView

final class AuthView: UIView {

    // MARK: - Public properties

    weak var delegate: AuthViewDelegate?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - AuthView + Setup

private extension AuthView {

    func setup() {
        backgroundColor = .white
    }
}

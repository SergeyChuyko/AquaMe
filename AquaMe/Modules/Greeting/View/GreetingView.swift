//
//  GreetingView.swift
//  AquaMe
//
//  Created by Sergey on 30.03.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - GreetingViewDelegate

/// Сообщает контроллеру о действиях пользователя на экране приветствия.
protocol GreetingViewDelegate: AnyObject {

}

// MARK: - GreetingView

/// Вью экрана приветствия — пользователь заполняет данные о себе перед началом работы с приложением.
final class GreetingView: UIView {

    // MARK: - Private enums

    private enum Constants {

        /// Размер круглой аватарки профиля.
        static let profileImageSize: CGFloat = 120

        /// Радиус скругления аватарки — половина размера чтобы получить круг.
        static let profileImageCornerRadius: CGFloat = profileImageSize / 2

        /// Отступ аватарки от верха экрана.
        static let profileImageTopOffset: CGFloat = 140
    }

    // MARK: - Public properties

    weak var delegate: GreetingViewDelegate?

    // MARK: - Private properties

    /// Круглая аватарка пользователя. Красный фон — временная заглушка до добавления фото.
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .red
        imageView.translatesAutoresizingMaskIntoConstraints = false
        /// cornerRadius нельзя ставить через frame здесь — в lazy var frame ещё равен CGRect.zero.
        /// Поэтому используем фиксированное значение из Constants.
        imageView.layer.cornerRadius = Constants.profileImageCornerRadius
        /// clipsToBounds = true обязателен чтобы скругление действительно обрезало содержимое.
        imageView.clipsToBounds = true

        return imageView
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - GreetingView + Setup

private extension GreetingView {

    func setup() {
        setupViews()
        setupConstraints()
    }

    func setupViews() {
        /// Временный фиолетовый фон — заменится на белый когда будет готов полный дизайн.
        backgroundColor = .systemPurple
        addSubview(profileImageView)
    }

    func setupConstraints() {
        setupConstraintsForProfileImageView()
    }

    func setupConstraintsForProfileImageView() {
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: Constants.profileImageSize),
            profileImageView.heightAnchor.constraint(equalToConstant: Constants.profileImageSize),
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.profileImageTopOffset),
            profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
}

//
//  SettingsSectionHeader.swift
//  AquaMe
//
//  Created by Friday on 26.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - SettingsSectionHeader

/// Заголовок секции настроек: маленькая иконка + uppercase-текст.
final class SettingsSectionHeader: UIView {

    // MARK: - Private enums

    private enum Constants {

        static let iconSize: CGFloat = 16
        static let spacing: CGFloat = 6
        static let fontSize: CGFloat = 12
    }

    // MARK: - Private properties

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .systemIndigo
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .semibold)
        label.textColor = .systemIndigo

        return label
    }()

    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = Constants.spacing

        return stack
    }()

    // MARK: - Initialization

    init(icon: UIImage?, title: String) {
        super.init(frame: .zero)
        iconImageView.image = icon
        titleLabel.text = title.uppercased()
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - SettingsSectionHeader + Setup

private extension SettingsSectionHeader {

    func setup() {
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Constants.iconSize),
        ])
    }
}

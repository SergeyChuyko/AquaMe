//
//  TodayPresetCardView.swift
//  AquaMe
//
//  Created by Friday on 25.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - TodayPresetCardView

/// Карточка пресета объёма (250 мл / 500 мл).
/// Имеет состояние выбран/не выбран и режим remove (красный).
final class TodayPresetCardView: UIView {

    // MARK: - Private enums

    private enum Constants {

        static let cornerRadius: CGFloat = 16
        static let borderWidth: CGFloat = 1.5
        static let height: CGFloat = 96
        static let iconSize: CGFloat = 28
        static let iconBackgroundSize: CGFloat = 44
        static let titleFontSize: CGFloat = 17
        static let stackSpacing: CGFloat = 8
    }

    private enum Images {

        static let cup = UIImage(systemName: "cup.and.saucer.fill")
    }

    // MARK: - Public properties

    let amount: Int
    var onTap: (() -> Void)?

    // MARK: - Private properties

    private var isSelected: Bool = false
    private var isRemoveMode: Bool = false

    private lazy var iconBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.iconBackgroundSize / 2

        return view
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(image: Images.cup)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.titleFontSize, weight: .semibold)
        label.textAlignment = .center

        return label
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconBackground, titleLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = Constants.stackSpacing

        return stack
    }()

    // MARK: - Initialization

    init(amount: Int) {
        self.amount = amount
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - TodayPresetCardView + Public

extension TodayPresetCardView {

    func update(isSelected: Bool, isRemoveMode: Bool, title: String) {
        self.isSelected = isSelected
        self.isRemoveMode = isRemoveMode
        titleLabel.text = title
        applyStyle()
    }
}

// MARK: - TodayPresetCardView + Setup

private extension TodayPresetCardView {

    func setup() {
        layer.cornerRadius = Constants.cornerRadius
        layer.borderWidth = Constants.borderWidth
        translatesAutoresizingMaskIntoConstraints = false

        iconBackground.addSubview(iconImageView)
        addSubview(contentStack)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Constants.height),
            iconBackground.widthAnchor.constraint(equalToConstant: Constants.iconBackgroundSize),
            iconBackground.heightAnchor.constraint(equalToConstant: Constants.iconBackgroundSize),
            iconImageView.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Constants.iconSize),
            contentStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
        applyStyle()
    }

    func applyStyle() {
        let accent: UIColor = isRemoveMode ? .systemRed : .systemIndigo

        if isSelected {
            backgroundColor = accent.withAlphaComponent(0.07)
            layer.borderColor = accent.cgColor
            iconBackground.backgroundColor = accent
            iconImageView.tintColor = .white
            titleLabel.textColor = accent
        } else {
            backgroundColor = .secondarySystemBackground
            layer.borderColor = UIColor.separator.withAlphaComponent(0.4).cgColor
            iconBackground.backgroundColor = .systemBackground
            iconImageView.tintColor = .secondaryLabel
            titleLabel.textColor = .label
        }
    }

    @objc
    func handleTap() {
        onTap?()
    }
}

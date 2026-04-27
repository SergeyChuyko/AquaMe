//
//  ProgressStatCard.swift
//  AquaMe
//
//  Created by Friday on 27.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - ProgressStatCardModel

struct ProgressStatCardModel: Equatable {

    enum Tone: Equatable {

        case positive
        case neutral
    }

    let icon: UIImage?
    let title: String
    let value: String
    let unit: String?
    let badge: String?
    let badgeTone: Tone
}

// MARK: - ProgressStatCard

/// Маленькая карточка из секции PERFORMANCE STATS: иконка + заголовок + значение + бейдж\.
final class ProgressStatCard: UIView {

    // MARK: - Private enums

    private enum Constants {

        static let cornerRadius: CGFloat = 16
        static let borderWidth: CGFloat = 1
        static let padding: CGFloat = 14
        static let iconSize: CGFloat = 14
        static let iconBackgroundSize: CGFloat = 28
        static let titleFontSize: CGFloat = 11
        static let valueFontSize: CGFloat = 22
        static let unitFontSize: CGFloat = 12
        static let badgeFontSize: CGFloat = 11
        static let badgeHeight: CGFloat = 20
    }

    // MARK: - Private properties

    private lazy var iconBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.iconBackgroundSize / 2
        view.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.12)

        return view
    }()

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
        label.font = .systemFont(ofSize: Constants.titleFontSize, weight: .semibold)
        label.textColor = .secondaryLabel

        return label
    }()

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.valueFontSize, weight: .bold)
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6

        return label
    }()

    private lazy var unitLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.unitFontSize, weight: .medium)
        label.textColor = .secondaryLabel

        return label
    }()

    private lazy var badge: PaddedLabel = {
        let label = PaddedLabel(insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.badgeFontSize, weight: .semibold)
        label.layer.cornerRadius = Constants.badgeHeight / 2
        label.layer.masksToBounds = true
        label.textAlignment = .center

        return label
    }()

    private lazy var valueRow: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [valueLabel, unitLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .lastBaseline
        stack.spacing = 4

        return stack
    }()

    // MARK: - Initialization

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - ProgressStatCard + Public

extension ProgressStatCard {

    func update(with model: ProgressStatCardModel) {
        iconImageView.image = model.icon
        titleLabel.text = model.title.uppercased()
        valueLabel.text = model.value
        unitLabel.text = model.unit
        unitLabel.isHidden = model.unit == nil

        if let text = model.badge {
            badge.text = text
            badge.isHidden = false
            applyBadgeTone(model.badgeTone)
        } else {
            badge.isHidden = true
        }
    }
}

// MARK: - ProgressStatCard + Setup

private extension ProgressStatCard {

    func setup() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = Constants.cornerRadius
        layer.borderWidth = Constants.borderWidth
        layer.borderColor = UIColor.separator.withAlphaComponent(0.3).cgColor

        addSubview(iconBackground)
        iconBackground.addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(valueRow)
        addSubview(badge)

        NSLayoutConstraint.activate([
            iconBackground.topAnchor.constraint(equalTo: topAnchor, constant: Constants.padding),
            iconBackground.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            iconBackground.widthAnchor.constraint(equalToConstant: Constants.iconBackgroundSize),
            iconBackground.heightAnchor.constraint(equalToConstant: Constants.iconBackgroundSize),

            iconImageView.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Constants.iconSize),

            titleLabel.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Constants.padding),

            valueRow.topAnchor.constraint(equalTo: iconBackground.bottomAnchor, constant: 12),
            valueRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            valueRow.trailingAnchor.constraint(lessThanOrEqualTo: badge.leadingAnchor, constant: -8),
            valueRow.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.padding),

            badge.centerYAnchor.constraint(equalTo: valueRow.centerYAnchor),
            badge.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
            badge.heightAnchor.constraint(equalToConstant: Constants.badgeHeight),
        ])
    }

    func applyBadgeTone(_ tone: ProgressStatCardModel.Tone) {
        switch tone {
        case .positive:
            badge.textColor = .systemGreen
            badge.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)

        case .neutral:
            badge.textColor = .systemIndigo
            badge.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.15)
        }
    }
}

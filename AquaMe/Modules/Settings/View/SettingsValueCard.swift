//
//  SettingsValueCard.swift
//  AquaMe
//
//  Created by Friday on 26.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - SettingsValueCardDelegate

protocol SettingsValueCardDelegate: AnyObject {

    func valueCard(_ card: SettingsValueCard, didEnter value: String)
}

// MARK: - SettingsValueCard

/// Карточка с заголовком слева, опциональным бейджем справа сверху, большим вводимым значением
/// и опциональной подсказкой/единицами\.
/// Поведение: тап по карточке поднимает клавиатуру (numberPad), на end editing — отдаёт значение делегату.
final class SettingsValueCard: UIView {

    // MARK: - Private enums

    private enum Constants {

        static let cornerRadius: CGFloat = 16
        static let borderWidth: CGFloat = 1
        static let padding: CGFloat = 16
        static let titleFontSize: CGFloat = 15
        static let valueFontSize: CGFloat = 22
        static let suffixFontSize: CGFloat = 14
        static let footnoteFontSize: CGFloat = 12
        static let badgeFontSize: CGFloat = 12
        static let badgeHeight: CGFloat = 22
    }

    // MARK: - Public properties

    weak var delegate: SettingsValueCardDelegate?

    // MARK: - Private properties

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.titleFontSize, weight: .semibold)
        label.textColor = .label

        return label
    }()

    private lazy var badgeLabel: PaddedLabel = {
        let label = PaddedLabel(insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.badgeFontSize, weight: .semibold)
        label.textColor = .systemIndigo
        label.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.12)
        label.layer.cornerRadius = Constants.badgeHeight / 2
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.isHidden = true

        return label
    }()

    private lazy var valueField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = .systemFont(ofSize: Constants.valueFontSize, weight: .bold)
        field.textColor = .label
        field.keyboardType = .numberPad
        field.borderStyle = .none
        field.delegate = self
        field.addTarget(self, action: #selector(handleEditingDidEnd), for: .editingDidEnd)

        return field
    }()

    private lazy var suffixLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.suffixFontSize, weight: .medium)
        label.textColor = .secondaryLabel

        return label
    }()

    private lazy var footnoteLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.footnoteFontSize)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.isHidden = true

        return label
    }()

    private lazy var valueRow: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [valueField, suffixLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .lastBaseline
        stack.spacing = 6

        return stack
    }()

    // MARK: - Initialization

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Hit testing

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        valueField.becomeFirstResponder()
    }
}

// MARK: - SettingsValueCard + Public

extension SettingsValueCard {

    func configure(title: String, value: String, suffix: String?, badge: String?, footnote: String?) {
        titleLabel.text = title
        valueField.text = value
        suffixLabel.text = suffix
        suffixLabel.isHidden = suffix == nil
        if let badge {
            badgeLabel.text = badge
            badgeLabel.isHidden = false
        } else {
            badgeLabel.isHidden = true
        }
        if let footnote {
            footnoteLabel.text = footnote
            footnoteLabel.isHidden = false
        } else {
            footnoteLabel.isHidden = true
        }
    }
}

// MARK: - SettingsValueCard + UITextFieldDelegate

extension SettingsValueCard: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - SettingsValueCard + Actions

private extension SettingsValueCard {

    @objc
    func handleEditingDidEnd() {
        delegate?.valueCard(self, didEnter: valueField.text ?? "")
    }
}

// MARK: - SettingsValueCard + Setup

private extension SettingsValueCard {

    func setup() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = Constants.cornerRadius
        layer.borderWidth = Constants.borderWidth
        layer.borderColor = UIColor.separator.withAlphaComponent(0.3).cgColor

        addSubview(titleLabel)
        addSubview(badgeLabel)
        addSubview(valueRow)
        addSubview(footnoteLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.padding),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: badgeLabel.leadingAnchor,
                constant: -8
            ),

            badgeLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            badgeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
            badgeLabel.heightAnchor.constraint(equalToConstant: Constants.badgeHeight),

            valueRow.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            valueRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            valueRow.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Constants.padding),

            footnoteLabel.topAnchor.constraint(equalTo: valueRow.bottomAnchor, constant: 8),
            footnoteLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            footnoteLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
            footnoteLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.padding),
        ])
    }
}

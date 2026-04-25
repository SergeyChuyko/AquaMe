//
//  TodayQuickAmountButton.swift
//  AquaMe
//
//  Created by Friday on 25.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - TodayQuickAmountButton

/// Маленькая кнопка-чип для быстрого добавления (или удаления в режиме remove)
/// объёма воды: 100/200/300/400 мл.
final class TodayQuickAmountButton: UIControl {

    // MARK: - Private enums

    private enum Constants {

        static let cornerRadius: CGFloat = 14
        static let borderWidth: CGFloat = 1
        static let height: CGFloat = 64
        static let amountFontSize: CGFloat = 18
        static let unitFontSize: CGFloat = 11
        static let stackSpacing: CGFloat = 2
        static let pressedAlpha: CGFloat = 0.6
    }

    // MARK: - Public properties

    let amount: Int
    var onTap: (() -> Void)?

    // MARK: - Private properties

    private var isRemoveMode: Bool = false

    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.amountFontSize, weight: .semibold)
        label.textAlignment = .center

        return label
    }()

    private lazy var unitLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.unitFontSize, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.text = "ML"

        return label
    }()

    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [amountLabel, unitLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = Constants.stackSpacing
        stack.isUserInteractionEnabled = false

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

    // MARK: - Touch tracking

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.alpha = self.isHighlighted ? Constants.pressedAlpha : 1
            }
        }
    }
}

// MARK: - TodayQuickAmountButton + Public

extension TodayQuickAmountButton {

    func update(isRemoveMode: Bool) {
        self.isRemoveMode = isRemoveMode
        amountLabel.text = "\(amount)"
        applyStyle()
    }
}

// MARK: - TodayQuickAmountButton + Setup

private extension TodayQuickAmountButton {

    func setup() {
        layer.cornerRadius = Constants.cornerRadius
        layer.borderWidth = Constants.borderWidth
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Constants.height),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        applyStyle()
    }

    func applyStyle() {
        let accent: UIColor = isRemoveMode ? .systemRed : .label
        amountLabel.textColor = accent
        backgroundColor = .secondarySystemBackground
        layer.borderColor = isRemoveMode
            ? UIColor.systemRed.withAlphaComponent(0.4).cgColor
            : UIColor.separator.withAlphaComponent(0.4).cgColor
    }

    @objc
    func handleTap() {
        onTap?()
    }
}

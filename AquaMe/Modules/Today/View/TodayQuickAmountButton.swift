//
//  TodayQuickAmountButton.swift
//  AquaMe
//
//  Created by Friday on 25.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - TodayQuickAmountButton

/// Чип быстрого добавления объёма воды.
/// По умолчанию серый. На тапе вспыхивает индиго (или красным в режиме remove)
/// и плавно возвращается к серому. Плюс press-эффект уменьшения чипа.
final class TodayQuickAmountButton: UIControl {

    // MARK: - Private enums

    private enum Constants {

        static let cornerRadius: CGFloat = 14
        static let borderWidth: CGFloat = 1
        static let height: CGFloat = 64
        static let amountFontSize: CGFloat = 18
        static let unitFontSize: CGFloat = 11
        static let stackSpacing: CGFloat = 2
        static let pressedScale: CGFloat = 0.94
        static let pressDuration: TimeInterval = 0.12
        static let flashHoldDuration: TimeInterval = 0.85
        static let flashFadeDuration: TimeInterval = 0.6
    }

    // MARK: - Public properties

    let amount: Int
    var onTap: (() -> Void)?

    // MARK: - Private properties

    private var isRemoveMode: Bool = false
    private var fadeWorkItem: DispatchWorkItem?

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

    // MARK: - Press feedback

    override var isHighlighted: Bool {
        didSet {
            animatePress(down: isHighlighted)
        }
    }
}

// MARK: - TodayQuickAmountButton + Public

extension TodayQuickAmountButton {

    func update(isRemoveMode: Bool, displayValue: String, unit: String) {
        self.isRemoveMode = isRemoveMode
        amountLabel.text = displayValue
        unitLabel.text = unit.uppercased()
        applyInactiveStyle()
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
        applyInactiveStyle()
    }

    func applyInactiveStyle() {
        backgroundColor = .secondarySystemBackground
        layer.borderColor = UIColor.separator.withAlphaComponent(0.4).cgColor
        amountLabel.textColor = .label
        unitLabel.textColor = .secondaryLabel
    }

    func applyActiveStyle() {
        let accent: UIColor = isRemoveMode ? .systemRed : .systemIndigo
        backgroundColor = accent
        layer.borderColor = accent.cgColor
        amountLabel.textColor = .white
        unitLabel.textColor = UIColor.white.withAlphaComponent(0.85)
    }

    func flashSelection() {
        applyActiveStyle()
        fadeWorkItem?.cancel()

        let item = DispatchWorkItem { [weak self] in
            guard let self else { return }

            UIView.animate(withDuration: Constants.flashFadeDuration) {
                self.applyInactiveStyle()
            }
        }
        fadeWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.flashHoldDuration, execute: item)
    }

    func animatePress(down: Bool) {
        let scale: CGFloat = down ? Constants.pressedScale : 1
        UIView.animate(
            withDuration: Constants.pressDuration,
            delay: 0,
            options: [.allowUserInteraction, .curveEaseOut]
        ) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }

    @objc
    func handleTap() {
        flashSelection()
        onTap?()
    }
}

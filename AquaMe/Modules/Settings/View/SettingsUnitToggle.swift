//
//  SettingsUnitToggle.swift
//  AquaMe
//
//  Created by Friday on 26.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - SettingsUnitToggleDelegate

protocol SettingsUnitToggleDelegate: AnyObject {

    func unitToggle(_ toggle: SettingsUnitToggle, didSelect unit: UserProfile.MeasureUnit)
}

// MARK: - SettingsUnitToggle

/// Pill-сегмент для выбора единиц измерения: Milliliters (ml) | Ounces (oz).
final class SettingsUnitToggle: UIView {

    // MARK: - Private enums

    private enum Constants {

        static let cornerRadius: CGFloat = 14
        static let segmentCornerRadius: CGFloat = 10
        static let height: CGFloat = 48
        static let inset: CGFloat = 4
        static let titleFontSize: CGFloat = 14
    }

    // MARK: - Public properties

    weak var delegate: SettingsUnitToggleDelegate?

    // MARK: - Private properties

    private var selectedUnit: UserProfile.MeasureUnit = .ml

    private lazy var mlSegment = makeSegment(text: "Metric (ml, kg)") { [weak self] in
        self?.handleSelect(.ml)
    }

    private lazy var ozSegment = makeSegment(text: "Imperial (oz, lb)") { [weak self] in
        self?.handleSelect(.oz)
    }

    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [mlSegment, ozSegment])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0

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

// MARK: - SettingsUnitToggle + Public

extension SettingsUnitToggle {

    func update(selected: UserProfile.MeasureUnit, animated: Bool) {
        selectedUnit = selected
        applyStyle(animated: animated)
    }
}

// MARK: - SettingsUnitToggle + Private

private extension SettingsUnitToggle {

    func setup() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = Constants.cornerRadius
        layer.borderWidth = 1
        layer.borderColor = UIColor.separator.withAlphaComponent(0.3).cgColor

        addSubview(stack)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Constants.height),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: Constants.inset),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.inset),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.inset),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.inset),
        ])
        applyStyle(animated: false)
    }

    func makeSegment(text: String, onTap: @escaping () -> Void) -> SegmentView {
        let segment = SegmentView()
        segment.label.text = text
        segment.label.font = .systemFont(ofSize: Constants.titleFontSize, weight: .semibold)
        segment.layer.cornerRadius = Constants.segmentCornerRadius
        segment.layer.masksToBounds = true
        segment.onTap = onTap

        return segment
    }

    func handleSelect(_ unit: UserProfile.MeasureUnit) {
        guard selectedUnit != unit else { return }
        selectedUnit = unit
        applyStyle(animated: true)
        delegate?.unitToggle(self, didSelect: unit)
    }

    func applyStyle(animated: Bool) {
        let mlSelected = selectedUnit == .ml

        let apply: () -> Void = {
            self.mlSegment.backgroundColor = mlSelected ? .systemIndigo : .clear
            self.mlSegment.label.textColor = mlSelected ? .white : .label
            self.ozSegment.backgroundColor = mlSelected ? .clear : .systemIndigo
            self.ozSegment.label.textColor = mlSelected ? .label : .white
        }

        if animated {
            UIView.animate(withDuration: 0.2, animations: apply)
        } else {
            apply()
        }
    }
}

// MARK: - SegmentView

/// Внутренний контейнер сегмента: лейбл по центру + tap-обработчик.
private final class SegmentView: UIView {

    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center

        return label
    }()

    var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    @objc
    private func handleTap() {
        onTap?()
    }
}

//
//  ProgressDayCell.swift
//  AquaMe
//
//  Created by Friday on 27.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - ProgressDayCell

/// Одна ячейка календаря: число дня + фон-индикатор по статусу + риска "сегодня".
final class ProgressDayCell: UIView {

    // MARK: - Private enums

    private enum Constants {

        static let cornerRadius: CGFloat = 10
        static let fontSize: CGFloat = 14
        static let todayBorderWidth: CGFloat = 2
    }

    // MARK: - Private properties

    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .bold)
        label.textAlignment = .center

        return label
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - ProgressDayCell + Public

extension ProgressDayCell {

    func update(with day: ProgressDay) {
        guard let dayNumber = day.dayNumber else {
            backgroundColor = .clear
            layer.borderWidth = 0
            dayLabel.text = ""

            return
        }

        dayLabel.text = "\(dayNumber)"

        if day.isToday {
            layer.borderWidth = Constants.todayBorderWidth
            layer.borderColor = UIColor.systemIndigo.cgColor
        } else {
            layer.borderWidth = 0
        }

        applyStyle(for: day.status)
    }
}

// MARK: - ProgressDayCell + Setup

private extension ProgressDayCell {

    func setup() {
        layer.cornerRadius = Constants.cornerRadius
        addSubview(dayLabel)

        NSLayoutConstraint.activate([
            dayLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    func applyStyle(for status: WaterDayStatus) {
        switch status {
        case .goalMet:
            backgroundColor = .systemIndigo
            dayLabel.textColor = .white

        case .missed:
            backgroundColor = UIColor.separator.withAlphaComponent(0.18)
            dayLabel.textColor = .label

        case .future:
            backgroundColor = UIColor.separator.withAlphaComponent(0.08)
            dayLabel.textColor = .tertiaryLabel
        }
    }
}

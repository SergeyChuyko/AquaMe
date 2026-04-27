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
        static let todayBarHeight: CGFloat = 3
        static let todayBarInset: CGFloat = 6
    }

    // MARK: - Private properties

    private lazy var bubble: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.cornerRadius

        return view
    }()

    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .semibold)
        label.textAlignment = .center

        return label
    }()

    private lazy var todayBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemIndigo
        view.layer.cornerRadius = Constants.todayBarHeight / 2
        view.isHidden = true

        return view
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
            bubble.backgroundColor = .clear
            dayLabel.text = ""
            todayBar.isHidden = true

            return
        }

        dayLabel.text = "\(dayNumber)"
        todayBar.isHidden = !day.isToday
        applyStyle(for: day.status)
    }
}

// MARK: - ProgressDayCell + Setup

private extension ProgressDayCell {

    func setup() {
        addSubview(bubble)
        bubble.addSubview(dayLabel)
        addSubview(todayBar)

        NSLayoutConstraint.activate([
            bubble.topAnchor.constraint(equalTo: topAnchor),
            bubble.leadingAnchor.constraint(equalTo: leadingAnchor),
            bubble.trailingAnchor.constraint(equalTo: trailingAnchor),
            bubble.bottomAnchor.constraint(equalTo: bottomAnchor),

            dayLabel.centerXAnchor.constraint(equalTo: bubble.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: bubble.centerYAnchor),

            todayBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            todayBar.heightAnchor.constraint(equalToConstant: Constants.todayBarHeight),
            todayBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.todayBarInset),
            todayBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.todayBarInset),
        ])
    }

    func applyStyle(for status: WaterDayStatus) {
        switch status {
        case .goalMet:
            bubble.backgroundColor = .systemIndigo
            dayLabel.textColor = .white

        case .partial:
            bubble.backgroundColor = UIColor.systemPink.withAlphaComponent(0.35)
            dayLabel.textColor = .systemPink

        case .missed:
            bubble.backgroundColor = UIColor.separator.withAlphaComponent(0.15)
            dayLabel.textColor = .secondaryLabel

        case .future:
            bubble.backgroundColor = UIColor.separator.withAlphaComponent(0.08)
            dayLabel.textColor = .tertiaryLabel
        }
    }
}

//
//  ProgressCalendarView.swift
//  AquaMe
//
//  Created by Friday on 27.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - ProgressCalendarViewDelegate

protocol ProgressCalendarViewDelegate: AnyObject {

    func calendarViewDidTapPrevious(_ view: ProgressCalendarView)
    func calendarViewDidTapNext(_ view: ProgressCalendarView)
}

// MARK: - ProgressCalendarView

/// Календарь месяца: заголовок с навигацией, шапка дней недели, грид ячеек, легенда.
final class ProgressCalendarView: UIView {

    // MARK: - Private enums

    private enum Constants {

        static let cornerRadius: CGFloat = 16
        static let borderWidth: CGFloat = 1
        static let outerPadding: CGFloat = 16
        static let titleFontSize: CGFloat = 17
        static let weekdayFontSize: CGFloat = 12
        static let cellSize: CGFloat = 36
        static let cellSpacing: CGFloat = 6
        static let chevronSize: CGFloat = 30
    }

    private enum Images {

        static let chevronLeft = UIImage(systemName: "chevron.left")
        static let chevronRight = UIImage(systemName: "chevron.right")
        static let info = UIImage(systemName: "info.circle")
    }

    // MARK: - Public properties

    weak var delegate: ProgressCalendarViewDelegate?

    // MARK: - Private properties

    private var dayCells: [ProgressDayCell] = []

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.titleFontSize, weight: .semibold)
        label.textColor = .label

        return label
    }()

    private lazy var prevButton: UIButton = {
        let button = makeChevron(image: Images.chevronLeft, action: #selector(handlePrev))

        return button
    }()

    private lazy var nextButton: UIButton = {
        let button = makeChevron(image: Images.chevronRight, action: #selector(handleNext))

        return button
    }()

    private lazy var weekdayHeader: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = Constants.cellSpacing

        for symbol in ["M", "T", "W", "T", "F", "S", "S"] {
            let label = UILabel()
            label.text = symbol
            label.font = .systemFont(ofSize: Constants.weekdayFontSize, weight: .medium)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            stack.addArrangedSubview(label)
        }

        return stack
    }()

    private lazy var grid: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = Constants.cellSpacing
        stack.alignment = .fill
        stack.distribution = .fillEqually

        return stack
    }()

    private lazy var legend = ProgressCalendarLegendView()

    // MARK: - Initialization

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - ProgressCalendarView + Public

extension ProgressCalendarView {

    func update(monthTitle: String, days: [ProgressDay]) {
        titleLabel.text = monthTitle
        rebuildGrid(for: days)
    }
}

// MARK: - ProgressCalendarView + Setup

private extension ProgressCalendarView {

    func setup() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = Constants.cornerRadius
        layer.borderWidth = Constants.borderWidth
        layer.borderColor = UIColor.separator.withAlphaComponent(0.3).cgColor

        addSubview(titleLabel)
        addSubview(prevButton)
        addSubview(nextButton)
        addSubview(weekdayHeader)
        addSubview(grid)
        addSubview(legend)
        legend.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.outerPadding),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.outerPadding),

            nextButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.outerPadding),
            nextButton.widthAnchor.constraint(equalToConstant: Constants.chevronSize),
            nextButton.heightAnchor.constraint(equalToConstant: Constants.chevronSize),

            prevButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            prevButton.trailingAnchor.constraint(equalTo: nextButton.leadingAnchor, constant: -8),
            prevButton.widthAnchor.constraint(equalToConstant: Constants.chevronSize),
            prevButton.heightAnchor.constraint(equalToConstant: Constants.chevronSize),

            weekdayHeader.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18),
            weekdayHeader.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.outerPadding),
            weekdayHeader.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.outerPadding),

            grid.topAnchor.constraint(equalTo: weekdayHeader.bottomAnchor, constant: 8),
            grid.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.outerPadding),
            grid.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.outerPadding),

            legend.topAnchor.constraint(equalTo: grid.bottomAnchor, constant: 14),
            legend.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.outerPadding),
            legend.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.outerPadding),
            legend.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.outerPadding),
        ])
    }

    func makeChevron(image: UIImage?, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .systemIndigo
        button.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.08)
        button.layer.cornerRadius = Constants.chevronSize / 2
        button.setImage(image, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)

        return button
    }

    func rebuildGrid(for days: [ProgressDay]) {
        grid.arrangedSubviews.forEach { $0.removeFromSuperview() }
        dayCells = []

        let weekChunks = stride(from: 0, to: days.count, by: 7).map { offset in
            Array(days[offset..<min(offset + 7, days.count)])
        }

        for week in weekChunks {
            let row = UIStackView()
            row.translatesAutoresizingMaskIntoConstraints = false
            row.axis = .horizontal
            row.spacing = Constants.cellSpacing
            row.distribution = .fillEqually

            for day in week {
                let cell = ProgressDayCell()
                cell.translatesAutoresizingMaskIntoConstraints = false
                cell.heightAnchor.constraint(equalToConstant: Constants.cellSize).isActive = true
                cell.update(with: day)
                row.addArrangedSubview(cell)
                dayCells.append(cell)
            }

            grid.addArrangedSubview(row)
        }
    }

    @objc
    func handlePrev() {
        delegate?.calendarViewDidTapPrevious(self)
    }

    @objc
    func handleNext() {
        delegate?.calendarViewDidTapNext(self)
    }
}

// MARK: - ProgressCalendarLegendView

final class ProgressCalendarLegendView: UIView {

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let goalDot = makeDot(color: .systemIndigo)
        let goalLabel = makeLabel(text: "Goal Met")
        let missedDot = makeDot(color: UIColor.systemRed.withAlphaComponent(0.85))
        let missedLabel = makeLabel(text: "Missed")
        let info = UIImageView(image: UIImage(systemName: "info.circle"))
        info.translatesAutoresizingMaskIntoConstraints = false
        info.tintColor = .tertiaryLabel
        info.contentMode = .scaleAspectFit

        let stack = UIStackView(arrangedSubviews: [
            goalDot, goalLabel,
            missedDot, missedLabel,
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4

        addSubview(stack)
        addSubview(info)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),

            info.centerYAnchor.constraint(equalTo: centerYAnchor),
            info.trailingAnchor.constraint(equalTo: trailingAnchor),
            info.widthAnchor.constraint(equalToConstant: 16),
            info.heightAnchor.constraint(equalToConstant: 16),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    private func makeDot(color: UIColor) -> UIView {
        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.backgroundColor = color
        dot.layer.cornerRadius = 4
        NSLayoutConstraint.activate([
            dot.widthAnchor.constraint(equalToConstant: 8),
            dot.heightAnchor.constraint(equalToConstant: 8),
        ])

        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(dot)
        NSLayoutConstraint.activate([
            dot.centerYAnchor.constraint(equalTo: wrapper.centerYAnchor),
            dot.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 8),
            dot.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
        ])

        return wrapper
    }

    private func makeLabel(text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel

        return label
    }
}

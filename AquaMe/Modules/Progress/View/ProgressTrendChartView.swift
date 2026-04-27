//
//  ProgressTrendChartView.swift
//  AquaMe
//
//  Created by Friday on 27.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - ProgressTrendChartView

/// 7-дневный bar chart внутри карточки\.
/// Слева — ось Y с 5 уровнями, по дну — короткие подписи дней недели\.
final class ProgressTrendChartView: UIView {

    // MARK: - Private enums

    private enum Constants {

        static let cornerRadius: CGFloat = 16
        static let borderWidth: CGFloat = 1
        static let padding: CGFloat = 16
        static let titleFontSize: CGFloat = 14
        static let badgeFontSize: CGFloat = 11
        static let badgeHeight: CGFloat = 22
        static let chartHeight: CGFloat = 160
        static let yAxisWidth: CGFloat = 40
        static let xAxisHeight: CGFloat = 22
        static let yAxisSteps: Int = 5
        static let axisFontSize: CGFloat = 10
        static let barCornerRadius: CGFloat = 5
        static let barSpacing: CGFloat = 8
        static let barHorizontalInset: CGFloat = 6
        /// На сколько раздуваем верх оси относительно реального максимума.
        static let yAxisHeadroom: Double = 1.1
        /// Если данных нет, ось всё равно рисуется — берём такой потолок.
        static let fallbackMaxValue: Int = 2600
    }

    // MARK: - Private properties

    private var bars: [UIView] = []
    private var weekdayLabels: [UILabel] = []
    private var yAxisLabels: [UILabel] = []
    private var maxValue: Int = 1

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "7-DAY INTAKE TREND"
        label.font = .systemFont(ofSize: Constants.titleFontSize, weight: .semibold)
        label.textColor = .label

        return label
    }()

    private lazy var badge: PaddedLabel = {
        let label = PaddedLabel(insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Active Week"
        label.font = .systemFont(ofSize: Constants.badgeFontSize, weight: .semibold)
        label.textColor = .systemIndigo
        label.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.12)
        label.layer.cornerRadius = Constants.badgeHeight / 2
        label.layer.masksToBounds = true

        return label
    }()

    private lazy var chartCanvas: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var yAxisStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .trailing
        stack.distribution = .equalSpacing

        return stack
    }()

    private lazy var barsRow: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = Constants.barSpacing

        return stack
    }()

    private lazy var xAxisRow: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.spacing = Constants.barSpacing

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

// MARK: - ProgressTrendChartView + Public

extension ProgressTrendChartView {

    func update(points: [ProgressTrendPoint], showsActiveWeekBadge: Bool) {
        badge.isHidden = !showsActiveWeekBadge
        rebuild(points: points)
    }
}

// MARK: - ProgressTrendChartView + Setup

private extension ProgressTrendChartView {

    func setup() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = Constants.cornerRadius
        layer.borderWidth = Constants.borderWidth
        layer.borderColor = UIColor.separator.withAlphaComponent(0.3).cgColor

        addSubview(titleLabel)
        addSubview(badge)
        addSubview(chartCanvas)
        chartCanvas.addSubview(yAxisStack)
        chartCanvas.addSubview(barsRow)
        addSubview(xAxisRow)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.padding),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),

            badge.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            badge.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
            badge.heightAnchor.constraint(equalToConstant: Constants.badgeHeight),

            chartCanvas.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            chartCanvas.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            chartCanvas.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
            chartCanvas.heightAnchor.constraint(equalToConstant: Constants.chartHeight),

            yAxisStack.topAnchor.constraint(equalTo: chartCanvas.topAnchor),
            yAxisStack.leadingAnchor.constraint(equalTo: chartCanvas.leadingAnchor),
            yAxisStack.bottomAnchor.constraint(equalTo: chartCanvas.bottomAnchor),
            yAxisStack.widthAnchor.constraint(equalToConstant: Constants.yAxisWidth),

            barsRow.topAnchor.constraint(equalTo: chartCanvas.topAnchor),
            barsRow.leadingAnchor.constraint(equalTo: yAxisStack.trailingAnchor, constant: 8),
            barsRow.trailingAnchor.constraint(equalTo: chartCanvas.trailingAnchor),
            barsRow.bottomAnchor.constraint(equalTo: chartCanvas.bottomAnchor),

            xAxisRow.topAnchor.constraint(equalTo: chartCanvas.bottomAnchor, constant: 6),
            xAxisRow.leadingAnchor.constraint(equalTo: barsRow.leadingAnchor),
            xAxisRow.trailingAnchor.constraint(equalTo: barsRow.trailingAnchor),
            xAxisRow.heightAnchor.constraint(equalToConstant: Constants.xAxisHeight),
            xAxisRow.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.padding),
        ])
    }

    func rebuild(points: [ProgressTrendPoint]) {
        let peak = points.map(\.totalMl).max() ?? 0
        maxValue = peak < 100
            ? Constants.fallbackMaxValue
            : Int((Double(peak) * Constants.yAxisHeadroom / 100).rounded()) * 100
        rebuildYAxis()
        rebuildBars(points: points)
        rebuildXAxis(points: points)
    }

    func rebuildYAxis() {
        yAxisStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        yAxisLabels = []

        for step in 0..<Constants.yAxisSteps {
            let value = maxValue * (Constants.yAxisSteps - 1 - step) / (Constants.yAxisSteps - 1)
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "\(value)"
            label.font = .systemFont(ofSize: Constants.axisFontSize, weight: .medium)
            label.textColor = .secondaryLabel
            label.textAlignment = .right
            yAxisStack.addArrangedSubview(label)
            yAxisLabels.append(label)
        }
    }

    func rebuildBars(points: [ProgressTrendPoint]) {
        barsRow.arrangedSubviews.forEach { $0.removeFromSuperview() }
        bars = []

        for point in points {
            let column = UIView()
            column.translatesAutoresizingMaskIntoConstraints = false

            let bar = UIView()
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.backgroundColor = point.reachedGoal
                ? UIColor.systemGreen.withAlphaComponent(0.55)
                : UIColor.systemIndigo.withAlphaComponent(0.85)
            bar.layer.cornerRadius = Constants.barCornerRadius
            bar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            column.addSubview(bar)

            let ratio = CGFloat(min(maxValue, point.totalMl)) / CGFloat(maxValue)
            NSLayoutConstraint.activate([
                bar.bottomAnchor.constraint(equalTo: column.bottomAnchor),
                bar.leadingAnchor.constraint(equalTo: column.leadingAnchor, constant: Constants.barHorizontalInset),
                bar.trailingAnchor.constraint(equalTo: column.trailingAnchor, constant: -Constants.barHorizontalInset),
                bar.heightAnchor.constraint(equalTo: column.heightAnchor, multiplier: max(0.02, ratio)),
            ])
            bars.append(bar)
            barsRow.addArrangedSubview(column)
        }
    }

    func rebuildXAxis(points: [ProgressTrendPoint]) {
        xAxisRow.arrangedSubviews.forEach { $0.removeFromSuperview() }
        weekdayLabels = []

        for point in points {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = point.weekdayShort
            label.font = .systemFont(ofSize: Constants.axisFontSize, weight: .medium)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            xAxisRow.addArrangedSubview(label)
            weekdayLabels.append(label)
        }
    }
}

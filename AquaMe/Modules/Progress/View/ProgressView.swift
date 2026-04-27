//
//  ProgressView.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - ProgressViewDelegate

protocol ProgressViewDelegate: AnyObject {

    func progressViewDidTapPreviousMonth(_ view: ProgressView)
    func progressViewDidTapNextMonth(_ view: ProgressView)
}

// MARK: - ProgressView

final class ProgressView: UIView {

    // MARK: - Private enums

    private enum Constants {

        static let horizontalPadding: CGFloat = 20
        static let sectionSpacing: CGFloat = 24
        static let groupSpacing: CGFloat = 12
        static let columnSpacing: CGFloat = 12
    }

    private enum Images {

        static let trophy = UIImage(systemName: "trophy.fill")
        static let drop = UIImage(systemName: "drop.fill")
        static let trendUp = UIImage(systemName: "chart.line.uptrend.xyaxis")
        static let calendar = UIImage(systemName: "calendar")
        static let medal = UIImage(systemName: "medal.fill")
    }

    // MARK: - Public properties

    weak var delegate: ProgressViewDelegate?

    // MARK: - Private properties

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false

        return view
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = Constants.sectionSpacing

        return stack
    }()

    private lazy var calendarView: ProgressCalendarView = {
        let view = ProgressCalendarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self

        return view
    }()

    private lazy var avgIntakeCard = ProgressStatCard()
    private lazy var bestDayCard = ProgressStatCard()
    private lazy var bestWeekCard = ProgressStatCard()
    private lazy var streakCard = ProgressStatCard()
    private lazy var trendChart = ProgressTrendChartView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - ProgressView + Public

extension ProgressView {

    func update(with state: ProgressState) {
        calendarView.update(monthTitle: state.monthTitle, days: state.days)

        let stats = state.stats
        let unit = state.unit

        avgIntakeCard.update(with: ProgressStatCardModel(
            icon: Images.drop,
            title: "Avg Intake",
            value: formatNumber(unit.format(ml: stats.avgIntakeMl)),
            unit: unit.rawValue,
            badge: formatPercentBadge(stats.avgChangePercent),
            badgeTone: stats.avgChangePercent >= 0 ? .positive : .neutral
        ))

        bestDayCard.update(with: ProgressStatCardModel(
            icon: Images.trendUp,
            title: "Best Day",
            value: formatNumber(unit.format(ml: stats.bestDayMl)),
            unit: unit.rawValue,
            badge: nil,
            badgeTone: .neutral
        ))

        let bestWeek = formatBestWeek(ml: stats.bestWeekMl, unit: unit)
        bestWeekCard.update(with: ProgressStatCardModel(
            icon: Images.calendar,
            title: "Best Week",
            value: bestWeek.value,
            unit: bestWeek.unit,
            badge: stats.isCurrentWeekBest ? "Current" : nil,
            badgeTone: .neutral
        ))

        streakCard.update(with: ProgressStatCardModel(
            icon: Images.medal,
            title: "Streak",
            value: "\(stats.streakDays)",
            unit: "days",
            badge: stats.streakDelta > 0 ? "+\(stats.streakDelta)" : nil,
            badgeTone: .neutral
        ))

        trendChart.update(
            points: state.trend,
            showsActiveWeekBadge: stats.isCurrentWeekBest
        )
    }
}

// MARK: - ProgressView + ProgressCalendarViewDelegate

extension ProgressView: ProgressCalendarViewDelegate {

    func calendarViewDidTapPrevious(_ view: ProgressCalendarView) {
        delegate?.progressViewDidTapPreviousMonth(self)
    }

    func calendarViewDidTapNext(_ view: ProgressCalendarView) {
        delegate?.progressViewDidTapNextMonth(self)
    }
}

// MARK: - ProgressView + Setup

private extension ProgressView {

    func setup() {
        backgroundColor = .systemBackground
        addSubview(scrollView)
        scrollView.addSubview(contentStack)
        setupContent()
        setupConstraints()
    }

    func setupContent() {
        contentStack.addArrangedSubview(calendarView)

        let perfHeader = SettingsSectionHeader(icon: Images.trophy, title: "Performance Stats")
        perfHeader.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(perfHeader)
        contentStack.setCustomSpacing(Constants.groupSpacing, after: perfHeader)

        let topStatsRow = makeRow(views: [avgIntakeCard, bestDayCard])
        let bottomStatsRow = makeRow(views: [bestWeekCard, streakCard])
        contentStack.addArrangedSubview(topStatsRow)
        contentStack.addArrangedSubview(bottomStatsRow)
        contentStack.setCustomSpacing(Constants.groupSpacing, after: topStatsRow)

        contentStack.addArrangedSubview(trendChart)
    }

    func makeRow(views: [UIView]) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = Constants.columnSpacing

        return stack
    }

    func setupConstraints() {
        let frameGuide = scrollView.frameLayoutGuide
        let contentGuide = scrollView.contentLayoutGuide

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: contentGuide.topAnchor, constant: 12),
            contentStack.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor, constant: -24),
            contentStack.leadingAnchor.constraint(
                equalTo: contentGuide.leadingAnchor,
                constant: Constants.horizontalPadding
            ),
            contentStack.trailingAnchor.constraint(
                equalTo: contentGuide.trailingAnchor,
                constant: -Constants.horizontalPadding
            ),
            contentStack.widthAnchor.constraint(
                equalTo: frameGuide.widthAnchor,
                constant: -Constants.horizontalPadding * 2
            ),
        ])
    }

    static let groupedFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","

        return formatter
    }()

    func formatNumber(_ value: String) -> String {
        guard let intValue = Int(value) else { return value }

        return Self.groupedFormatter.string(from: NSNumber(value: intValue)) ?? value
    }

    func formatPercentBadge(_ percent: Int) -> String? {
        guard percent != 0 else { return nil }

        let sign = percent > 0 ? "+" : ""

        return "\(sign)\(percent)%"
    }

    /// Best Week выводим в крупных единицах: литры в метрической, oz в имперской.
    /// Хранится канонически в мл — конвертируется только тут на дисплее.
    func formatBestWeek(ml: Int, unit: UserProfile.MeasureUnit) -> (value: String, unit: String) {
        switch unit {
        case .ml:
            return (String(format: "%.1f", Double(ml) / 1000), "L")

        case .oz:
            let totalOz = Int((Double(ml) / UserProfile.MeasureUnit.mlPerOunce).rounded())

            return ("\(totalOz)", "oz")
        }
    }
}

//
//  ProgressViewModel.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import Foundation

// MARK: - ProgressViewModel

/// Бизнес-логика экрана прогресса.
/// Грузит профиль (для дневной нормы) и записи воды за нужный диапазон, считает агрегаты.
final class ProgressViewModel: ProgressViewModelProtocol {

    // MARK: - Public properties

    var onStateChange: ((ProgressState) -> Void)?
    private(set) var state: ProgressState

    // MARK: - Private properties

    private let profileService: ProfileServiceProtocol
    private let storage: WaterStorageProtocol
    private let calendar: Calendar
    private let monthFormatter: DateFormatter
    private let weekdayFormatter: DateFormatter

    private var visibleMonthAnchor: Date
    private var dailyGoal: Int = 2400

    // MARK: - Initialization

    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        storage: WaterStorageProtocol = WaterStorage.shared,
        calendar: Calendar = .current
    ) {
        self.profileService = profileService
        self.storage = storage
        var calendar = calendar
        calendar.firstWeekday = 2 // Monday
        self.calendar = calendar
        self.visibleMonthAnchor = calendar.startOfMonth(for: Date())

        let monthFormatter = DateFormatter()
        monthFormatter.locale = Locale.current
        monthFormatter.setLocalizedDateFormatFromTemplate("LLLLyyyy")
        self.monthFormatter = monthFormatter

        let weekdayFormatter = DateFormatter()
        weekdayFormatter.locale = Locale.current
        weekdayFormatter.setLocalizedDateFormatFromTemplate("EEE")
        self.weekdayFormatter = weekdayFormatter

        self.state = ProgressState(
            monthTitle: monthFormatter.string(from: visibleMonthAnchor).capitalized,
            days: [],
            trend: [],
            stats: ProgressStats(
                avgIntakeMl: 0,
                avgChangePercent: 0,
                bestDayMl: 0,
                bestWeekMl: 0,
                isCurrentWeekBest: false,
                streakDays: 0,
                streakDelta: 0
            ),
            unit: .ml,
            isLoading: true
        )
    }

    // MARK: - ProgressViewModelProtocol

    func viewDidLoad() {
        emit()
        loadProfileThenData()
    }

    func didTapPreviousMonth() {
        guard let prev = calendar.date(byAdding: .month, value: -1, to: visibleMonthAnchor) else { return }

        visibleMonthAnchor = prev
        state.monthTitle = monthFormatter.string(from: visibleMonthAnchor).capitalized
        state.isLoading = true
        emit()
        loadData()
    }

    func didTapNextMonth() {
        guard let next = calendar.date(byAdding: .month, value: 1, to: visibleMonthAnchor) else { return }

        // Не пускаем в будущие месяцы — статистика и trend всё равно про сегодня,
        // а календарь там рисует одни future-дни. Бесполезно и сбивает юзера.
        let currentMonthStart = calendar.startOfMonth(for: Date())
        guard next <= currentMonthStart else { return }

        visibleMonthAnchor = next
        state.monthTitle = monthFormatter.string(from: visibleMonthAnchor).capitalized
        state.isLoading = true
        emit()
        loadData()
    }
}

// MARK: - ProgressViewModel + Private

private extension ProgressViewModel {

    func loadProfileThenData() {
        profileService.loadProfile { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                if case .success(let profile) = result {
                    self.dailyGoal = max(1, profile.dailyGoal)
                    self.state.unit = profile.unit
                }
                self.loadData()
            }
        }
    }

    /// Грузит записи за окно: 14 дней до начала отображаемого месяца — этого хватает на
    /// `prev avg` для текущего месяца. Если visible month в прошлом, окно расширяется до
    /// сегодня, чтобы trend/stats оставались актуальными.
    func loadData() {
        let monthStart = calendar.startOfMonth(for: visibleMonthAnchor)
        guard let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else { return }

        let today = calendar.startOfDay(for: Date())
        let windowStart = calendar.date(byAdding: .day, value: -14, to: monthStart) ?? monthStart
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        let windowEnd = max(monthEnd, tomorrow)

        storage.loadRecords(from: windowStart, to: windowEnd) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                let records: [WaterRecord]

                switch result {
                case .success(let loaded):
                    records = loaded

                case .failure(let error):
                    print("[Progress] loadRecords failed: \(error.localizedDescription)")
                    records = []
                }

                self.recompute(records: records, monthStart: monthStart, monthEnd: monthEnd)
            }
        }
    }

    func recompute(records: [WaterRecord], monthStart: Date, monthEnd: Date) {
        var dailyTotals = Self.dailyTotals(records: records, calendar: calendar)

        #if DEBUG
        if dailyTotals.isEmpty {
            dailyTotals = Self.mockTotals(
                monthStart: monthStart,
                monthEnd: monthEnd,
                dailyGoal: dailyGoal,
                calendar: calendar
            )
        }
        #endif

        state.days = buildCalendarDays(
            monthStart: monthStart,
            monthEnd: monthEnd,
            dailyTotals: dailyTotals
        )
        state.trend = buildTrend(dailyTotals: dailyTotals)
        state.stats = buildStats(dailyTotals: dailyTotals)
        state.isLoading = false
        emit()
    }

    func buildCalendarDays(
        monthStart: Date,
        monthEnd: Date,
        dailyTotals: [Date: Int]
    ) -> [ProgressDay] {
        // Дополнение до начала недели — независимо от того, какой firstWeekday у календаря.
        let weekday = calendar.component(.weekday, from: monthStart)
        let leadingPad = (weekday - calendar.firstWeekday + 7) % 7
        let today = calendar.startOfDay(for: Date())

        var days: [ProgressDay] = []

        if leadingPad > 0,
           let prevDayBefore = calendar.date(byAdding: .day, value: -leadingPad, to: monthStart) {
            for offset in 0..<leadingPad {
                guard let date = calendar.date(byAdding: .day, value: offset, to: prevDayBefore) else { continue }

                days.append(ProgressDay(
                    date: date,
                    dayNumber: nil,
                    status: .pending,
                    isToday: false
                ))
            }
        }

        var cursor = monthStart
        while cursor < monthEnd {
            let total = dailyTotals[cursor] ?? 0
            let isPast = cursor < today
            let status = WaterDayStatus.classify(
                total: total,
                dailyGoal: dailyGoal,
                isPast: isPast
            )
            let dayNumber = calendar.component(.day, from: cursor)

            days.append(ProgressDay(
                date: cursor,
                dayNumber: dayNumber,
                status: status,
                isToday: calendar.isDate(cursor, inSameDayAs: today)
            ))

            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }

            cursor = next
        }

        // Хвостовое дополнение до полной недели
        let trailingPad = (7 - days.count % 7) % 7

        for offset in 0..<trailingPad {
            guard let date = calendar.date(byAdding: .day, value: offset, to: cursor) else { continue }

            days.append(ProgressDay(
                date: date,
                dayNumber: nil,
                status: .pending,
                isToday: false
            ))
        }

        return days
    }

    func buildTrend(dailyTotals: [Date: Int]) -> [ProgressTrendPoint] {
        let today = calendar.startOfDay(for: Date())
        var points: [ProgressTrendPoint] = []

        for offset in (0..<7).reversed() {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }

            let total = dailyTotals[day] ?? 0
            let weekday = weekdayFormatter.string(from: day)
            points.append(ProgressTrendPoint(
                weekdayShort: weekday,
                totalMl: total,
                reachedGoal: total >= dailyGoal
            ))
        }

        return points
    }

    func buildStats(dailyTotals: [Date: Int]) -> ProgressStats {
        let today = calendar.startOfDay(for: Date())
        let last7Days = (0..<7).compactMap { offset -> Int? in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }

            return dailyTotals[day]
        }
        let prev7Days = (7..<14).compactMap { offset -> Int? in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }

            return dailyTotals[day]
        }

        let avg = last7Days.isEmpty ? 0 : last7Days.reduce(0, +) / last7Days.count
        let prevAvg = prev7Days.isEmpty ? 0 : prev7Days.reduce(0, +) / prev7Days.count
        let avgChange: Int = prevAvg == 0
            ? 0
            : Int(((Double(avg) - Double(prevAvg)) / Double(prevAvg) * 100).rounded())

        let bestDay = dailyTotals.values.max() ?? 0

        // Текущая неделя — недо-неделя, оценивается отдельно: считаем уже накопленную сумму
        // и сравниваем с лучшей из ПОЛНЫХ недель.
        let currentWeekMl = sumOfWeek(dailyTotals: dailyTotals, weekOffset: 0, today: today)
        let completedWeeksMl = (1..<4).map { offset in
            sumOfWeek(dailyTotals: dailyTotals, weekOffset: offset, today: today)
        }
        let bestCompletedWeek = completedWeeksMl.max() ?? 0
        let bestWeekMl = max(currentWeekMl, bestCompletedWeek)
        let isCurrentWeekBest = currentWeekMl > 0 && currentWeekMl >= bestCompletedWeek

        let streak = currentStreak(dailyTotals: dailyTotals, from: today)
        let prevStreak = currentStreak(
            dailyTotals: dailyTotals,
            from: calendar.date(byAdding: .day, value: -7, to: today) ?? today
        )

        return ProgressStats(
            avgIntakeMl: avg,
            avgChangePercent: avgChange,
            bestDayMl: bestDay,
            bestWeekMl: bestWeekMl,
            isCurrentWeekBest: isCurrentWeekBest,
            streakDays: streak,
            streakDelta: streak - prevStreak
        )
    }

    func sumOfWeek(dailyTotals: [Date: Int], weekOffset: Int, today: Date) -> Int {
        (0..<7).compactMap { dayOffset -> Int? in
            let totalOffset = weekOffset * 7 + dayOffset
            guard let day = calendar.date(byAdding: .day, value: -totalOffset, to: today) else { return nil }

            return dailyTotals[day]
        }.reduce(0, +)
    }

    /// Сколько подряд идущих дней до `from` включительно достигнута цель.
    /// Если `from == today` и норма ещё не выполнена — день пропускается, чтобы streak
    /// не обнулялся пока день не закончился.
    func currentStreak(dailyTotals: [Date: Int], from start: Date) -> Int {
        var count = 0
        var cursor = start
        let today = calendar.startOfDay(for: Date())

        if cursor == today, (dailyTotals[cursor] ?? 0) < dailyGoal {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor) else { return 0 }

            cursor = yesterday
        }

        while true {
            let total = dailyTotals[cursor] ?? 0

            if total >= dailyGoal {
                count += 1
            } else {
                break
            }

            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }

            cursor = prev
        }

        return count
    }

    static func dailyTotals(records: [WaterRecord], calendar: Calendar) -> [Date: Int] {
        var totals: [Date: Int] = [:]

        for record in records {
            let day = calendar.startOfDay(for: record.date)
            totals[day, default: 0] += record.amount
        }

        for key in totals.keys where totals[key] ?? 0 < 0 {
            totals[key] = 0
        }

        return totals
    }

    func emit() {
        onStateChange?(state)
    }
}

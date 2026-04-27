//
//  ProgressViewModelProtocol.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import Foundation

// MARK: - ProgressDay

/// Один день в гриде календаря.
struct ProgressDay: Equatable {

    let date: Date
    /// Число месяца (1...31). Если день не из текущего месяца — `nil`.
    let dayNumber: Int?
    let status: WaterDayStatus
    let isToday: Bool
}

// MARK: - ProgressTrendPoint

/// Точка для bar-чарта (последние 7 дней).
struct ProgressTrendPoint: Equatable {

    let weekdayShort: String
    let totalMl: Int
    let reachedGoal: Bool
}

// MARK: - ProgressStats

struct ProgressStats: Equatable {

    let avgIntakeMl: Int
    let avgChangePercent: Int
    let bestDayMl: Int
    let bestWeekMl: Int
    let isCurrentWeekBest: Bool
    let streakDays: Int
    let streakDelta: Int
}

// MARK: - ProgressState

struct ProgressState: Equatable {

    var monthTitle: String
    var days: [ProgressDay]
    var trend: [ProgressTrendPoint]
    var stats: ProgressStats
    var unit: UserProfile.MeasureUnit
    var isLoading: Bool
}

// MARK: - ProgressViewModelProtocol

protocol ProgressViewModelProtocol: AnyObject {

    var state: ProgressState { get }
    var onStateChange: ((ProgressState) -> Void)? { get set }

    func viewDidLoad()
    func didTapPreviousMonth()
    func didTapNextMonth()
}

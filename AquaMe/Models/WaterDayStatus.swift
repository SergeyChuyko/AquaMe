//
//  WaterDayStatus.swift
//  AquaMe
//
//  Created by Friday on 27.04.2026.
//  Copyright © 2026. All rights reserved.
//

import Foundation

// MARK: - WaterDayStatus

/// Сводный статус дня для подсветки ячейки календаря.
/// Считается из суммарного выпитого за день и дневной нормы.
enum WaterDayStatus: Equatable {

    /// Будущее или сегодняшний день, по которому цель ещё не достигнута, — нейтрально-светлый.
    case pending
    /// Прошедший день, в котором выпито мало (< partialThreshold от нормы) — серый.
    case missed
    /// Прошедший день, частично закрытый (от partialThreshold до нормы) — розовый.
    case partial
    /// Норма выполнена — индиго.
    case goalMet

    /// День «частично» если выпито хотя бы столько от нормы.
    static let partialThreshold: Double = 0.5

    /// `isPast` означает строго прошедший день (вчера и раньше). Сегодня к past не относится.
    static func classify(total: Int, dailyGoal: Int, isPast: Bool) -> WaterDayStatus {
        guard dailyGoal > 0 else { return .pending }

        if total >= dailyGoal { return .goalMet }

        guard isPast else { return .pending }

        let ratio = Double(total) / Double(dailyGoal)

        return ratio >= partialThreshold ? .partial : .missed
    }
}

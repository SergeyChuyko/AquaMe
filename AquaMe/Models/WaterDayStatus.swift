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

    /// Будущее или сегодняшний день, по которому цель ещё не достигнута, — нейтрально серый.
    case pending
    /// Прошедший день, в котором норма не выполнена, — красный.
    case missed
    /// Норма выполнена — индиго.
    case goalMet

    /// `isPast` означает строго прошедший день (вчера и раньше). Сегодня к past не относится.
    static func classify(total: Int, dailyGoal: Int, isPast: Bool) -> WaterDayStatus {
        guard dailyGoal > 0 else { return .pending }

        if total >= dailyGoal { return .goalMet }

        return isPast ? .missed : .pending
    }
}

//
//  ProgressViewModel+Mock.swift
//  AquaMe
//
//  Created by Friday on 27.04.2026.
//  Copyright © 2026. All rights reserved.
//

#if DEBUG

import Foundation

extension ProgressViewModel {

    /// Циклический сэмпл данных за прошедшие дни месяца — Goal Met / Partial / Missed.
    /// Включается только в Debug-билде и только когда из storage реально пусто.
    /// TODO: убрать когда вся реальная цепочка с Firestore-rules заработает в проде.
    static func mockTotals(
        monthStart: Date,
        monthEnd: Date,
        dailyGoal: Int,
        calendar: Calendar
    ) -> [Date: Int] {
        var totals: [Date: Int] = [:]
        let today = calendar.startOfDay(for: Date())
        var cursor = monthStart

        while cursor < monthEnd && cursor < today {
            let dayNumber = calendar.component(.day, from: cursor)
            let bucket = dayNumber % 3
            let ratio: Double

            switch bucket {
            case 0:
                ratio = 1.0 + Double(dayNumber % 4) * 0.05  // goalMet, 100..115%

            case 1:
                ratio = 0.55 + Double(dayNumber % 4) * 0.08  // partial, 55..79%

            default:
                ratio = 0.10 + Double(dayNumber % 4) * 0.07  // missed, 10..31%
            }

            totals[cursor] = Int(Double(dailyGoal) * ratio)

            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }

            cursor = next
        }

        return totals
    }
}

#endif

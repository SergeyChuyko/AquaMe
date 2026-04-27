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

    case future
    case missed
    case partial
    case goalMet

    /// Порог "partial" — день засчитывается жёлтым/розовым если выпито хотя бы столько от нормы.
    static let partialThreshold: Double = 0.5

    static func classify(total: Int, dailyGoal: Int, isFuture: Bool) -> WaterDayStatus {
        if isFuture { return .future }
        guard dailyGoal > 0 else { return .missed }

        let ratio = Double(total) / Double(dailyGoal)

        if ratio >= 1 {
            return .goalMet
        } else if ratio >= partialThreshold {
            return .partial
        } else {
            return .missed
        }
    }
}

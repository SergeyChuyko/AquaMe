//
//  WaterRecord.swift
//  AquaMe
//
//  Created by Friday on 25.04.2026.
//  Copyright © 2026. All rights reserved.
//

import Foundation

// MARK: - WaterRecord

/// Запись о потреблении воды.
/// Положительное `amount` — выпито. Отрицательное — отмена/убавление при ошибочном вводе.
struct WaterRecord: Codable, Equatable {

    let id: UUID
    let amount: Int
    let date: Date

    init(id: UUID = UUID(), amount: Int, date: Date = Date()) {
        self.id = id
        self.amount = amount
        self.date = date
    }
}

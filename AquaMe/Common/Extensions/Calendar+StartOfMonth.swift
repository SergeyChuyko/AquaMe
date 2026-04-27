//
//  Calendar+StartOfMonth.swift
//  AquaMe
//
//  Created by Friday on 27.04.2026.
//  Copyright © 2026. All rights reserved.
//

import Foundation

// MARK: - Calendar + StartOfMonth

extension Calendar {

    /// Возвращает первое число месяца, в котором лежит `date`. На случай ошибки —
    /// откатываемся на startOfDay, чтобы вызывающий гарантированно получил Date.
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)

        return self.date(from: components) ?? startOfDay(for: date)
    }
}

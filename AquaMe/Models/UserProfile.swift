//
//  UserProfile.swift
//  AquaMe
//
//  Created by Friday on 19.04.2026.
//  Copyright © 2026. All rights reserved.
//

import Foundation

// MARK: - UserProfile

struct UserProfile: Codable {

    let uid: String
    var name: String
    var age: Int
    var weight: Double
    var goal: Goal
    var avatarURL: String?
    var unit: MeasureUnit
    var dailyGoal: Int
    var memberSince: Date
    /// Включены ли push-напоминания о воде. Optional, чтобы старые документы декодировались.
    var remindersEnabled: Bool?
    /// Время начала напоминаний в формате "HH:mm". Optional по той же причине.
    var reminderStartTime: String?

    // MARK: - Goal

    enum Goal: String, Codable {

        case stayHealthy
        case loseWeight
        case stayActive
    }

    // MARK: - MeasureUnit

    enum MeasureUnit: String, Codable {

        case ml
        case oz
    }
}

// MARK: - UserProfile.MeasureUnit + System

/// `unit` хранит выбранную систему измерения целиком: `.ml` означает метрическую (мл + кг),
/// `.oz` означает имперскую (oz + lb). Хранение остаётся одним полем для совместимости с уже
/// созданными документами в Firestore.
extension UserProfile.MeasureUnit {

    /// US fluid ounce → мл. Используется одинаково при чтении и записи,
    /// чтобы избежать рассинхрона.
    static let mlPerOunce: Double = 29.5735

    /// Фунтов в килограмме (имперский фунт).
    static let lbPerKg: Double = 2.20462

    /// Подпись для лейбла «WEIGHT (KG)» / «WEIGHT (LB)».
    var weightLabel: String {
        switch self {
        case .ml: return "KG"
        case .oz: return "LB"
        }
    }

    /// Превращает значение в мл в строку в текущих единицах: "2460" в режиме .ml или "83" в .oz.
    func format(ml value: Int) -> String {
        switch self {
        case .ml: return "\(value)"
        case .oz: return "\(Int((Double(value) / Self.mlPerOunce).rounded()))"
        }
    }

    /// Парсит значение, которое юзер ввёл в текущих единицах, и приводит к мл.
    func mlValue(from displayValue: Double) -> Int {
        switch self {
        case .ml: return Int(displayValue.rounded())
        case .oz: return Int((displayValue * Self.mlPerOunce).rounded())
        }
    }

    /// Превращает вес в кг в строку в текущих единицах: "82" в .ml или "181" в .oz.
    func formatWeight(kg value: Double) -> String {
        switch self {
        case .ml: return "\(Int(value.rounded()))"
        case .oz: return "\(Int((value * Self.lbPerKg).rounded()))"
        }
    }

    /// Парсит значение веса, введённое в текущих единицах, и приводит к кг.
    func kgValue(from displayValue: Double) -> Double {
        switch self {
        case .ml: return displayValue
        case .oz: return displayValue / Self.lbPerKg
        }
    }
}

// MARK: - UserProfile + Daily Goal Calculation

extension UserProfile {

    static func calculateDailyGoal(weight: Double, goal: Goal) -> Int {
        let base = weight * 30
        switch goal {
        case .stayHealthy:
            return Int(base)

        case .loseWeight:
            return Int(base * 1.1)

        case .stayActive:
            return Int(base * 1.2)
        }
    }
}

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

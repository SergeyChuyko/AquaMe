//
//  SettingsViewModelProtocol.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import Foundation

// MARK: - SettingsState

struct SettingsState: Equatable {

    var dailyGoal: Int
    var recommendedDailyGoal: Int
    var weight: Double
    var age: Int
    var unit: UserProfile.MeasureUnit
    var remindersEnabled: Bool
    var reminderStartTime: String
    var appVersion: String
}

// MARK: - SettingsViewModelProtocol

protocol SettingsViewModelProtocol: AnyObject {

    var state: SettingsState { get }
    var onStateChange: ((SettingsState) -> Void)? { get set }

    func viewDidLoad()

    func didChangeDailyGoal(_ value: Int)
    func didChangeWeight(_ value: Double)
    func didChangeAge(_ value: Int)
    func didChangeUnit(_ unit: UserProfile.MeasureUnit)
    func didToggleReminders(_ isOn: Bool)
    func didChangeReminderTime(_ value: String)
}

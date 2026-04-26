//
//  SettingsViewModel.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import Foundation

// MARK: - SettingsViewModel

/// Бизнес-логика экрана настроек: грузит профиль, эмитит state и сохраняет каждое изменение
/// обратно в Firestore через ProfileService.
final class SettingsViewModel: SettingsViewModelProtocol {

    // MARK: - Private enums

    private enum Defaults {

        static let dailyGoal = 2400
        static let weight: Double = 70
        static let age = 25
        static let reminderStartTime = "08:30"
    }

    // MARK: - Public properties

    var onStateChange: ((SettingsState) -> Void)?
    private(set) var state: SettingsState

    // MARK: - Private properties

    private let profileService: ProfileServiceProtocol
    private var profile: UserProfile?

    // MARK: - Initialization

    init(profileService: ProfileServiceProtocol = ProfileService.shared) {
        self.profileService = profileService
        self.state = SettingsState(
            dailyGoal: Defaults.dailyGoal,
            recommendedDailyGoal: Defaults.dailyGoal,
            weight: Defaults.weight,
            age: Defaults.age,
            unit: .ml,
            remindersEnabled: false,
            reminderStartTime: Defaults.reminderStartTime,
            appVersion: Self.bundleVersionString()
        )
    }

    // MARK: - SettingsViewModelProtocol

    func viewDidLoad() {
        emit()
        loadProfile()
    }

    func didChangeDailyGoal(_ value: Int) {
        let clamped = max(500, min(8000, value))
        guard state.dailyGoal != clamped else { return }
        state.dailyGoal = clamped
        emit()
        update { $0.dailyGoal = clamped }
    }

    func didChangeWeight(_ value: Double) {
        let clamped = max(20, min(300, value))
        guard state.weight != clamped else { return }
        state.weight = clamped
        state.recommendedDailyGoal = UserProfile.calculateDailyGoal(
            weight: clamped,
            goal: profile?.goal ?? .stayHealthy
        )
        emit()
        update { $0.weight = clamped }
    }

    func didChangeAge(_ value: Int) {
        let clamped = max(1, min(120, value))
        guard state.age != clamped else { return }
        state.age = clamped
        emit()
        update { $0.age = clamped }
    }

    func didChangeUnit(_ unit: UserProfile.MeasureUnit) {
        guard state.unit != unit else { return }
        state.unit = unit
        emit()
        update { $0.unit = unit }
    }

    func didToggleReminders(_ isOn: Bool) {
        guard state.remindersEnabled != isOn else { return }
        state.remindersEnabled = isOn
        emit()
        update { $0.remindersEnabled = isOn }
    }

    func didChangeReminderTime(_ value: String) {
        guard state.reminderStartTime != value else { return }
        state.reminderStartTime = value
        emit()
        update { $0.reminderStartTime = value }
    }
}

// MARK: - SettingsViewModel + Private

private extension SettingsViewModel {

    func loadProfile() {
        profileService.loadProfile { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                guard case .success(let profile) = result else { return }
                self.profile = profile
                self.state.dailyGoal = profile.dailyGoal
                self.state.recommendedDailyGoal = UserProfile.calculateDailyGoal(
                    weight: profile.weight,
                    goal: profile.goal
                )
                self.state.weight = profile.weight
                self.state.age = profile.age
                self.state.unit = profile.unit
                self.state.remindersEnabled = profile.remindersEnabled ?? false
                self.state.reminderStartTime = profile.reminderStartTime ?? Defaults.reminderStartTime
                self.emit()
            }
        }
    }

    func update(_ change: (inout UserProfile) -> Void) {
        guard var profile else { return }
        change(&profile)
        self.profile = profile
        profileService.saveProfile(profile) { _ in }
    }

    func emit() {
        onStateChange?(state)
    }

    static func bundleVersionString() -> String {
        let info = Bundle.main.infoDictionary ?? [:]
        let version = info["CFBundleShortVersionString"] as? String ?? "1.0"
        return "AQUAME V\(version) • HYDRATE BETTER"
    }
}

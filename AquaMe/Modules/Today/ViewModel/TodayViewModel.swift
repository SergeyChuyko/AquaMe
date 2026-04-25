//
//  TodayViewModel.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import Foundation

// MARK: - TodayViewModel

/// Бизнес-логика экрана Today.
/// Загружает профиль (для дневной нормы), хранит выпитое за сегодня, отдаёт во view готовый TodayState.
final class TodayViewModel: TodayViewModelProtocol {

    // MARK: - Private enums

    private enum Defaults {

        static let dailyGoal = 2400
        static let selectedAmount = 250
        static let presets = [250, 500]
        static let quick = [100, 200, 300, 400]
    }

    // MARK: - Public properties

    var title: String { "AquaMe" }
    var onStateChange: ((TodayState) -> Void)?

    private(set) var state: TodayState

    // MARK: - Private properties

    private let profileService: ProfileServiceProtocol
    private let storage: WaterStorageProtocol

    // MARK: - Initialization

    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        storage: WaterStorageProtocol = WaterStorage.shared
    ) {
        self.profileService = profileService
        self.storage = storage
        self.state = TodayState(
            totalDrunk: storage.todayTotal(),
            dailyGoal: Defaults.dailyGoal,
            selectedAmount: Defaults.selectedAmount,
            isRemoveMode: false,
            presetAmounts: Defaults.presets,
            quickAmounts: Defaults.quick,
            avatarPath: nil,
            unit: .ml
        )
    }

    // MARK: - TodayViewModelProtocol

    func viewDidLoad() {
        emit()
        loadProfile()
    }

    func didSelectPreset(amount: Int) {
        guard state.selectedAmount != amount else { return }
        state.selectedAmount = amount
        emit()
    }

    func didToggleRemoveMode(_ isOn: Bool) {
        guard state.isRemoveMode != isOn else { return }
        state.isRemoveMode = isOn
        emit()
    }

    func didTapLogIntake() {
        commit(amount: state.selectedAmount)
    }

    func didTapQuickAmount(_ amount: Int) {
        commit(amount: amount)
    }
}

// MARK: - TodayViewModel + Private

private extension TodayViewModel {

    func commit(amount: Int) {
        guard amount > 0 else { return }
        let signed = state.isRemoveMode ? -amount : amount
        storage.add(WaterRecord(amount: signed))
        state.totalDrunk = storage.todayTotal()
        emit()
    }

    func loadProfile() {
        profileService.loadProfile { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                guard case .success(let profile) = result else { return }
                self.state.dailyGoal = max(1, profile.dailyGoal)
                self.state.avatarPath = profile.avatarURL
                self.state.unit = profile.unit
                self.emit()
            }
        }
    }

    func emit() {
        onStateChange?(state)
    }
}

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
/// Грузит профиль (для дневной нормы) и сегодняшние записи воды из Firestore,
/// поддерживает мгновенный оптимистический ответ на тап и фоновую запись на сервер.
final class TodayViewModel: TodayViewModelProtocol {

    // MARK: - Private enums

    private enum Defaults {

        static let dailyGoal = 2400
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
    private var records: [WaterRecord] = []

    // MARK: - Initialization

    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        storage: WaterStorageProtocol = WaterStorage.shared
    ) {
        self.profileService = profileService
        self.storage = storage
        self.state = TodayState(
            totalDrunk: 0,
            dailyGoal: Defaults.dailyGoal,
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
        loadRecords()
    }

    func didToggleRemoveMode(_ isOn: Bool) {
        guard state.isRemoveMode != isOn else { return }
        state.isRemoveMode = isOn
        emit()
    }

    func didTapAmount(_ amount: Int) {
        guard amount > 0 else { return }
        let signed = state.isRemoveMode ? -amount : amount
        let record = WaterRecord(amount: signed)

        records.append(record)
        recomputeTotal()
        emit()

        // Шлём в Firestore fire-and-forget. Если запись упадёт (например, не задеплоены
        // rules) — для текущей сессии оставляем локальный optimistic-стейт, чтобы юзер
        // не видел «вычитание» сразу после тапа. На следующей загрузке reconcile подтянет
        // реальные записи с сервера.
        storage.add(record, completion: nil)
    }
}

// MARK: - TodayViewModel + Private

private extension TodayViewModel {

    func loadRecords() {
        storage.loadTodayRecords { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                guard case .success(let loaded) = result else { return }
                self.records = loaded
                self.recomputeTotal()
                self.emit()
            }
        }
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

    func recomputeTotal() {
        state.totalDrunk = max(0, records.reduce(0) { $0 + $1.amount })
    }

    func emit() {
        onStateChange?(state)
    }
}

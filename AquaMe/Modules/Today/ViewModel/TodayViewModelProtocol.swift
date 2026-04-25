//
//  TodayViewModelProtocol.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import Foundation

// MARK: - TodayState

/// Снимок состояния экрана Today для рендера во вьюхе.
struct TodayState: Equatable {

    var totalDrunk: Int
    var dailyGoal: Int
    var selectedAmount: Int
    var isRemoveMode: Bool
    var presetAmounts: [Int]
    var quickAmounts: [Int]
    var avatarPath: String?
    var unit: UserProfile.MeasureUnit

    var remaining: Int { max(0, dailyGoal - totalDrunk) }

    var progress: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(1, Double(totalDrunk) / Double(dailyGoal))
    }

    var progressPercent: Int { Int((progress * 100).rounded()) }
}

// MARK: - TodayViewModelProtocol

/// Контракт между TodayViewController и его ViewModel.
/// ViewController зависит только от этого протокола — никогда от TodayViewModel напрямую.
protocol TodayViewModelProtocol: AnyObject {

    // MARK: - Данные

    var title: String { get }
    var state: TodayState { get }
    var onStateChange: ((TodayState) -> Void)? { get set }

    // MARK: - Жизненный цикл

    func viewDidLoad()

    // MARK: - Действия пользователя

    func didSelectPreset(amount: Int)
    func didToggleRemoveMode(_ isOn: Bool)
    func didTapLogIntake()
    func didTapQuickAmount(_ amount: Int)
}

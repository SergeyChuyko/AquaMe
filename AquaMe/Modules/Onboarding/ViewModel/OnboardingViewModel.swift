//
//  OnboardingViewModel.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

// MARK: - OnboardingViewModel

/// Бизнес-логика экрана онбординга.
/// Координатор устанавливает колбэк `onFinish` — он вызывается когда пользователь нажал "Начать".
final class OnboardingViewModel: OnboardingViewModelProtocol {

    // MARK: - Public properties

    /// Координатор подписывается на этот колбэк чтобы перейти к главному экрану.
    var onFinish: (() -> Void)?

    // MARK: - OnboardingViewModelProtocol

    func didTapStart() {
        // TODO: Сохранить флаг что онбординг пройден (UserDefaults)
        onFinish?()
    }
}

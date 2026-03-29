//
//  OnboardingViewModelProtocol.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

// MARK: - OnboardingViewModelProtocol

/// Контракт между OnboardingViewController и его ViewModel.
protocol OnboardingViewModelProtocol: AnyObject {

    /// Вызывается когда пользователь нажал кнопку "Начать".
    /// ViewModel уведомляет координатор о завершении онбординга.
    func didTapStart()
}

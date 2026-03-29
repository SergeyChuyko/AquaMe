//
//  TodayViewModel.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

// MARK: - TodayViewModel

/// Бизнес-логика экрана Today.
/// Отвечает за загрузку данных о потреблении воды, расчёт дневного прогресса
/// и обработку действий пользователя, например добавление новой записи.
/// Не импортирует UIKit — не знает о слое отображения.
final class TodayViewModel: TodayViewModelProtocol {

    // MARK: - TodayViewModelProtocol

    var title: String { "Сегодня" }

    func viewDidLoad() {
        // TODO: Загрузить сегодняшние записи о воде из WaterStorage
    }
}

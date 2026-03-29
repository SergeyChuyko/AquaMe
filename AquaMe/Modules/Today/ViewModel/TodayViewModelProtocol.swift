//
//  TodayViewModelProtocol.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

// MARK: - TodayViewModelProtocol

/// Контракт между TodayViewController и его ViewModel.
/// ViewController зависит только от этого протокола — никогда от TodayViewModel напрямую.
/// Это даёт возможность тестировать экран изолированно: подменяем TodayViewModel на mock.
protocol TodayViewModelProtocol: AnyObject {

    // MARK: - Данные

    /// Заголовок экрана, например "Сегодня".
    var title: String { get }

    // MARK: - Жизненный цикл

    /// Вызывается когда view controller загрузил свою вью.
    /// Используется для запуска начальной загрузки данных.
    func viewDidLoad()
}

//
//  Coordinator.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - Coordinator

/// Базовый протокол для всех координаторов.
/// Координатор владеет частью навигационного флоу и отвечает за создание
/// view controller-ов и решение о том, что показать следующим.
protocol Coordinator: AnyObject {

    /// Запускает навигационный флоу координатора.
    /// Вызывай сразу после инициализации координатора.
    func start()
}

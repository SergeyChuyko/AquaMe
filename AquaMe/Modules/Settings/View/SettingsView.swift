//
//  SettingsView.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - SettingsView

/// Вью экрана настроек.
/// Заготовка: оранжевый фон. В будущем: список настроек с карточками.
final class SettingsView: UIView {

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - SettingsView + Setup

private extension SettingsView {

    func setup() {
        setupViews()
        setupConstraints()
    }

    func setupViews() {
        /// Оранжевый фон — временная заготовка для экрана настроек.
        backgroundColor = .systemOrange
    }

    func setupConstraints() {
        // TODO: Добавить констрейнты для элементов настроек
    }
}

//
//  ProgressView.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - ProgressView

/// Вью экрана прогресса.
/// Заготовка: синий фон. В будущем здесь будет календарь-heatmap с данными за месяц.
final class ProgressView: UIView {

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - ProgressView + Setup

private extension ProgressView {

    func setup() {
        setupView()
        setupConstraints()
    }

    func setupView() {
        /// Синий фон — временная заготовка для экрана прогресса.
        backgroundColor = .systemBlue
    }

    func setupConstraints() {
        // TODO: Добавить констрейнты для элементов календаря
    }
}

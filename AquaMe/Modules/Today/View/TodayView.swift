//
//  TodayView.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - TodayViewDelegate

/// Получает события пользовательского взаимодействия из TodayView.
/// Реализует TodayViewController, который передаёт их во ViewModel.
protocol TodayViewDelegate: AnyObject {

    /// Вызывается когда пользователь нажал кнопку Add для записи потребления воды.
    func todayViewDidTapAdd(_ view: TodayView)
}

// MARK: - TodayView

/// Корневая вью экрана Today.
/// Будет содержать: кольцо прогресса, пикер количества воды, быстрые пресеты и кнопку Add.
/// Все магические числа хранятся в Constants — никогда не используй сырые значения напрямую.
final class TodayView: UIView {

    // MARK: - Private enums

    private enum Constants {
        /// Горизонтальный отступ для основных UI-элементов.
        static let horizontalPadding: CGFloat = 24
        /// Стандартный радиус скругления для карточек и кнопок.
        static let cornerRadius: CGFloat = 16
    }

    // MARK: - Public properties

    /// Делегат для обработки пользовательских действий (устанавливается из TodayViewController).
    weak var delegate: TodayViewDelegate?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - TodayView + Setup

private extension TodayView {

    func setup() {
        setupViews()
        setupConstraints()
    }

    /// Настраивает внешний вид и добавляет все сабвью в иерархию.
    func setupViews() {
        backgroundColor = .white
        // TODO: Добавить сабвью (кольцо, пикер, кнопки)
    }

    /// Активирует Auto Layout констрейнты для всех сабвью.
    func setupConstraints() {
        // TODO: Добавить констрейнты когда будут добавлены сабвью
    }
}

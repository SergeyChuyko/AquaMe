//
//  TodayViewController.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - TodayViewController

/// View controller экрана Today.
/// Отвечает только за отображение данных из ViewModel и передачу действий пользователя обратно.
/// Не содержит никакой бизнес-логики.
final class TodayViewController: UIViewController {

    // MARK: - Private properties

    /// Типизирован как TodayView — даёт прямой доступ к его публичному интерфейсу без каста.
    private lazy var todayView: TodayView = {
        let view = TodayView()
        view.delegate = self
        return view
    }()

    /// Хранится как протокол — VC не знает о внутреннем устройстве TodayViewModel.
    private var viewModel: TodayViewModelProtocol

    // MARK: - Initialization

    init(viewModel: TodayViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func loadView() {
        /// Заменяем стандартную UIView на нашу кастомную TodayView.
        view = todayView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        /// Уведомляем ViewModel что вью готова — запускает начальную загрузку данных.
        viewModel.viewDidLoad()
    }
}

// MARK: - TodayViewController + TodayViewDelegate

extension TodayViewController: TodayViewDelegate {

    /// Пользователь нажал Add — просим ViewModel записать выбранное количество воды.
    func todayViewDidTapAdd(_ view: TodayView) {
        // TODO: Передать выбранное количество из пикера в viewModel.didTapAdd(amount:)
    }
}

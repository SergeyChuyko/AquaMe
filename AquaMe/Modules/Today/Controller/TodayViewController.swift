//
//  TodayViewController.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - TodayViewController

final class TodayViewController: UIViewController {

    // MARK: - Private properties

    private lazy var todayView: TodayView = {
        let view = TodayView()
        view.delegate = self

        return view
    }()

    private var viewModel: TodayViewModelProtocol

    // MARK: - Initialization

    init(viewModel: TodayViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindViewModel()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func loadView() {
        view = todayView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        todayView.update(with: viewModel.state)
    }
}

// MARK: - TodayViewController + Setup

private extension TodayViewController {

    func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.todayView.update(with: state)
        }
    }
}

// MARK: - TodayViewController + TodayViewDelegate

extension TodayViewController: TodayViewDelegate {

    func todayView(_ view: TodayView, didSelectPreset amount: Int) {
        viewModel.didSelectPreset(amount: amount)
    }

    func todayView(_ view: TodayView, didTapQuickAmount amount: Int) {
        viewModel.didTapQuickAmount(amount)
    }

    func todayView(_ view: TodayView, didToggleRemoveMode isOn: Bool) {
        viewModel.didToggleRemoveMode(isOn)
    }

    func todayViewDidTapLogIntake(_ view: TodayView) {
        viewModel.didTapLogIntake()
    }
}

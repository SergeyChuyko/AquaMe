//
//  SettingsViewController.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - SettingsViewController

final class SettingsViewController: UIViewController {

    // MARK: - Private properties

    private lazy var settingsView: SettingsView = {
        let view = SettingsView()
        view.delegate = self

        return view
    }()

    private var viewModel: SettingsViewModelProtocol

    // MARK: - Initialization

    init(viewModel: SettingsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindViewModel()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func loadView() {
        view = settingsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settingsView.update(with: viewModel.state)
    }
}

// MARK: - SettingsViewController + Setup

private extension SettingsViewController {

    func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.settingsView.update(with: state)
        }
    }
}

// MARK: - SettingsViewController + SettingsViewDelegate

extension SettingsViewController: SettingsViewDelegate {

    func settingsView(_ view: SettingsView, didChangeDailyGoal value: Int) {
        viewModel.didChangeDailyGoal(value)
    }

    func settingsView(_ view: SettingsView, didChangeWeight value: Double) {
        viewModel.didChangeWeight(value)
    }

    func settingsView(_ view: SettingsView, didChangeAge value: Int) {
        viewModel.didChangeAge(value)
    }

    func settingsView(_ view: SettingsView, didChangeUnit unit: UserProfile.MeasureUnit) {
        viewModel.didChangeUnit(unit)
    }

    func settingsView(_ view: SettingsView, didToggleReminders isOn: Bool) {
        viewModel.didToggleReminders(isOn)
    }

    func settingsView(_ view: SettingsView, didChangeReminderTime value: String) {
        viewModel.didChangeReminderTime(value)
    }
}

//
//  SettingsViewController.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - SettingsViewController

/// View controller экрана настроек (вкладка 3).
/// Управление дневной нормой, уведомлениями и профилем пользователя.
final class SettingsViewController: UIViewController {

    // MARK: - Private properties

    private lazy var settingsView = SettingsView()
    private var viewModel: SettingsViewModelProtocol

    // MARK: - Initialization

    init(viewModel: SettingsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
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
}

//
//  ProgressViewController.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - ProgressViewController

/// View controller экрана прогресса (вкладка 1).
/// Показывает статистику потребления воды за месяц.
final class ProgressViewController: UIViewController {

    // MARK: - Private properties

    private lazy var progressView = ProgressView()
    private var viewModel: ProgressViewModelProtocol

    // MARK: - Initialization

    init(viewModel: ProgressViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func loadView() {
        view = progressView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
    }
}

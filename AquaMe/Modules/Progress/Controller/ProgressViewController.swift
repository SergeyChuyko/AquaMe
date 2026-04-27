//
//  ProgressViewController.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - ProgressViewController

final class ProgressViewController: UIViewController {

    // MARK: - Private properties

    private lazy var progressView: ProgressView = {
        let view = ProgressView()
        view.delegate = self

        return view
    }()

    private var viewModel: ProgressViewModelProtocol

    // MARK: - Initialization

    init(viewModel: ProgressViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindViewModel()
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        progressView.update(with: viewModel.state)
    }
}

// MARK: - ProgressViewController + Setup

private extension ProgressViewController {

    func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.progressView.update(with: state)
        }
    }
}

// MARK: - ProgressViewController + ProgressViewDelegate

extension ProgressViewController: ProgressViewDelegate {

    func progressViewDidTapPreviousMonth(_ view: ProgressView) {
        viewModel.didTapPreviousMonth()
    }

    func progressViewDidTapNextMonth(_ view: ProgressView) {
        viewModel.didTapNextMonth()
    }
}

//
//  ProfileSheetViewController.swift
//  AquaMe
//
//  Created by Friday on 22.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - ProfileSheetViewController

final class ProfileSheetViewController: UIViewController {

    // MARK: - Public properties

    var onEditProfile: (() -> Void)?

    // MARK: - Private properties

    private lazy var profileSheetView: ProfileSheetView = {
        let view = ProfileSheetView()
        view.delegate = self

        return view
    }()

    private var viewModel: ProfileSheetViewModelProtocol

    // MARK: - Initialization

    init(viewModel: ProfileSheetViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupBindings()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func loadView() {
        view = profileSheetView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadProfile()
    }
}

// MARK: - ProfileSheetViewController + ProfileSheetViewDelegate

extension ProfileSheetViewController: ProfileSheetViewDelegate {

    func profileSheetViewDidTapEdit(_ view: ProfileSheetView) {
        let callback = onEditProfile
        dismiss(animated: true) {
            callback?()
        }
    }
}

// MARK: - ProfileSheetViewController + Setup

private extension ProfileSheetViewController {

    func setupBindings() {
        viewModel.onProfileLoaded = { [weak self] profile in
            self?.profileSheetView.configure(with: profile)
        }
    }
}

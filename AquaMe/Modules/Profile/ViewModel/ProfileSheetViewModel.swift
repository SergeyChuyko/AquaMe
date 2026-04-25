//
//  ProfileSheetViewModel.swift
//  AquaMe
//
//  Created by Friday on 22.04.2026.
//  Copyright © 2026. All rights reserved.
//

import Foundation

// MARK: - ProfileSheetViewModel

final class ProfileSheetViewModel: ProfileSheetViewModelProtocol {

    // MARK: - Public properties

    var onProfileLoaded: ((UserProfile) -> Void)?
    var onError: ((String) -> Void)?
    var onEditProfile: (() -> Void)?

    // MARK: - Private properties

    private let profileService: ProfileServiceProtocol

    // MARK: - Initialization

    init(profileService: ProfileServiceProtocol = ProfileService.shared) {
        self.profileService = profileService
    }

    // MARK: - ProfileSheetViewModelProtocol

    func loadProfile() {
        profileService.loadProfile { [weak self] result in
            switch result {
            case .success(let profile):
                self?.onProfileLoaded?(profile)

            case .failure(let error):
                self?.onError?(error.localizedDescription)
            }
        }
    }

    func didTapEditProfile() {
        onEditProfile?()
    }
}

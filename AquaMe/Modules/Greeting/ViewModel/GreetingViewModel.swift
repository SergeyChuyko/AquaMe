//
//  GreetingViewModel.swift
//  AquaMe
//
//  Created by Sergey on 30.03.2026.
//  Copyright © 2026. All rights reserved.
//

import Foundation

// MARK: - GreetingViewModel

final class GreetingViewModel: GreetingViewModelProtocol {

    // MARK: - Public properties

    var onNext: ((String, Int, Double, String?) -> Void)?
    var onLogout: (() -> Void)?
    var avatarPath: String?
    private(set) var initialProfile: UserProfile?

    // MARK: - Initialization

    init(profile: UserProfile? = nil) {
        self.initialProfile = profile
        self.avatarPath = profile?.avatarURL
    }

    // MARK: - GreetingViewModelProtocol

    func didTapNext(name: String, age: Int, weight: Double) {
        onNext?(name, age, weight, avatarPath)
    }

    func didTapLogout() {
        try? AuthService.shared.signOut()
        onLogout?()
    }
}

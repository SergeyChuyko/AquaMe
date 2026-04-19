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

    var onNext: ((String, Int, Double) -> Void)?
    var onLogout: (() -> Void)?

    // MARK: - GreetingViewModelProtocol

    func didTapNext(name: String, age: Int, weight: Double) {
        onNext?(name, age, weight)
    }

    func didTapLogout() {
        try? AuthService.shared.signOut()
        onLogout?()
    }
}

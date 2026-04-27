//
//  GreetingViewModelProtocol.swift
//  AquaMe
//
//  Created by Sergey on 30.03.2026.
//  Copyright © 2026. All rights reserved.
//

import Foundation

// MARK: - GreetingViewModelProtocol

protocol GreetingViewModelProtocol: AnyObject {

    var onNext: ((String, Int, Double, String?) -> Void)? { get set }
    var onLogout: (() -> Void)? { get set }

    var avatarPath: String? { get set }
    var initialProfile: UserProfile? { get }

    func didTapNext(name: String, age: Int, weight: Double)
    func didTapLogout()
}

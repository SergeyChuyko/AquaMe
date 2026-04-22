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

    var onNext: ((String, Int, Double) -> Void)? { get set }
    var onLogout: (() -> Void)? { get set }

    func didTapNext(name: String, age: Int, weight: Double)
    func didTapLogout()
}

//
//  SettingsViewModelProtocol.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

// MARK: - SettingsViewModelProtocol

/// Контракт между SettingsViewController и его ViewModel.
protocol SettingsViewModelProtocol: AnyObject {

    /// Вызывается когда view controller загрузил свою вью.
    func viewDidLoad()
}

//
//  ProgressViewModelProtocol.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

// MARK: - ProgressViewModelProtocol

/// Контракт между ProgressViewController и его ViewModel.
protocol ProgressViewModelProtocol: AnyObject {

    /// Вызывается когда view controller загрузил свою вью.
    func viewDidLoad()
}

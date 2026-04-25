//
//  GoalViewModelProtocol.swift
//  AquaMe
//
//  Created by Sergey on 04.04.2026.
//  Copyright © 2026. All rights reserved.
//

import Foundation

// MARK: - GoalViewModelProtocol

protocol GoalViewModelProtocol: AnyObject {

    var onGetStarted: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var isEditing: Bool { get }
    var initialGoal: UserProfile.Goal? { get }

    func didTapGetStarted(goal: UserProfile.Goal)
}

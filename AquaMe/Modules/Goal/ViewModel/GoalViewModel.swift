//
//  GoalViewModel.swift
//  AquaMe
//
//  Created by Sergey on 04.04.2026.
//  Copyright © 2026. All rights reserved.
//

import FirebaseAuth

// MARK: - GoalViewModel

final class GoalViewModel: GoalViewModelProtocol {

    // MARK: - Public properties

    var onGetStarted: (() -> Void)?
    var onError: ((String) -> Void)?
    let isEditing: Bool
    let initialGoal: UserProfile.Goal?

    // MARK: - Private properties

    private let name: String
    private let age: Int
    private let weight: Double
    private let avatarPath: String?
    private let memberSince: Date
    private let profileService: ProfileServiceProtocol

    // MARK: - Initialization

    init(
        name: String,
        age: Int,
        weight: Double,
        avatarPath: String? = nil,
        isEditing: Bool = false,
        initialGoal: UserProfile.Goal? = nil,
        memberSince: Date = Date(),
        profileService: ProfileServiceProtocol = ProfileService.shared
    ) {
        self.name = name
        self.age = age
        self.weight = weight
        self.avatarPath = avatarPath
        self.isEditing = isEditing
        self.initialGoal = initialGoal
        self.memberSince = memberSince
        self.profileService = profileService
    }

    // MARK: - GoalViewModelProtocol

    func didTapGetStarted(goal: UserProfile.Goal) {
        guard let uid = Auth.auth().currentUser?.uid else {
            onError?("Not authenticated")
            return
        }

        let dailyGoal = UserProfile.calculateDailyGoal(weight: weight, goal: goal)

        let profile = UserProfile(
            uid: uid,
            name: name,
            age: age,
            weight: weight,
            goal: goal,
            avatarURL: avatarPath,
            unit: .ml,
            dailyGoal: dailyGoal,
            memberSince: memberSince
        )

        profileService.saveProfile(profile) { [weak self] result in
            switch result {
            case .success:
                self?.onGetStarted?()

            case .failure(let error):
                self?.onError?(error.localizedDescription)
            }
        }
    }
}

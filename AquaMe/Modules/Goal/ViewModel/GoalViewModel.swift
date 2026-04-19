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

    // MARK: - Private properties

    private let name: String
    private let age: Int
    private let weight: Double
    private let profileService: ProfileServiceProtocol

    // MARK: - Initialization

    init(name: String, age: Int, weight: Double, profileService: ProfileServiceProtocol = ProfileService.shared) {
        self.name = name
        self.age = age
        self.weight = weight
        self.profileService = profileService
    }

    // MARK: - GoalViewModelProtocol

    func didTapGetStarted(goal: UserProfile.Goal) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let dailyGoal = UserProfile.calculateDailyGoal(weight: weight, goal: goal)

        let profile = UserProfile(
            uid: uid,
            name: name,
            age: age,
            weight: weight,
            goal: goal,
            unit: .ml,
            dailyGoal: dailyGoal
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

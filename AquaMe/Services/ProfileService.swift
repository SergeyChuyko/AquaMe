//
//  ProfileService.swift
//  AquaMe
//
//  Created by Friday on 19.04.2026.
//  Copyright © 2026. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore

// MARK: - ProfileServiceProtocol

protocol ProfileServiceProtocol: AnyObject {

    func saveProfile(_ profile: UserProfile, completion: @escaping (Result<Void, Error>) -> Void)
    func loadProfile(completion: @escaping (Result<UserProfile, Error>) -> Void)
    func hasProfile(completion: @escaping (Bool) -> Void)
}

// MARK: - ProfileService

final class ProfileService: ProfileServiceProtocol {

    // MARK: - Public properties

    static let shared = ProfileService()

    // MARK: - Private properties

    private let db = Firestore.firestore()

    // MARK: - Initialization

    private init() {}

    // MARK: - ProfileServiceProtocol

    func saveProfile(_ profile: UserProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        print(
            "[Profile] Saving: uid=\(profile.uid), name=\(profile.name), "
            + "age=\(profile.age), weight=\(profile.weight), "
            + "goal=\(profile.goal.rawValue), dailyGoal=\(profile.dailyGoal)ml"
        )
        do {
            let data = try Firestore.Encoder().encode(profile)
            db.collection("users").document(profile.uid).setData(data) { error in
                if let error {
                    print("[Profile] Save failed: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    print("[Profile] Save success: uid=\(profile.uid)")
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    func loadProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            let error = NSError(
                domain: "ProfileService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Not authenticated"]
            )
            completion(.failure(error))
            return
        }

        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let data = snapshot?.data() else {
                let error = NSError(
                    domain: "ProfileService",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "Profile not found"]
                )
                completion(.failure(error))
                return
            }

            do {
                let profile = try Firestore.Decoder().decode(UserProfile.self, from: data)
                completion(.success(profile))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func hasProfile(completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }

        db.collection("users").document(uid).getDocument { snapshot, _ in
            completion(snapshot?.exists == true)
        }
    }
}

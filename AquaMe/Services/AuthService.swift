//
//  AuthService.swift
//  AquaMe
//
//  Created by Friday on 18.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

// MARK: - AuthServiceProtocol

protocol AuthServiceProtocol: AnyObject {

    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    func register(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    func signInWithGoogle(
        presenting viewController: UIViewController,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func signOut() throws
    var isLoggedIn: Bool { get }
}

// MARK: - AuthService

final class AuthService: AuthServiceProtocol {

    // MARK: - Public properties

    static let shared = AuthService()

    var isLoggedIn: Bool {
        Auth.auth().currentUser != nil
    }

    // MARK: - Initialization

    private init() {}

    // MARK: - Public methods

    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        print("[Auth] Sign in attempt: email=\(email)")
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error {
                print("[Auth] Sign in failed: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("[Auth] Sign in success: uid=\(result?.user.uid ?? "nil"), email=\(result?.user.email ?? "nil")")
                completion(.success(()))
            }
        }
    }

    func register(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        print("[Auth] Register attempt: email=\(email)")
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error {
                print("[Auth] Register failed: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("[Auth] Register success: uid=\(result?.user.uid ?? "nil"), email=\(result?.user.email ?? "nil")")
                completion(.success(()))
            }
        }
    }

    func signInWithGoogle(
        presenting viewController: UIViewController,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            let error = NSError(
                domain: "AuthService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Firebase clientID not found"]
            )
            completion(.failure(error))
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                let error = NSError(
                    domain: "AuthService",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "Google Sign-In failed"]
                )
                completion(.failure(error))
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            Auth.auth().signIn(with: credential) { result, error in
                if let error {
                    print("[Auth] Google sign in failed: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    let uid = result?.user.uid ?? "nil"
                    let email = result?.user.email ?? "nil"
                    print("[Auth] Google sign in success: uid=\(uid), email=\(email)")
                    completion(.success(()))
                }
            }
        }
    }

    func signOut() throws {
        print("[Auth] Sign out: uid=\(Auth.auth().currentUser?.uid ?? "nil")")
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
    }
}

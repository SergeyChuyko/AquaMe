//
//  SceneDelegate.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Public properties

    var window: UIWindow?

    /// Сильная ссылка на корневой координатор.
    /// Необходима чтобы координатор жил всё время жизни сцены — UIKit его не удерживает.
    private var appCoordinator: AppCoordinator?

    // MARK: - UIWindowSceneDelegate

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        /// Создаём корневой координатор и передаём ему window.
        /// AppCoordinator сам установит rootViewController и вызовет makeKeyAndVisible.
        let coordinator = AppCoordinator(window: window)
        appCoordinator = coordinator
        coordinator.start()
    }
}

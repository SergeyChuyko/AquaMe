//
//  ProfileSheetViewModelProtocol.swift
//  AquaMe
//
//  Created by Friday on 22.04.2026.
//  Copyright © 2026. All rights reserved.
//

import Foundation

// MARK: - ProfileSheetViewModelProtocol

protocol ProfileSheetViewModelProtocol: AnyObject {

    var onProfileLoaded: ((UserProfile) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onEditProfile: (() -> Void)? { get set }

    func loadProfile()
    func didTapEditProfile()
}

//
//  WaterStorage.swift
//  AquaMe
//
//  Created by Friday on 25.04.2026.
//  Copyright © 2026. All rights reserved.
//

import FirebaseAuth
import Foundation

// MARK: - WaterStorageProtocol

protocol WaterStorageProtocol: AnyObject {

    func todayRecords() -> [WaterRecord]
    func todayTotal() -> Int
    func add(_ record: WaterRecord)
}

// MARK: - WaterStorage

/// Локальное хранилище записей о воде на основе UserDefaults.
/// Записи скоупятся по uid пользователя — это позволяет хранить данные нескольких аккаунтов на одном девайсе.
/// Firestore-синк можно добавить позже без изменения публичного контракта.
final class WaterStorage: WaterStorageProtocol {

    // MARK: - Public properties

    static let shared = WaterStorage()

    // MARK: - Private enums

    private enum Keys {

        static let prefix = "water.records."
    }

    // MARK: - Private properties

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Initialization

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - WaterStorageProtocol

    func todayRecords() -> [WaterRecord] {
        let calendar = Calendar.current
        return loadAll().filter { calendar.isDateInToday($0.date) }
    }

    func todayTotal() -> Int {
        max(0, todayRecords().reduce(0) { $0 + $1.amount })
    }

    func add(_ record: WaterRecord) {
        var all = loadAll()
        all.append(record)
        save(all)
    }
}

// MARK: - WaterStorage + Private

private extension WaterStorage {

    func storageKey() -> String {
        let uid = Auth.auth().currentUser?.uid ?? "anonymous"
        return Keys.prefix + uid
    }

    func loadAll() -> [WaterRecord] {
        guard let data = defaults.data(forKey: storageKey()) else { return [] }
        return (try? decoder.decode([WaterRecord].self, from: data)) ?? []
    }

    func save(_ records: [WaterRecord]) {
        guard let data = try? encoder.encode(records) else { return }
        defaults.set(data, forKey: storageKey())
    }
}

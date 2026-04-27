//
//  WaterStorage.swift
//  AquaMe
//
//  Created by Friday on 25.04.2026.
//  Copyright © 2026. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

// MARK: - WaterStorageProtocol

protocol WaterStorageProtocol: AnyObject {

    /// Загружает записи о воде за сегодня для текущего пользователя.
    func loadTodayRecords(completion: @escaping (Result<[WaterRecord], Error>) -> Void)

    /// Загружает записи о воде в произвольном промежутке (start включён, end исключён).
    func loadRecords(
        from start: Date,
        to end: Date,
        completion: @escaping (Result<[WaterRecord], Error>) -> Void
    )

    /// Сохраняет одну запись. Сетевая ошибка прокидывается в completion.
    /// Если completion = nil, ошибка молча логируется — fire-and-forget из ViewModel.
    func add(_ record: WaterRecord, completion: ((Result<Void, Error>) -> Void)?)
}

// MARK: - WaterStorage

/// Firestore-бэкенд для записей о потреблении воды.
/// Каждый юзер пишет в свою подколлекцию `users/{uid}/water/{recordId}`.
/// SDK Firestore сам кеширует записи оффлайн и реплеит их на сервер при появлении сети,
/// поэтому отдельный локальный кеш в UserDefaults не нужен.
final class WaterStorage: WaterStorageProtocol {

    // MARK: - Public properties

    static let shared = WaterStorage()

    // MARK: - Private enums

    private enum Path {

        static let users = "users"
        static let water = "water"
    }

    private enum StorageError: LocalizedError {

        case notAuthenticated

        var errorDescription: String? {
            switch self {
            case .notAuthenticated: return "User is not authenticated"
            }
        }
    }

    // MARK: - Private properties

    private let db: Firestore
    private let auth: Auth

    // MARK: - Initialization

    private init(db: Firestore = .firestore(), auth: Auth = .auth()) {
        self.db = db
        self.auth = auth
    }

    // MARK: - WaterStorageProtocol

    func loadTodayRecords(completion: @escaping (Result<[WaterRecord], Error>) -> Void) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            completion(.success([]))
            return
        }

        loadRecords(from: startOfDay, to: endOfDay, completion: completion)
    }

    func loadRecords(
        from start: Date,
        to end: Date,
        completion: @escaping (Result<[WaterRecord], Error>) -> Void
    ) {
        guard let collection = waterCollection() else {
            completion(.failure(StorageError.notAuthenticated))
            return
        }

        collection
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: start))
            .whereField("date", isLessThan: Timestamp(date: end))
            .getDocuments { snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }

                let records = snapshot?.documents.compactMap { doc -> WaterRecord? in
                    try? doc.data(as: WaterRecord.self)
                } ?? []
                completion(.success(records))
            }
    }

    func add(_ record: WaterRecord, completion: ((Result<Void, Error>) -> Void)?) {
        guard let collection = waterCollection() else {
            completion?(.failure(StorageError.notAuthenticated))
            return
        }

        do {
            try collection.document(record.id.uuidString).setData(from: record) { error in
                if let error {
                    print("[Water] Save failed: \(error.localizedDescription)")
                    completion?(.failure(error))
                } else {
                    completion?(.success(()))
                }
            }
        } catch {
            print("[Water] Encode failed: \(error.localizedDescription)")
            completion?(.failure(error))
        }
    }
}

// MARK: - WaterStorage + Private

private extension WaterStorage {

    func waterCollection() -> CollectionReference? {
        guard let uid = auth.currentUser?.uid else { return nil }
        return db.collection(Path.users).document(uid).collection(Path.water)
    }
}

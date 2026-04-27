//
//  RemindersService.swift
//  AquaMe
//
//  Created by Friday on 27.04.2026.
//  Copyright © 2026. All rights reserved.
//

import Foundation
import UserNotifications

// MARK: - RemindersServiceProtocol

protocol RemindersServiceProtocol: AnyObject {

    /// Запрашивает разрешение на нотификации. Колбэк на main thread.
    func requestAuthorization(completion: @escaping (Bool) -> Void)

    /// Отменяет старые уведомления и, если `enabled`, пересоздаёт расписание
    /// от `startTime` ("HH:mm") до `endHour` с шагом `intervalHours` часа.
    func reschedule(enabled: Bool, startTime: String, endHour: Int, intervalHours: Int)
}

// MARK: - RemindersService

final class RemindersService: RemindersServiceProtocol {

    // MARK: - Public properties

    static let shared = RemindersService()

    // MARK: - Private enums

    private enum Constants {

        static let identifierPrefix = "aquame.hydration."
        static let timeFormat = "HH:mm"
    }

    // MARK: - Private properties

    private let center: UNUserNotificationCenter
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.timeFormat
        formatter.locale = Locale(identifier: "en_US_POSIX")

        return formatter
    }()

    // MARK: - Initialization

    private init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    // MARK: - RemindersServiceProtocol

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error {
                print("[Reminders] Authorization failed: \(error.localizedDescription)")
            }

            DispatchQueue.main.async { completion(granted) }
        }
    }

    func reschedule(enabled: Bool, startTime: String, endHour: Int, intervalHours: Int) {
        center.getPendingNotificationRequests { [weak self] requests in
            guard let self else { return }

            let ids = requests
                .map(\.identifier)
                .filter { $0.hasPrefix(Constants.identifierPrefix) }
            self.center.removePendingNotificationRequests(withIdentifiers: ids)

            guard enabled else {
                print("[Reminders] Disabled, cancelled \(ids.count) pending")
                return
            }

            self.scheduleSlots(startTime: startTime, endHour: endHour, intervalHours: intervalHours)
        }
    }
}

// MARK: - RemindersService + Private

private extension RemindersService {

    /// Создаёт по одному `UNCalendarNotificationTrigger` на каждое окно времени
    /// от startTime до endHour с шагом intervalHours. Каждое окно репитится ежедневно.
    /// Тексты разводятся по слотам через `HydrationReminderMessage.shuffled(count:)`,
    /// чтобы в один день одинаковые сообщения не повторялись.
    func scheduleSlots(startTime: String, endHour: Int, intervalHours: Int) {
        guard let parsed = timeFormatter.date(from: startTime) else {
            print("[Reminders] Bad startTime: \(startTime)")
            return
        }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: parsed)
        guard let startHour = components.hour else { return }

        let minute = components.minute ?? 0
        let slots = stride(from: startHour, through: endHour, by: intervalHours).map { $0 }
        let messages = HydrationReminderMessage.shuffled(count: slots.count)

        for (index, hour) in slots.enumerated() {
            schedule(hour: hour, minute: minute, index: index, message: messages[index])
        }

        print("[Reminders] Scheduled \(slots.count) slots starting at \(startTime)")
    }

    func schedule(hour: Int, minute: Int, index: Int, message: HydrationReminderMessage) {
        let content = UNMutableNotificationContent()
        content.title = message.title
        content.body = message.body
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let identifier = "\(Constants.identifierPrefix)\(index)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request) { error in
            if let error {
                print("[Reminders] Failed to schedule \(identifier): \(error.localizedDescription)")
            }
        }
    }
}

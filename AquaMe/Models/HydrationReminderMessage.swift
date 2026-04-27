//
//  HydrationReminderMessage.swift
//  AquaMe
//
//  Created by Friday on 27.04.2026.
//  Copyright © 2026. All rights reserved.
//

import Foundation

// MARK: - HydrationReminderMessage

/// Один вариант текста уведомления о воде.
/// Хранится статически в `library` — при планировании каждое окно времени
/// получает случайный экземпляр, чтобы юзер не видел один и тот же текст.
struct HydrationReminderMessage: Equatable {

    let title: String
    let body: String
}

// MARK: - HydrationReminderMessage + Library

extension HydrationReminderMessage {

    static let library: [HydrationReminderMessage] = [
        HydrationReminderMessage(title: "Время попить воды 💧", body: "Сделай глоток — тело скажет спасибо"),
        HydrationReminderMessage(title: "Пауза на воду 💦", body: "Минута, стакан, и обратно к делам"),
        HydrationReminderMessage(title: "Гидратация ⏰", body: "Сейчас самое время для воды"),
        HydrationReminderMessage(title: "Капелька зовёт 💧", body: "Не забывай про сегодняшнюю норму"),
        HydrationReminderMessage(title: "Привет от тела 👋", body: "Я тут немного хочу пить"),
        HydrationReminderMessage(title: "Стакан воды? 🥛", body: "Идеально подходит к этому моменту"),
        HydrationReminderMessage(title: "Освежись 💦", body: "Один глоток и настроение лучше"),
        HydrationReminderMessage(title: "Пьём как чемпионы 🏆", body: "Норма сама себя не выпьет"),
        HydrationReminderMessage(title: "Внутренний океан 🌊", body: "Подкинь воды, ему скучно"),
        HydrationReminderMessage(title: "До цели чуть-чуть ✨", body: "Ещё стакан и ты молодец"),
        HydrationReminderMessage(title: "Тук-тук 🚪", body: "Это вода, можно к тебе?"),
        HydrationReminderMessage(title: "Зарядись водой ⚡", body: "Пара глотков и снова в строй"),
        HydrationReminderMessage(title: "Минутка для воды ☕→💧", body: "Чай подождёт, вода не очень"),
        HydrationReminderMessage(title: "Сухость не ок 🏜️", body: "Спасай себя стаканом воды"),
        HydrationReminderMessage(title: "Вода — твой бро 🤝", body: "Угости его собой"),
    ]

    /// Запасной дефолт на случай пустой библиотеки.
    static let fallback = HydrationReminderMessage(
        title: "Пора попить воды 💧",
        body: "Глоток воды — и снова к делам"
    )

    /// Случайное сообщение из библиотеки. Используется как точечный fallback —
    /// для планирования набора слотов сразу бери `shuffled(count:)`, чтобы
    /// в один день одно и то же сообщение не пришло несколько раз.
    static func random() -> HydrationReminderMessage {
        library.randomElement() ?? fallback
    }

    /// Возвращает `count` сообщений без повторов (если они есть в библиотеке).
    /// Если слотов больше, чем сообщений в библиотеке, добавляет ещё одну
    /// перетасованную копию — повтор всё равно случится, но как можно позже.
    static func shuffled(count: Int) -> [HydrationReminderMessage] {
        guard count > 0 else { return [] }
        guard !library.isEmpty else { return Array(repeating: fallback, count: count) }

        var result = library.shuffled()

        while result.count < count {
            result.append(contentsOf: library.shuffled())
        }

        return Array(result.prefix(count))
    }
}

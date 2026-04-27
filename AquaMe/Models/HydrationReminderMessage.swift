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

    /// Случайное сообщение из библиотеки. Если по какой-то причине библиотека пуста,
    /// возвращает запасной дефолт, чтобы код выше не падал.
    static func random() -> HydrationReminderMessage {
        library.randomElement() ?? HydrationReminderMessage(
            title: "Пора попить воды 💧",
            body: "Глоток воды — и снова к делам"
        )
    }
}

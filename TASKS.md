# TASKS.md — AquaMe v1.0

## Что реализовано

### Инфраструктура
- [x] SwiftFormat + SwiftLint конфигурация (PR #1)
- [x] Структура проекта: MVVM + Coordinator, 4 модуля, кастомный таб-бар (PR #2)
- [x] AppCoordinator — роутинг Onboarding → Main
- [x] MainCoordinator — создание 3 табов (Today / Progress / Settings)

### UI-компоненты (Common/Components/)
- [x] CUITextField — поле ввода с иконкой, суффиксом, hint, secure-режимом (PR #3, #11)
- [x] CUIButton — кнопка с анимацией нажатия, disabled-состоянием (PR #4)
- [x] CUISelectCard — карточка выбора с иконкой, selected/deselected (PR #5)
- [x] CUIText — заголовок + подзаголовок (PR #6)
- [x] CUINavigationBar — кастомный навбар (заголовок, кнопки назад/действие, дивайдер) (PR #7)
- [x] CUISocialButton — кнопки Apple/Google авторизации (в PR #9)
- [x] MainTabBarView — 3 иконки (график, капля, шестерёнка), выделение текущего таба

### Экраны
- [x] Onboarding — фиолетовый экран с кнопкой «Начать» (базовый, на develop/v1.0)
- [x] MainViewController — контейнер для 3 табов с кастомным таб-баром

### В открытых PR (не смёржены)
- [x] Profile Setup (Greeting) — фото, имя, возраст, вес, кнопка Next (PR #12)
- [x] Goal Setup — 3 карточки целей, кнопка Get Started (PR #12)
- [x] Auth screen — email/пароль, Sign In, Apple/Google, ссылка на регистрацию (PR #9)
- [x] Register screen — email/пароль/подтверждение, Create Account, Apple/Google (PR #10)

---

## Текущий статус

### Открытые PR
| PR | Ветка | Статус | Конфликты |
|----|-------|--------|-----------|
| #12 | feature/009/goal-screens | MERGEABLE | нет |
| #9 | feature/010/auth-screens | CONFLICTING | есть |
| #10 | feature/011/register-screen | CONFLICTING | есть |

### Экраны: что работает, что нет
| Экран | UI | Логика | Данные |
|-------|----|--------|--------|
| Onboarding | ✅ базовый | ✅ callback → Main | ❌ флаг не сохраняется |
| Profile Setup | ✅ готов (PR #12) | ⚠️ фото не работает | ❌ нет модели User |
| Goal Setup | ✅ готов (PR #12) | ⚠️ выбор не сохраняется | ❌ нет модели Goal |
| Auth | ✅ готов (PR #9) | ❌ заглушки | ❌ нет авторизации |
| Register | ✅ готов (PR #10) | ❌ заглушки | ❌ нет регистрации |
| Today | ✅ кольцо/пресеты/чипы/Log/Remove toggle | ✅ add/remove + дневной прогресс | ✅ WaterStorage (UserDefaults) |
| Progress | ❌ пустой синий экран | ❌ пусто | ❌ нет данных |
| Settings | ❌ пустой оранжевый экран | ❌ пусто | ❌ нет UserDefaults |

---

## Что осталось до v1.0

### Приоритет 1 — Ядро приложения
- [x] Модель данных: `WaterRecord` (id, amount, date), `UserProfile` (name, age, weight, goal)
- [x] Сервис хранения: `WaterStorage` (UserDefaults, скоуп по uid)
- [x] Логика расчёта нормы воды по весу и активности (UserProfile.calculateDailyGoal)
- [ ] Сохранение флага завершения онбординга в UserDefaults

### Приоритет 2 — Today (главный экран)
- [x] UI: кольцо прогресса (выпито / норма)
- [x] UI: пресеты 250/500 мл
- [x] UI: чипы быстрого добавления 100/200/300/400 мл
- [x] UI: кнопка Log Intake
- [x] UI: переключатель Remove mode (кнопки красные, действие инвертируется)
- [x] Логика: добавление/удаление записи через WaterStorage
- [x] Логика: обновление кольца прогресса при изменении
- [ ] Перенести WaterStorage на Firestore (сейчас локально UserDefaults)
- [ ] Карточка статистики «Almost there!» (сравнение с прошлой неделей)

### Приоритет 3 — Progress (статистика)
- [ ] UI: календарь-хитмап за месяц
- [ ] Логика: агрегация данных по дням из WaterStorage
- [ ] UI: итоговая статистика (среднее, лучший день, streak)

### Приоритет 4 — Settings (настройки)
- [ ] UI: список настроек (имя, вес, дневная норма, единицы измерения)
- [ ] UI: настройки уведомлений (интервал напоминаний)
- [ ] Логика: сохранение/загрузка настроек из UserDefaults
- [ ] Пересчёт нормы при изменении веса

### Приоритет 5 — Уведомления
- [ ] Запрос разрешения на нотификации
- [ ] Планирование локальных напоминаний по интервалу
- [ ] Управление расписанием из Settings

### Приоритет 6 — Мёрдж открытых PR и навигация
- [ ] Смёрджить PR #12 (Goal flow: Profile Setup + Goal Setup)
- [ ] Обновить и смёрджить PR #9 (Auth screen)
- [ ] Обновить и смёрджить PR #10 (Register screen)
- [ ] Связать навигацию: Onboarding → Greeting → Goal → Auth / Main
- [ ] Подключить Profile Setup к сохранению UserProfile
- [ ] Подключить Goal Setup к сохранению выбранной цели

### Приоритет 7 — Полировка
- [ ] Заменить placeholder Bundle ID `com.example.AquaMe` на реальный
- [ ] Добавить AppIcon
- [ ] Добавить LaunchScreen
- [ ] Обработка ошибок и валидация ввода
- [ ] Тесты (unit-тесты для ViewModel, storage)

---

## Известные баги и проблемы

1. **Онбординг показывается каждый раз** — флаг завершения не сохраняется в UserDefaults (`OnboardingViewModel` TODO)
2. **Profile Setup: камера не работает** — `greetingViewDidTapCamera()` пустой (TODO в `GreetingViewController`)
3. **Today/Progress/Settings — пустые экраны** — только цветной фон, нет UI-элементов
4. **PR #9 и #10 в конфликте с develop/v1.0** — нужно обновить ветки от develop перед мёржем
5. **Auth/Register — все кнопки заглушки** — Sign In, Create Account, Apple, Google выводят print в консоль, реальной логики нет
6. **Нет модели данных** — WaterRecord, UserProfile, DailyGoal не определены
7. **Нет персистенции** — приложение не сохраняет ничего между запусками

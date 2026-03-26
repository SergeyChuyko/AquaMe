# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## О проекте

**AquaMe** — iOS приложение для расчёта нормы воды по весу и активности с напоминаниями.
Разработка: Сергей Чуйко (MacBook) + Friday Mac Mini (Mac mini, аккаунт sergeymini).

## Архитектура

- **MVVM + Coordinator** — обязательно для всех экранов
- **Программный UI** — только UIKit + NSLayoutConstraint, никаких сторибордов
- **SceneDelegate** устанавливает корневой UINavigationController через AppCoordinator

## Структура веток

```
main                    ← стабильный релиз
└── develop/v1.0        ← текущая версия в разработке
    ├── feature/xxx     ← отдельные фичи
develop/test            ← тестовая ветка (временная)
```

## Code Style

Используются `.swiftformat` и `.swiftlint.yml` в корне проекта.

### SwiftFormat
- Только 2 правила активны: `wrapArguments`, `wrapLoopBodies`
- Максимальная длина строки: **120 символов**
- Отступ: **4 пробела**

### SwiftLint — ключевые правила
- `force_unwrapping` → **error** (никаких `!`)
- `implicitly_unwrapped_optional` → **error**
- Максимум строк в файле: 800
- Максимум строк в функции: 230
- Максимум параметров функции: 6
- Цикломатическая сложность: не более 15

### Запреты
- Нельзя использовать `Custom` в именах типов
- Нельзя называть типы и методы начиная с `init` (использовать `setup`/`configure`)
- Все протоколы должны наследоваться от `AnyObject`

### Именование
- Минимальная длина идентификатора: 1 символ
- Допускается `_` в именах

## Bundle ID

`com.example.AquaMe` → заменить на реальный при публикации

## Симулятор

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -project AquaMe.xcodeproj -scheme AquaMe \
  -destination 'platform=iOS Simulator,id=DA51EF54-6945-485D-97E4-DE2124D7B1E4' \
  -configuration Debug build
```

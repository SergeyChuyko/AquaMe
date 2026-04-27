# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Рабочий процесс

- **При каждом старте сессии** — первым делом прочитай `TASKS.md` в корне проекта
- **После выполнения задачи** — обнови `TASKS.md`: отметь что сделано (`[x]`), добавь новые задачи/баги если появились
- `TASKS.md` — основная память между сессиями: статус проекта, открытые задачи, известные баги

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

## Паттерны кода

### Заголовок файла

```swift
//
//  FileName.swift
//  AquaMe
//
//  Created by Name on DD.MM.YYYY.
//  Copyright © YYYY. All rights reserved.
//
```

### ViewController

```swift
// MARK: - SomeViewControllerDelegate
protocol SomeViewControllerDelegate: AnyObject {
    func someViewControllerDidFinish(_ controller: SomeViewController)
}

// MARK: - SomeViewController
final class SomeViewController: UIViewController {

    // MARK: - Private properties
    private lazy var someView: SomeView = {
        let view = SomeView()
        view.delegate = self
        return view
    }()

    private var viewModel: SomeViewModelProtocol  // ← всегда протокол, не конкретный тип

    // MARK: - Initialization
    init(viewModel: SomeViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - SomeViewController + SomeViewDelegate
extension SomeViewController: SomeViewDelegate {
    func someViewDidTapButton(_ view: SomeView) { ... }
}

// MARK: - SomeViewController + Setup
private extension SomeViewController {
    func setup() {
        setupView()
        setupConstraints()
    }

    func setupView() { ... }
    func setupConstraints() { ... }
}
```

### Custom UIView

```swift
// MARK: - SomeViewDelegate
protocol SomeViewDelegate: AnyObject {
    func someViewDidTapButton(_ view: SomeView)
}

// MARK: - SomeView
final class SomeView: UIView {

    // MARK: - Private enums
    private enum Constants {
        static let buttonHeight: CGFloat = 52
        static let cornerRadius: CGFloat = 12
        static let spacing: CGFloat = 16
    }

    private enum Images {
        static let icon = UIImage(named: "icon_name")
    }

    // MARK: - Public properties
    weak var delegate: SomeViewDelegate?

    // MARK: - Private properties
    private lazy var button: UIButton = {
        let action = UIAction { [weak self] _ in
            guard let self else { return }
            delegate?.someViewDidTapButton(self)
        }
        let button = UIButton(primaryAction: action)
        return button
    }()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        // dynamic layout if needed
    }
}

// MARK: - SomeView + Public methods
extension SomeView {
    func update(with model: SomeModel) { ... }
}

// MARK: - SomeView + Setup
private extension SomeView {
    func setup() {
        setupView()
        setupConstraints()
    }

    func setupView() {
        addSubview(button)
    }

    func setupConstraints() {
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }
}
```

### ViewModel

```swift
// MARK: - SomeViewModelProtocol
protocol SomeViewModelProtocol: AnyObject {
    var title: String { get }
    func didTapButton()
}

// MARK: - SomeViewModel
final class SomeViewModel: SomeViewModelProtocol {
    var title: String { "Some Title" }

    func didTapButton() { ... }
}
```

### Ключевые правила

- `final class` — везде где нет наследования
- ViewModel всегда через протокол (`var viewModel: SomeViewModelProtocol`)
- `UIAction` для кнопок (не `#selector`)
- `private lazy var` для всех UI-элементов
- `@available(*, unavailable)` на `init?(coder:)`
- Константы — в `private enum Constants`, картинки — в `private enum Images`
- Extensions сгруппированы по ответственности: Setup, Actions, Public methods, Delegates

## Bundle ID

`com.example.AquaMe` → заменить на реальный при публикации

## Симулятор

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -project AquaMe.xcodeproj -scheme AquaMe \
  -destination 'platform=iOS Simulator,id=DA51EF54-6945-485D-97E4-DE2124D7B1E4' \
  -configuration Debug build
```

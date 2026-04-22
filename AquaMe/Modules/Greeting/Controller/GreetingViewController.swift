//
//  GreetingViewController.swift
//  AquaMe
//
//  Created by Sergey on 30.03.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit
import PhotosUI

// MARK: - GreetingViewController

/// Контроллер экрана приветствия — показывается при первом запуске приложения.
/// Пользователь заполняет данные профиля: фото, имя, возраст, вес.
/// Не содержит логики — только отображает GreetingView и передаёт события во ViewModel.
final class GreetingViewController: UIViewController {

    // MARK: - Private properties

    /// GreetingView полностью заменяет стандартную UIView контроллера.
    private lazy var greetingView: GreetingView = {
        let view = GreetingView()
        view.delegate = self

        return view
    }()

    /// ViewModel хранится через протокол — контроллер не знает о конкретной реализации.
    private var viewModel: GreetingViewModelProtocol

    // MARK: - Initialization

    init(viewModel: GreetingViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func loadView() {
        /// Устанавливаем GreetingView как корневую вью контроллера — она занимает весь экран.
        view = greetingView
    }
}

// MARK: - GreetingViewController + GreetingViewDelegate

extension GreetingViewController: GreetingViewDelegate {

    func greetingViewDidTapNext(_ view: GreetingView) {
        let name = view.name ?? ""
        let age = Int(view.age ?? "") ?? 0
        let weight = Double(view.weight ?? "") ?? 0
        viewModel.didTapNext(name: name, age: age, weight: weight)
    }

    func greetingViewDidTapCamera(_ view: GreetingView) {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    func greetingViewDidTapLogout(_ view: GreetingView) {
        viewModel.didTapLogout()
    }
}

// MARK: - GreetingViewController + PHPickerViewControllerDelegate

extension GreetingViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            guard let image = image as? UIImage else { return }
            DispatchQueue.main.async {
                self?.greetingView.setProfileImage(image)
            }
        }
    }
}

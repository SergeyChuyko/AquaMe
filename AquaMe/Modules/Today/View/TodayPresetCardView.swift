//
//  TodayPresetCardView.swift
//  AquaMe
//
//  Created by Friday on 25.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - TodayPresetCardView

/// Карточка пресета объёма (250 мл / 500 мл).
/// По умолчанию серая. На тапе кратко вспыхивает акцентным цветом и плавно
/// возвращается к серому через `flashFadeDuration`.
final class TodayPresetCardView: UIView {

    // MARK: - Private enums

    private enum Constants {

        static let cornerRadius: CGFloat = 16
        static let borderWidth: CGFloat = 1.5
        static let height: CGFloat = 96
        static let iconSize: CGFloat = 28
        static let iconBackgroundSize: CGFloat = 44
        static let titleFontSize: CGFloat = 17
        static let stackSpacing: CGFloat = 8
        static let flashHoldDuration: TimeInterval = 0.85
        static let flashFadeDuration: TimeInterval = 0.6
        static let pressedScale: CGFloat = 0.94
        static let pressDuration: TimeInterval = 0.12
    }

    private enum Images {

        static let glass = UIImage(systemName: "mug.fill")

        /// Бутылка появилась в SF Symbols только в iOS 17.4 — для более ранних версий
        /// откатываемся на бокал, чтобы карточка не оставалась без иконки.
        static let bottle: UIImage? = UIImage(systemName: "waterbottle.fill")
            ?? UIImage(systemName: "wineglass.fill")
    }

    // MARK: - Public properties

    let amount: Int
    var onTap: (() -> Void)?

    // MARK: - Private properties

    private var isRemoveMode: Bool = false
    private var fadeWorkItem: DispatchWorkItem?

    private lazy var iconBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.iconBackgroundSize / 2

        return view
    }()

    private lazy var iconImageView: UIImageView = {
        let image = amount >= 500 ? Images.bottle : Images.glass
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.titleFontSize, weight: .semibold)
        label.textAlignment = .center

        return label
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconBackground, titleLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = Constants.stackSpacing

        return stack
    }()

    // MARK: - Initialization

    init(amount: Int) {
        self.amount = amount
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Press feedback

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animatePress(down: true)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animatePress(down: false)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animatePress(down: false)
    }
}

// MARK: - TodayPresetCardView + Public

extension TodayPresetCardView {

    func update(isRemoveMode: Bool, title: String) {
        self.isRemoveMode = isRemoveMode
        titleLabel.text = title
        applyInactiveStyle()
    }

    func flashSelection() {
        applyActiveStyle()
        fadeWorkItem?.cancel()

        let item = DispatchWorkItem { [weak self] in
            guard let self else { return }

            UIView.animate(withDuration: Constants.flashFadeDuration) {
                self.applyInactiveStyle()
            }
        }
        fadeWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.flashHoldDuration, execute: item)
    }
}

// MARK: - TodayPresetCardView + Setup

private extension TodayPresetCardView {

    func setup() {
        layer.cornerRadius = Constants.cornerRadius
        layer.borderWidth = Constants.borderWidth
        translatesAutoresizingMaskIntoConstraints = false

        iconBackground.addSubview(iconImageView)
        addSubview(contentStack)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Constants.height),
            iconBackground.widthAnchor.constraint(equalToConstant: Constants.iconBackgroundSize),
            iconBackground.heightAnchor.constraint(equalToConstant: Constants.iconBackgroundSize),
            iconImageView.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Constants.iconSize),
            contentStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
        applyInactiveStyle()
    }

    func applyInactiveStyle() {
        backgroundColor = .secondarySystemBackground
        layer.borderColor = UIColor.separator.withAlphaComponent(0.4).cgColor
        iconBackground.backgroundColor = .systemBackground
        iconImageView.tintColor = .secondaryLabel
        titleLabel.textColor = .label
    }

    func applyActiveStyle() {
        let accent: UIColor = isRemoveMode ? .systemRed : .systemIndigo
        backgroundColor = accent.withAlphaComponent(0.10)
        layer.borderColor = accent.cgColor
        iconBackground.backgroundColor = accent
        iconImageView.tintColor = .white
        titleLabel.textColor = accent
    }

    @objc
    func handleTap() {
        flashSelection()
        onTap?()
    }

    func animatePress(down: Bool) {
        let scale: CGFloat = down ? Constants.pressedScale : 1
        UIView.animate(
            withDuration: Constants.pressDuration,
            delay: 0,
            options: [.allowUserInteraction, .curveEaseOut]
        ) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
}

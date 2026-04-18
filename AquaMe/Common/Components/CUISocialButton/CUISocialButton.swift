//
//  CUISocialButton.swift
//  AquaMe
//
//  Created by Sergey on 05.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - CUISocialButton

final class CUISocialButton: UIView {

    // MARK: - Provider

    enum Provider {

        case apple
        case google
    }

    // MARK: - Private enums

    private enum Constants {

        static let cornerRadius: CGFloat = 16
        static let borderWidth: CGFloat = 1
        static let iconSize: CGFloat = 20
        static let titleFontSize: CGFloat = 17
        static let stackSpacing: CGFloat = 8
        static let pressedScale: CGFloat = 0.95
        static let pressAnimationDuration: TimeInterval = 0.1
        static let releaseAnimationDuration: TimeInterval = 0.2
    }

    // MARK: - Public properties

    var onTap: (() -> Void)?

    var isEnabled: Bool = true {
        didSet {
            updateEnabledAppearance()
        }
    }

    // MARK: - Private properties

    private let provider: Provider

    private lazy var iconView: UIView = makeIconView()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.titleFontSize)
        label.textColor = .label
        label.isUserInteractionEnabled = false

        return label
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = Constants.stackSpacing
        stack.isUserInteractionEnabled = false

        return stack
    }()

    // MARK: - Initialization

    init(provider: Provider) {
        self.provider = provider
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Touch handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard isEnabled else { return }
        animatePress()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard isEnabled else { return }
        animateRelease()
        onTap?()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard isEnabled else { return }
        animateRelease()
    }
}

// MARK: - CUISocialButton + Actions

private extension CUISocialButton {

    func animatePress() {
        UIView.animate(withDuration: Constants.pressAnimationDuration) {
            self.transform = CGAffineTransform(scaleX: Constants.pressedScale, y: Constants.pressedScale)
        }
    }

    func animateRelease() {
        UIView.animate(
            withDuration: Constants.releaseAnimationDuration,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.5
        ) {
            self.transform = .identity
        }
    }
}

// MARK: - CUISocialButton + Setup

private extension CUISocialButton {

    func setup() {
        setupViews()
        setupConstraints()
        titleLabel.text = titleText()
    }

    func setupViews() {
        isUserInteractionEnabled = true
        layer.cornerRadius = Constants.cornerRadius
        layer.borderWidth = Constants.borderWidth
        layer.borderColor = UIColor.systemGray4.cgColor
        addSubview(contentStack)
        updateEnabledAppearance()
    }

    func updateEnabledAppearance() {
        alpha = isEnabled ? 1.0 : 0.4
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            contentStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    func titleText() -> String {
        switch provider {
        case .apple: return "Apple"
        case .google: return "Google"
        }
    }

    func makeIconView() -> UIView {
        switch provider {
        case .apple:
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .label
            let config = UIImage.SymbolConfiguration(pointSize: Constants.iconSize, weight: .medium)
            imageView.image = UIImage(systemName: "apple.logo", withConfiguration: config)?
                .withRenderingMode(.alwaysTemplate)
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: Constants.iconSize),
                imageView.heightAnchor.constraint(equalToConstant: Constants.iconSize),
            ])

            return imageView

        case .google:
            let label = UILabel()
            label.text = "G"
            label.font = .boldSystemFont(ofSize: Constants.iconSize)
            label.textColor = UIColor(red: 0.26, green: 0.52, blue: 0.96, alpha: 1)
            label.isUserInteractionEnabled = false

            return label
        }
    }
}

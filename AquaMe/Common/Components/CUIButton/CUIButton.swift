//
//  CUIButton.swift
//  AquaMe
//

import UIKit

// MARK: - CUIButton

final class CUIButton: UIView {

    // MARK: - Private enums

    private enum Constants {

        static let height: CGFloat = 56
        static let cornerRadius: CGFloat = 16
        static let horizontalPadding: CGFloat = 24
        static let iconSpacing: CGFloat = 8
        static let titleFontSize: CGFloat = 17
        static let pressedScale: CGFloat = 0.95
        static let pressAnimationDuration: TimeInterval = 0.1
        static let releaseAnimationDuration: TimeInterval = 0.2
        static let springDamping: CGFloat = 0.5
        static let springVelocity: CGFloat = 0.5
        static let iconSize: CGFloat = 20
    }

    // MARK: - Public properties

    var onTap: (() -> Void)?

    var isEnabled: Bool = true {
        didSet {
            updateEnabledAppearance()
        }
    }

    var isLoading: Bool = false {
        didSet {
            updateLoadingState()
        }
    }

    // MARK: - Private properties

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .white
        indicator.hidesWhenStopped = true

        return indicator
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.isHidden = true

        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: Constants.titleFontSize)
        label.textColor = .white
        label.textAlignment = .center

        return label
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = Constants.iconSpacing

        return stack
    }()

    // MARK: - Initialization

    init(title: String, icon: UIImage? = nil) {
        super.init(frame: .zero)
        setup()
        configure(title: title, icon: icon)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

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
        guard !isLoading else { return }
        onTap?()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard isEnabled else { return }

        animateRelease()
    }
}

// MARK: - CUIButton + Public

extension CUIButton {

    func configure(title: String, icon: UIImage? = nil) {
        titleLabel.text = title
        iconImageView.image = icon?.withRenderingMode(.alwaysTemplate)
        iconImageView.isHidden = icon == nil
    }
}

// MARK: - CUIButton + Actions

private extension CUIButton {

    func animatePress() {
        UIView.animate(withDuration: Constants.pressAnimationDuration) {
            self.transform = CGAffineTransform(
                scaleX: Constants.pressedScale,
                y: Constants.pressedScale
            )
        }
    }

    func animateRelease() {
        UIView.animate(
            withDuration: Constants.releaseAnimationDuration,
            delay: 0,
            usingSpringWithDamping: Constants.springDamping,
            initialSpringVelocity: Constants.springVelocity
        ) {
            self.transform = .identity
        }
    }
}

// MARK: - CUIButton + Setup

private extension CUIButton {

    func setup() {
        setupViews()
        setupConstraints()
        setupGestures()
    }

    func setupViews() {
        layer.cornerRadius = Constants.cornerRadius
        addSubview(contentStackView)
        addSubview(activityIndicator)
        updateEnabledAppearance()
    }

    func updateEnabledAppearance() {
        backgroundColor = isEnabled && !isLoading ? .systemIndigo : .systemIndigo.withAlphaComponent(0.35)
    }

    func updateLoadingState() {
        if isLoading {
            activityIndicator.startAnimating()
            contentStackView.alpha = 0
        } else {
            activityIndicator.stopAnimating()
            contentStackView.alpha = 1
        }
        updateEnabledAppearance()
    }

    func setupConstraints() {
        setupConstraintsForHeight()
        setupConstraintsForContentStackView()
        setupConstraintsForIconImageView()
        setupConstraintsForActivityIndicator()
    }

    func setupConstraintsForHeight() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Constants.height),
        ])
    }

    func setupConstraintsForContentStackView() {
        NSLayoutConstraint.activate([
            contentStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentStackView.leadingAnchor.constraint(
                greaterThanOrEqualTo: leadingAnchor,
                constant: Constants.horizontalPadding
            ),
            contentStackView.trailingAnchor.constraint(
                lessThanOrEqualTo: trailingAnchor,
                constant: -Constants.horizontalPadding
            ),
        ])
    }

    func setupConstraintsForIconImageView() {
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Constants.iconSize),
        ])
    }

    func setupConstraintsForActivityIndicator() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    func setupGestures() {
        isUserInteractionEnabled = true
    }
}

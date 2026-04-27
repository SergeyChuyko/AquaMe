//
//  CUINavigationBar.swift
//  AquaMe
//

import UIKit

// MARK: - CUINavigationBar

/// Кастомный навбар с тайтлом по центру и опциональными кнопками слева/справа.
/// Включает дивайдер снизу. Используется вместо UINavigationBar на всех экранах.
final class CUINavigationBar: UIView {

    // MARK: - Private enums

    private enum Constants {

        static let titleFontSize: CGFloat = 17
        static let verticalPadding: CGFloat = 16
        static let buttonSize: CGFloat = 44
        static let buttonIconSize: CGFloat = 20
        static let dividerHeight: CGFloat = 1
    }

    // MARK: - Public properties

    var onTapLeft: (() -> Void)?
    var onTapRight: (() -> Void)?

    var rightButtonTintColor: UIColor? {
        didSet {
            rightButton.tintColor = rightButtonTintColor ?? .systemIndigo
        }
    }

    // MARK: - Private properties

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: Constants.titleFontSize)
        label.textAlignment = .center

        return label
    }()

    private lazy var leftButton: UIButton = {
        let action = UIAction { [weak self] _ in
            guard let self else { return }

            onTapLeft?()
        }
        let button = UIButton(primaryAction: action)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .systemIndigo
        button.isHidden = true

        return button
    }()

    private lazy var rightButton: UIButton = {
        let action = UIAction { [weak self] _ in
            guard let self else { return }

            onTapRight?()
        }
        let button = UIButton(primaryAction: action)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .systemIndigo
        button.isHidden = true

        return button
    }()

    private lazy var dividerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5

        return view
    }()

    // MARK: - Initialization

    init(title: String, leftIcon: UIImage? = nil, rightIcon: UIImage? = nil) {
        super.init(frame: .zero)
        setup()
        configure(title: title, leftIcon: leftIcon, rightIcon: rightIcon)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}

// MARK: - CUINavigationBar + Public

extension CUINavigationBar {

    func configure(title: String, leftIcon: UIImage? = nil, rightIcon: UIImage? = nil) {
        titleLabel.text = title

        let iconConfig = UIImage.SymbolConfiguration(pointSize: Constants.buttonIconSize, weight: .semibold)
        leftButton.setImage(leftIcon?.withConfiguration(iconConfig), for: .normal)
        leftButton.isHidden = leftIcon == nil
        rightButton.setImage(rightIcon?.withConfiguration(iconConfig), for: .normal)
        rightButton.isHidden = rightIcon == nil
    }
}

// MARK: - CUINavigationBar + Setup

private extension CUINavigationBar {

    func setup() {
        setupViews()
        setupConstraints()
    }

    func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        addSubview(leftButton)
        addSubview(rightButton)
        addSubview(dividerView)
    }

    func setupConstraints() {
        setupConstraintsForTitleLabel()
        setupConstraintsForLeftButton()
        setupConstraintsForRightButton()
        setupConstraintsForDividerView()
    }

    func setupConstraintsForTitleLabel() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: topAnchor,
                constant: Constants.verticalPadding
            ),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(
                equalTo: dividerView.topAnchor,
                constant: -Constants.verticalPadding
            ),
        ])
    }

    func setupConstraintsForLeftButton() {
        NSLayoutConstraint.activate([
            leftButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            leftButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            leftButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            leftButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
        ])
    }

    func setupConstraintsForRightButton() {
        NSLayoutConstraint.activate([
            rightButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            rightButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            rightButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            rightButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
        ])
    }

    func setupConstraintsForDividerView() {
        NSLayoutConstraint.activate([
            dividerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dividerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: Constants.dividerHeight),
        ])
    }
}

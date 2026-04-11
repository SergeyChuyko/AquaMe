//
//  CUISelectCard.swift
//  AquaMe
//

import UIKit

// MARK: - CUISelectCard

final class CUISelectCard: UIView {

    // MARK: - Private enums

    private enum Constants {

        static let cornerRadius: CGFloat = 16
        static let borderWidth: CGFloat = 2
        static let iconContainerSize: CGFloat = 52
        static let iconContainerCornerRadius: CGFloat = 14
        static let iconSize: CGFloat = 26
        static let verticalPadding: CGFloat = 16
        static let horizontalPadding: CGFloat = 12
        static let stackSpacing: CGFloat = 8
        static let titleFontSize: CGFloat = 15
        static let subtitleFontSize: CGFloat = 13
        static let animationDuration: TimeInterval = 0.2
        static let titleNumberOfLines: Int = 2
    }

    private enum Colors {

        static let selectedBorder = UIColor.systemIndigo
        static let selectedBackground = UIColor.systemIndigo.withAlphaComponent(0.07)
        static let selectedIconBackground = UIColor.systemIndigo.withAlphaComponent(0.15)
        static let selectedIconTint = UIColor.systemIndigo
        static let selectedTitle = UIColor.systemIndigo

        static let deselectedBorder = UIColor.systemGray4
        static let deselectedBackground = UIColor.white
        static let deselectedIconBackground = UIColor.systemGray5
        static let deselectedIconTint = UIColor.systemGray
        static let deselectedTitle = UIColor.label
    }

    // MARK: - Public properties

    var onTap: (() -> Void)?

    private(set) var isSelected: Bool = false

    // MARK: - Private properties

    private lazy var iconContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.iconContainerCornerRadius

        return view
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: Constants.titleFontSize)
        label.textAlignment = .center
        label.numberOfLines = Constants.titleNumberOfLines

        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.subtitleFontSize)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.isHidden = true

        return label
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconContainerView, titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = Constants.stackSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }()

    // MARK: - Initialization

    init(icon: UIImage?, title: String, subtitle: String? = nil) {
        super.init(frame: .zero)
        setup()
        configure(icon: icon, title: title, subtitle: subtitle)
        applyDeselectedStyle()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}

// MARK: - CUISelectCard + Public

extension CUISelectCard {

    func setSelected(_ selected: Bool, animated: Bool = true) {
        isSelected = selected

        guard animated else {
            applyStyle()
            return
        }

        UIView.animate(withDuration: Constants.animationDuration) {
            self.applyStyle()
        }
    }

    func configure(icon: UIImage?, title: String, subtitle: String? = nil) {
        iconImageView.image = icon
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil
    }
}

// MARK: - CUISelectCard + Actions

private extension CUISelectCard {

    @objc func handleTap() {
        onTap?()
    }

    func applyStyle() {
        isSelected ? applySelectedStyle() : applyDeselectedStyle()
    }

    func applySelectedStyle() {
        layer.borderColor = Colors.selectedBorder.cgColor
        backgroundColor = Colors.selectedBackground
        iconContainerView.backgroundColor = Colors.selectedIconBackground
        iconImageView.tintColor = Colors.selectedIconTint
        titleLabel.textColor = Colors.selectedTitle
    }

    func applyDeselectedStyle() {
        layer.borderColor = Colors.deselectedBorder.cgColor
        backgroundColor = Colors.deselectedBackground
        iconContainerView.backgroundColor = Colors.deselectedIconBackground
        iconImageView.tintColor = Colors.deselectedIconTint
        titleLabel.textColor = Colors.deselectedTitle
    }
}

// MARK: - CUISelectCard + Setup

private extension CUISelectCard {

    func setup() {
        setupViews()
        setupConstraints()
        setupGesture()
    }

    func setupViews() {
        layer.cornerRadius = Constants.cornerRadius
        layer.borderWidth = Constants.borderWidth
        addSubview(contentStackView)
        iconContainerView.addSubview(iconImageView)
    }

    func setupConstraints() {
        setupConstraintsForContentStackView()
        setupConstraintsForIconContainer()
        setupConstraintsForIconImageView()
    }

    func setupConstraintsForContentStackView() {
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(
                equalTo: topAnchor,
                constant: Constants.verticalPadding
            ),
            contentStackView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Constants.horizontalPadding
            ),
            contentStackView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Constants.horizontalPadding
            ),
            contentStackView.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -Constants.verticalPadding
            ),
        ])
    }

    func setupConstraintsForIconContainer() {
        NSLayoutConstraint.activate([
            iconContainerView.widthAnchor.constraint(equalToConstant: Constants.iconContainerSize),
            iconContainerView.heightAnchor.constraint(equalToConstant: Constants.iconContainerSize),
        ])
    }

    func setupConstraintsForIconImageView() {
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Constants.iconSize),
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
        ])
    }

    func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }
}

//
//  CUIText.swift
//  AquaMe
//

import UIKit

// MARK: - CUIText

final class CUIText: UIView {

    // MARK: - Private enums

    private enum Constants {

        static let titleFontSize: CGFloat = 16
        static let subtitleFontSize: CGFloat = 14
        static let spacing: CGFloat = 4
    }

    // MARK: - Private properties

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: Constants.titleFontSize)
        label.textColor = .label
        label.numberOfLines = 0

        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.subtitleFontSize)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.isHidden = true

        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = Constants.spacing
        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }()

    // MARK: - Initialization

    init(title: String, subtitle: String? = nil) {
        super.init(frame: .zero)
        setup()
        configure(title: title, subtitle: subtitle)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - CUIText + Public

extension CUIText {

    func configure(title: String, subtitle: String? = nil) {
        titleLabel.text = title

        if let subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
        }
    }
}

// MARK: - CUIText + Setup

private extension CUIText {

    func setup() {
        setupViews()
        setupConstraints()
    }

    func setupViews() {
        addSubview(stackView)
    }

    func setupConstraints() {
        setupConstraintsForStackView()
    }

    func setupConstraintsForStackView() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

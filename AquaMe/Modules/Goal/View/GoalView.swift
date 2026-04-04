//
//  GoalView.swift
//  AquaMe
//
//  Created by Sergey on 04.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - GoalViewDelegate

/// Сообщает контроллеру о действиях пользователя на экране выбора цели.
protocol GoalViewDelegate: AnyObject {

    func goalViewDidTapBack(_ view: GoalView)
    func goalViewDidTapGetStarted(_ view: GoalView)
}

// MARK: - GoalView

/// Вью второго экрана онбординга — пользователь выбирает цель использования приложения.
final class GoalView: UIView {

    // MARK: - Private enums

    private enum Constants {

        static let descriptionTopSpacing: CGFloat = 32
        static let goalsStackTopSpacing: CGFloat = 16
        static let goalsStackSpacing: CGFloat = 12
        static let goalsStackBottomSpacing: CGFloat = 32
        static let getStartedButtonSpacing: CGFloat = 12
        static let sidePadding: CGFloat = 16
    }

    private enum Strings {

        static let navigationTitle = "Goal Setup"
        static let descriptionTitle = "What is your goal?"
        static let descriptionSubtitle = "We will calculate your daily intake based on this."
        static let getStartedButton = "Get Started"
    }

    // MARK: - Public properties

    weak var delegate: GoalViewDelegate?

    // MARK: - Private properties

    private lazy var navigationBar: CUINavigationBar = {
        let bar = CUINavigationBar(
            title: Strings.navigationTitle,
            leftIcon: UIImage(systemName: "chevron.left")
        )
        bar.onTapLeft = { [weak self] in
            guard let self else { return }
            delegate?.goalViewDidTapBack(self)
        }

        return bar
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .always

        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var descriptionText: CUIText = {
        let text = CUIText(title: Strings.descriptionTitle, subtitle: Strings.descriptionSubtitle)
        text.translatesAutoresizingMaskIntoConstraints = false

        return text
    }()

    private lazy var stayHealthyCard: CUISelectCard = {
        let card = CUISelectCard(
            icon: UIImage(systemName: "heart.fill"),
            title: "Stay healthy",
            subtitle: "Maintenance"
        )
        card.translatesAutoresizingMaskIntoConstraints = false
        card.onTap = { [weak self] in
            guard let self else { return }
            selectGoalCard(card)
        }

        return card
    }()

    private lazy var loseWeightCard: CUISelectCard = {
        let card = CUISelectCard(
            icon: UIImage(systemName: "figure.run"),
            title: "Lose weight",
            subtitle: "Metabolism"
        )
        card.translatesAutoresizingMaskIntoConstraints = false
        card.onTap = { [weak self] in
            guard let self else { return }
            selectGoalCard(card)
        }

        return card
    }()

    private lazy var stayActiveCard: CUISelectCard = {
        let card = CUISelectCard(
            icon: UIImage(systemName: "bolt.fill"),
            title: "Stay active",
            subtitle: "Performance"
        )
        card.translatesAutoresizingMaskIntoConstraints = false
        card.onTap = { [weak self] in
            guard let self else { return }
            selectGoalCard(card)
        }

        return card
    }()

    private lazy var goalsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [stayHealthyCard, loseWeightCard, stayActiveCard])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = Constants.goalsStackSpacing

        return stack
    }()

    private lazy var getStartedButton: CUIButton = {
        let button = CUIButton(title: Strings.getStartedButton)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.onTap = { [weak self] in
            guard let self else { return }
            delegate?.goalViewDidTapGetStarted(self)
        }

        return button
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - GoalView + Actions

private extension GoalView {

    func selectGoalCard(_ selected: CUISelectCard) {
        let allCards = [stayHealthyCard, loseWeightCard, stayActiveCard]

        allCards.forEach { card in
            card.setSelected(card === selected)
        }
    }
}

// MARK: - GoalView + Setup

private extension GoalView {

    func setup() {
        setupViews()
        setupConstraints()
    }

    func setupViews() {
        backgroundColor = .white
        addSubview(navigationBar)
        addSubview(getStartedButton)
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(descriptionText)
        contentView.addSubview(goalsStack)
    }

    func setupConstraints() {
        setupConstraintsForNavigationBar()
        setupConstraintsForGetStartedButton()
        setupConstraintsForScrollView()
        setupConstraintsForContentView()
        setupConstraintsForDescriptionText()
        setupConstraintsForGoalsStack()
    }

    func setupConstraintsForNavigationBar() {
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    func setupConstraintsForGetStartedButton() {
        NSLayoutConstraint.activate([
            getStartedButton.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Constants.sidePadding
            ),
            getStartedButton.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Constants.sidePadding
            ),
            getStartedButton.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.bottomAnchor,
                constant: -Constants.getStartedButtonSpacing
            ),
        ])
    }

    func setupConstraintsForScrollView() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(
                equalTo: getStartedButton.topAnchor,
                constant: -Constants.getStartedButtonSpacing
            ),
        ])
    }

    func setupConstraintsForContentView() {
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])
    }

    func setupConstraintsForDescriptionText() {
        NSLayoutConstraint.activate([
            descriptionText.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.sidePadding
            ),
            descriptionText.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.sidePadding
            ),
            descriptionText.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.descriptionTopSpacing
            ),
        ])
    }

    func setupConstraintsForGoalsStack() {
        NSLayoutConstraint.activate([
            goalsStack.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.sidePadding
            ),
            goalsStack.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.sidePadding
            ),
            goalsStack.topAnchor.constraint(
                equalTo: descriptionText.bottomAnchor,
                constant: Constants.goalsStackTopSpacing
            ),
            goalsStack.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Constants.goalsStackBottomSpacing
            ),
        ])
    }
}

// MARK: - Agreement Label (for future Auth screen)

// private lazy var agreementLabel: UILabel = {
//     let label = UILabel()
//     label.translatesAutoresizingMaskIntoConstraints = false
//     label.numberOfLines = 0
//     label.textAlignment = .center
//     label.isUserInteractionEnabled = true
//
//     let agreementFontSize: CGFloat = 13
//     let agreementPrefix = "By continuing, you agree to "
//     let agreementSuffix = "AquaMe's Terms of Service and Privacy Policy."
//
//     let prefix = NSAttributedString(
//         string: agreementPrefix,
//         attributes: [
//             .foregroundColor: UIColor.secondaryLabel,
//             .font: UIFont.systemFont(ofSize: agreementFontSize),
//         ]
//     )
//     let suffix = NSAttributedString(
//         string: agreementSuffix,
//         attributes: [
//             .foregroundColor: UIColor.systemIndigo,
//             .font: UIFont.systemFont(ofSize: agreementFontSize),
//         ]
//     )
//     let attributed = NSMutableAttributedString()
//     attributed.append(prefix)
//     attributed.append(suffix)
//     label.attributedText = attributed
//
//     let tap = UITapGestureRecognizer(target: self, action: #selector(handleAgreementTap))
//     label.addGestureRecognizer(tap)
//
//     return label
// }()

// @objc func handleAgreementTap() {
//     print("ты нажал на соглашение")
// }

// Constraints (pin below action button):
// agreementLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
// agreementLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
// agreementLabel.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: 12),

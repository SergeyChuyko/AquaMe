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
        static let stayHealthyDescription = "Maintain your current hydration level. "
            + "Recommended daily intake based on your weight × 30ml."
        static let loseWeightDescription = "Boost your metabolism with extra water. "
            + "10% more than the base intake to support weight loss."
        static let stayActiveDescription = "Stay hydrated during workouts. "
            + "20% more than the base intake for active lifestyle."
    }

    // MARK: - Public properties

    weak var delegate: GoalViewDelegate?
    var onGoalChanged: (() -> Void)?

    func setButtonTitle(_ title: String) {
        getStartedButton.configure(title: title)
    }

    func setButtonEnabled(_ enabled: Bool) {
        getStartedButton.isEnabled = enabled
    }

    func selectGoal(_ goal: UserProfile.Goal) {
        let allCards = [stayHealthyCard, loseWeightCard, stayActiveCard]

        allCards.forEach { card in
            card.setSelected(false)
        }

        switch goal {
        case .stayHealthy:
            stayHealthyCard.setSelected(true)
        case .loseWeight:
            loseWeightCard.setSelected(true)
        case .stayActive:
            stayActiveCard.setSelected(true)
        }

        updateGoalDescription()
    }

    var selectedGoal: UserProfile.Goal? {
        if stayHealthyCard.isSelected { return .stayHealthy }
        if loseWeightCard.isSelected { return .loseWeight }
        if stayActiveCard.isSelected { return .stayActive }
        return nil
    }

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

    private lazy var goalDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true

        return label
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

        updateGoalDescription()
        onGoalChanged?()
    }

    func updateGoalDescription() {
        guard let goal = selectedGoal else {
            goalDescriptionLabel.isHidden = true
            return
        }

        switch goal {
        case .stayHealthy:
            goalDescriptionLabel.text = Strings.stayHealthyDescription
        case .loseWeight:
            goalDescriptionLabel.text = Strings.loseWeightDescription
        case .stayActive:
            goalDescriptionLabel.text = Strings.stayActiveDescription
        }

        goalDescriptionLabel.isHidden = false
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
        contentView.addSubview(goalDescriptionLabel)
    }

    func setupConstraints() {
        setupConstraintsForNavigationBar()
        setupConstraintsForGetStartedButton()
        setupConstraintsForScrollView()
        setupConstraintsForContentView()
        setupConstraintsForDescriptionText()
        setupConstraintsForGoalsStack()
        setupConstraintsForGoalDescriptionLabel()
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
        ])
    }

    func setupConstraintsForGoalDescriptionLabel() {
        NSLayoutConstraint.activate([
            goalDescriptionLabel.topAnchor.constraint(
                equalTo: goalsStack.bottomAnchor,
                constant: 16
            ),
            goalDescriptionLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.sidePadding
            ),
            goalDescriptionLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.sidePadding
            ),
            goalDescriptionLabel.bottomAnchor.constraint(
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

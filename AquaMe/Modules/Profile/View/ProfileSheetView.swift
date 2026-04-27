//
//  ProfileSheetView.swift
//  AquaMe
//
//  Created by Friday on 22.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - ProfileSheetViewDelegate

protocol ProfileSheetViewDelegate: AnyObject {

    func profileSheetViewDidTapEdit(_ view: ProfileSheetView)
}

// MARK: - ProfileSheetView

final class ProfileSheetView: UIView {

    // MARK: - Private enums

    private enum Constants {

        static let profileImageSize: CGFloat = 80
        static let profileImageCornerRadius: CGFloat = 40
        static let profileImageTopOffset: CGFloat = 24
        static let nameTopSpacing: CGFloat = 16
        static let nameFontSize: CGFloat = 22
        static let subtitleFontSize: CGFloat = 14
        static let subtitleTopSpacing: CGFloat = 8
        static let statsTopSpacing: CGFloat = 16
        static let statsSpacing: CGFloat = 12
        static let statCardHeight: CGFloat = 80
        static let statCardCornerRadius: CGFloat = 12
        static let statValueFontSize: CGFloat = 22
        static let statLabelFontSize: CGFloat = 11
        static let statIconSize: CGFloat = 16
        static let sidePadding: CGFloat = 16
        static let buttonTopSpacing: CGFloat = 20
        static let buttonBottomSpacing: CGFloat = 16
        static let bottomStatsTopSpacing: CGFloat = 12
        static let bottomStatHeight: CGFloat = 70
        static let bottomStatValueFontSize: CGFloat = 20
        static let bottomStatLabelFontSize: CGFloat = 13
    }

    private enum Strings {

        static let editButton = "Edit Profile Settings"
        static let years = "YEARS"
        static let kg = "KG"
        static let goalL = "GOAL L"
        static let goalCompletion = "Goal Completion"
        static let avgIntake = "Avg. Intake"
    }

    // MARK: - Public properties

    weak var delegate: ProfileSheetViewDelegate?

    // MARK: - Private properties

    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.1)
        imageView.layer.cornerRadius = Constants.profileImageCornerRadius
        imageView.clipsToBounds = true
        imageView.contentMode = .center
        let config = UIImage.SymbolConfiguration(pointSize: 36, weight: .thin)
        imageView.image = UIImage(
            systemName: "person.crop.circle.fill",
            withConfiguration: config
        )
        imageView.tintColor = .systemIndigo.withAlphaComponent(0.5)

        return imageView
    }()


    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: Constants.nameFontSize)
        label.textAlignment = .center
        label.numberOfLines = 0

        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.subtitleFontSize)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.numberOfLines = 0

        return label
    }()

    private lazy var ageStatCard: UIView = {
        makeStatCard(icon: "clock", iconColor: .systemBlue, value: "—", label: Strings.years)
    }()

    private lazy var weightStatCard: UIView = {
        makeStatCard(icon: "scalemass", iconColor: .systemIndigo, value: "—", label: Strings.kg)
    }()

    private lazy var goalStatCard: UIView = {
        makeStatCard(icon: "target", iconColor: .systemTeal, value: "—", label: Strings.goalL)
    }()

    private lazy var topStatsStack: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [ageStatCard, weightStatCard, goalStatCard]
        )
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = Constants.statsSpacing

        return stack
    }()

    private lazy var completionCard: UIView = {
        makeBottomStatCard(
            label: Strings.goalCompletion,
            value: "—",
            valueColor: .systemGreen
        )
    }()

    private lazy var intakeCard: UIView = {
        makeBottomStatCard(
            label: Strings.avgIntake,
            value: "—",
            valueColor: .label
        )
    }()

    private lazy var bottomStatsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [completionCard, intakeCard])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = Constants.statsSpacing

        return stack
    }()

    private lazy var editButton: CUIButton = {
        let button = CUIButton(title: Strings.editButton)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.onTap = { [weak self] in
            guard let self else { return }

            handleEditTap()
        }

        return button
    }()

    private var ageValueLabel: UILabel?
    private var weightValueLabel: UILabel?
    private var goalValueLabel: UILabel?
    private var completionValueLabel: UILabel?
    private var intakeValueLabel: UILabel?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - ProfileSheetView + Public methods

extension ProfileSheetView {

    func configure(with profile: UserProfile) {
        nameLabel.text = profile.name

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let since = formatter.string(from: profile.memberSince)
        subtitleLabel.text = "Hydration Enthusiast • Member since \(since)"

        if let avatarName = profile.avatarURL {
            let url = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            )[0].appendingPathComponent(avatarName)

            if let image = UIImage(contentsOfFile: url.path) {
                profileImageView.image = image
                profileImageView.contentMode = .scaleAspectFill
            }
        }

        ageValueLabel?.text = "\(profile.age)"
        weightValueLabel?.text = "\(Int(profile.weight))"

        let goalInLiters = Double(profile.dailyGoal) / 1000.0
        goalValueLabel?.text = String(format: "%.1f", goalInLiters)

        // Реальные значения Goal Completion и Avg. Intake пока не заведены —
        // показываем «—» вместо вводящих в заблуждение чисел из профиля.
        // TODO: подтянуть из ProgressViewModel-стиля агрегатора.
        completionValueLabel?.text = "—"
        intakeValueLabel?.text = "—"
    }
}

// MARK: - ProfileSheetView + Actions

private extension ProfileSheetView {

    func handleEditTap() {
        delegate?.profileSheetViewDidTapEdit(self)
    }
}

// MARK: - ProfileSheetView + Setup

private extension ProfileSheetView {

    func setup() {
        setupViews()
        setupConstraints()
    }

    func setupViews() {
        backgroundColor = .white
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(subtitleLabel)
        addSubview(topStatsStack)
        addSubview(bottomStatsStack)
        addSubview(editButton)
    }

    func setupConstraints() {
        setupConstraintsForProfileImageView()
        setupConstraintsForNameLabel()
        setupConstraintsForSubtitleLabel()
        setupConstraintsForTopStatsStack()
        setupConstraintsForBottomStatsStack()
        setupConstraintsForEditButton()
    }

    func setupConstraintsForProfileImageView() {
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(
                equalTo: topAnchor,
                constant: Constants.profileImageTopOffset
            ),
            profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageView.widthAnchor.constraint(
                equalToConstant: Constants.profileImageSize
            ),
            profileImageView.heightAnchor.constraint(
                equalToConstant: Constants.profileImageSize
            ),
        ])
    }

    func setupConstraintsForNameLabel() {
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(
                equalTo: profileImageView.bottomAnchor,
                constant: Constants.nameTopSpacing
            ),
            nameLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Constants.sidePadding
            ),
            nameLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Constants.sidePadding
            ),
        ])
    }

    func setupConstraintsForSubtitleLabel() {
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(
                equalTo: nameLabel.bottomAnchor,
                constant: Constants.subtitleTopSpacing
            ),
            subtitleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Constants.sidePadding
            ),
            subtitleLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Constants.sidePadding
            ),
        ])
    }

    func setupConstraintsForTopStatsStack() {
        NSLayoutConstraint.activate([
            topStatsStack.topAnchor.constraint(
                equalTo: subtitleLabel.bottomAnchor,
                constant: Constants.statsTopSpacing
            ),
            topStatsStack.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Constants.sidePadding
            ),
            topStatsStack.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Constants.sidePadding
            ),
            topStatsStack.heightAnchor.constraint(
                equalToConstant: Constants.statCardHeight
            ),
        ])
    }

    func setupConstraintsForBottomStatsStack() {
        NSLayoutConstraint.activate([
            bottomStatsStack.topAnchor.constraint(
                equalTo: topStatsStack.bottomAnchor,
                constant: Constants.bottomStatsTopSpacing
            ),
            bottomStatsStack.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Constants.sidePadding
            ),
            bottomStatsStack.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Constants.sidePadding
            ),
            bottomStatsStack.heightAnchor.constraint(
                equalToConstant: Constants.bottomStatHeight
            ),
        ])
    }

    func setupConstraintsForEditButton() {
        NSLayoutConstraint.activate([
            editButton.topAnchor.constraint(
                greaterThanOrEqualTo: bottomStatsStack.bottomAnchor,
                constant: Constants.buttonTopSpacing
            ),
            editButton.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Constants.sidePadding
            ),
            editButton.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Constants.sidePadding
            ),
            editButton.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -Constants.buttonBottomSpacing
            ),
        ])
    }
}

// MARK: - ProfileSheetView + Factory

private extension ProfileSheetView {

    func makeStatCard(
        icon: String,
        iconColor: UIColor,
        value: String,
        label: String
    ) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor.systemGray6
        card.layer.cornerRadius = Constants.statCardCornerRadius

        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(
            pointSize: Constants.statIconSize,
            weight: .medium
        )
        iconView.image = UIImage(systemName: icon, withConfiguration: config)
        iconView.tintColor = iconColor
        iconView.contentMode = .scaleAspectFit

        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.font = .boldSystemFont(ofSize: Constants.statValueFontSize)
        valueLabel.textAlignment = .center
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.6

        let unitLabel = UILabel()
        unitLabel.translatesAutoresizingMaskIntoConstraints = false
        unitLabel.text = label
        unitLabel.font = .systemFont(
            ofSize: Constants.statLabelFontSize,
            weight: .medium
        )
        unitLabel.textColor = .systemGray
        unitLabel.textAlignment = .center

        card.addSubview(iconView)
        card.addSubview(valueLabel)
        card.addSubview(unitLabel)

        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            iconView.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: Constants.statIconSize),
            iconView.heightAnchor.constraint(equalToConstant: Constants.statIconSize),

            valueLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor, constant: 4),

            unitLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2),
            unitLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
        ])

        switch label {
        case Strings.years:
            ageValueLabel = valueLabel
        case Strings.kg:
            weightValueLabel = valueLabel
        case Strings.goalL:
            goalValueLabel = valueLabel
        default:
            break
        }

        return card
    }

    func makeBottomStatCard(
        label: String,
        value: String,
        valueColor: UIColor
    ) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor.systemGray6
        card.layer.cornerRadius = Constants.statCardCornerRadius

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = label
        titleLabel.font = .systemFont(ofSize: Constants.bottomStatLabelFontSize)
        titleLabel.textColor = .systemGray

        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.font = .boldSystemFont(ofSize: Constants.bottomStatValueFontSize)
        valueLabel.textColor = valueColor

        card.addSubview(titleLabel)
        card.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),

            valueLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            valueLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
        ])

        if label == Strings.goalCompletion {
            completionValueLabel = valueLabel
        } else {
            intakeValueLabel = valueLabel
        }

        return card
    }
}

//
//  TodayView.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - TodayViewDelegate

protocol TodayViewDelegate: AnyObject {

    func todayView(_ view: TodayView, didSelectPreset amount: Int)
    func todayView(_ view: TodayView, didTapQuickAmount amount: Int)
    func todayView(_ view: TodayView, didToggleRemoveMode isOn: Bool)
    func todayViewDidTapLogIntake(_ view: TodayView)
}

// MARK: - TodayView

/// Корневая вью экрана Today: заголовок, кольцо прогресса, цели, пресеты, быстрые кнопки,
/// переключатель режима удаления и основная кнопка Log/Remove Intake.
final class TodayView: UIView {

    // MARK: - Private enums

    private enum Constants {

        static let horizontalPadding: CGFloat = 24
        static let verticalSpacing: CGFloat = 24
        static let groupSpacing: CGFloat = 16
        static let ringSize: CGFloat = 240
        static let cardCornerRadius: CGFloat = 16
        static let cardPadding: CGFloat = 16
        static let titleFontSize: CGFloat = 22
        static let smallTitleFontSize: CGFloat = 13
        static let valueFontSize: CGFloat = 20
        static let modeRowHeight: CGFloat = 44
        static let avatarSize: CGFloat = 40
    }

    private enum Images {

        static let avatarPlaceholder = UIImage(systemName: "person.crop.circle.fill")
        static let plus = UIImage(systemName: "plus")
        static let minus = UIImage(systemName: "minus")
    }

    // MARK: - Public properties

    weak var delegate: TodayViewDelegate?

    // MARK: - Private properties

    private var presetCards: [TodayPresetCardView] = []
    private var quickButtons: [TodayQuickAmountButton] = []
    private var currentState: TodayState?

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false

        return view
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = Constants.verticalSpacing

        return stack
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.titleFontSize, weight: .bold)
        label.text = "AquaMe"
        label.textAlignment = .center

        return label
    }()

    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView(image: Images.avatarPlaceholder)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .systemIndigo.withAlphaComponent(0.3)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.avatarSize / 2

        return imageView
    }()

    private lazy var headerRow: UIView = {
        let view = UIView()
        view.addSubview(titleLabel)
        view.addSubview(avatarImageView)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            avatarImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: Constants.avatarSize),
            avatarImageView.heightAnchor.constraint(equalToConstant: Constants.avatarSize),
            view.heightAnchor.constraint(equalToConstant: Constants.avatarSize + 8),
        ])

        return view
    }()

    private lazy var ringView = TodayProgressRingView()

    private lazy var ringContainer: UIView = {
        let container = UIView()
        ringView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(ringView)
        NSLayoutConstraint.activate([
            ringView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            ringView.topAnchor.constraint(equalTo: container.topAnchor),
            ringView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            ringView.widthAnchor.constraint(equalToConstant: Constants.ringSize),
            ringView.heightAnchor.constraint(equalToConstant: Constants.ringSize),
        ])

        return container
    }()

    private lazy var goalRow = makeGoalRow()
    private lazy var dailyGoalValueLabel = makeValueLabel()
    private lazy var remainingValueLabel = makeValueLabel()

    private lazy var presetsRow: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12

        return stack
    }()

    private lazy var customAmountHeader: UIView = {
        let container = UIView()
        let title = UILabel()
        title.text = "Custom Amount"
        title.font = .systemFont(ofSize: 17, weight: .semibold)
        title.translatesAutoresizingMaskIntoConstraints = false

        selectedAmountBadge.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(title)
        container.addSubview(selectedAmountBadge)

        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            title.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            selectedAmountBadge.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            selectedAmountBadge.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            container.heightAnchor.constraint(equalToConstant: 28),
        ])

        return container
    }()

    private lazy var selectedAmountBadge: PaddedLabel = {
        let label = PaddedLabel(insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .systemIndigo
        label.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.12)
        label.layer.cornerRadius = 11
        label.layer.masksToBounds = true
        label.textAlignment = .center

        let height = label.heightAnchor.constraint(equalToConstant: 22)
        height.isActive = true

        return label
    }()

    private lazy var quickRow: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10

        return stack
    }()

    private lazy var modeRow: UIView = {
        let container = UIView()
        modeLabel.translatesAutoresizingMaskIntoConstraints = false
        modeIconBackground.translatesAutoresizingMaskIntoConstraints = false
        modeSwitch.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(modeIconBackground)
        container.addSubview(modeLabel)
        container.addSubview(modeSwitch)

        NSLayoutConstraint.activate([
            modeIconBackground.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            modeIconBackground.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            modeIconBackground.widthAnchor.constraint(equalToConstant: 32),
            modeIconBackground.heightAnchor.constraint(equalToConstant: 32),
            modeLabel.leadingAnchor.constraint(
                equalTo: modeIconBackground.trailingAnchor,
                constant: 10
            ),
            modeLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            modeSwitch.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            modeSwitch.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            container.heightAnchor.constraint(equalToConstant: Constants.modeRowHeight),
        ])

        return container
    }()

    private lazy var modeIconBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.12)

        let icon = UIImageView(image: Images.plus)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = .systemIndigo
        icon.contentMode = .scaleAspectFit
        view.addSubview(icon)
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 16),
            icon.heightAnchor.constraint(equalToConstant: 16),
        ])
        view.tag = 1

        return view
    }()

    private lazy var modeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.text = "Add intake"
        label.textColor = .label

        return label
    }()

    private lazy var modeSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = .systemRed
        toggle.addTarget(self, action: #selector(handleModeChanged), for: .valueChanged)

        return toggle
    }()

    private lazy var logButton: CUIButton = {
        let button = CUIButton(title: "+ Log Intake")
        button.onTap = { [weak self] in
            guard let self else { return }
            self.delegate?.todayViewDidTapLogIntake(self)
        }

        return button
    }()

    private lazy var logButtonContainer: UIView = {
        let container = UIView()
        logButton.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(logButton)
        NSLayoutConstraint.activate([
            logButton.topAnchor.constraint(equalTo: container.topAnchor),
            logButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            logButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            logButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        return container
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - TodayView + Public

extension TodayView {

    func update(with state: TodayState) {
        if currentState?.presetAmounts != state.presetAmounts {
            rebuildPresets(amounts: state.presetAmounts)
        }
        if currentState?.quickAmounts != state.quickAmounts {
            rebuildQuickButtons(amounts: state.quickAmounts)
        }
        currentState = state

        ringView.update(
            progress: state.progress,
            valueText: "\(state.totalDrunk)",
            unitText: state.unit.rawValue,
            percentText: "\(state.progressPercent)% OF GOAL"
        )

        dailyGoalValueLabel.text = "\(state.dailyGoal) \(state.unit.rawValue)"
        remainingValueLabel.text = "\(state.remaining) \(state.unit.rawValue)"
        remainingValueLabel.textColor = state.isRemoveMode ? .systemRed : .systemIndigo

        for card in presetCards {
            card.update(
                isSelected: card.amount == state.selectedAmount,
                isRemoveMode: state.isRemoveMode,
                title: "\(card.amount)\(state.unit.rawValue)"
            )
        }
        for button in quickButtons {
            button.update(isRemoveMode: state.isRemoveMode)
        }

        selectedAmountBadge.text = "\(state.selectedAmount) \(state.unit.rawValue)"
        selectedAmountBadge.textColor = state.isRemoveMode ? .systemRed : .systemIndigo
        selectedAmountBadge.backgroundColor = (state.isRemoveMode ? UIColor.systemRed : UIColor.systemIndigo)
            .withAlphaComponent(0.12)

        applyMode(isRemoveMode: state.isRemoveMode)

        if modeSwitch.isOn != state.isRemoveMode {
            modeSwitch.setOn(state.isRemoveMode, animated: false)
        }

        if let path = state.avatarPath, let image = UIImage(contentsOfFile: path) {
            avatarImageView.image = image
            avatarImageView.tintColor = .clear
        }
    }
}

// MARK: - TodayView + Setup

private extension TodayView {

    func setup() {
        backgroundColor = .systemBackground
        setupViews()
        setupConstraints()
    }

    func setupViews() {
        addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(headerRow)
        contentStack.addArrangedSubview(ringContainer)
        contentStack.addArrangedSubview(goalRow)
        contentStack.addArrangedSubview(presetsRow)
        contentStack.addArrangedSubview(customAmountHeader)
        contentStack.addArrangedSubview(quickRow)
        contentStack.addArrangedSubview(modeRow)
        contentStack.addArrangedSubview(logButtonContainer)

        contentStack.setCustomSpacing(Constants.groupSpacing, after: customAmountHeader)
        contentStack.setCustomSpacing(Constants.groupSpacing, after: quickRow)
    }

    func setupConstraints() {
        let frameGuide = scrollView.frameLayoutGuide
        let contentGuide = scrollView.contentLayoutGuide

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: contentGuide.topAnchor, constant: 12),
            contentStack.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor, constant: -24),
            contentStack.leadingAnchor.constraint(
                equalTo: contentGuide.leadingAnchor,
                constant: Constants.horizontalPadding
            ),
            contentStack.trailingAnchor.constraint(
                equalTo: contentGuide.trailingAnchor,
                constant: -Constants.horizontalPadding
            ),
            contentStack.widthAnchor.constraint(
                equalTo: frameGuide.widthAnchor,
                constant: -Constants.horizontalPadding * 2
            ),
        ])
    }

    func makeGoalRow() -> UIStackView {
        let dailyTitle = UILabel()
        dailyTitle.text = "DAILY GOAL"
        dailyTitle.font = .systemFont(ofSize: Constants.smallTitleFontSize, weight: .medium)
        dailyTitle.textColor = .secondaryLabel

        let remainingTitle = UILabel()
        remainingTitle.text = "REMAINING"
        remainingTitle.font = .systemFont(ofSize: Constants.smallTitleFontSize, weight: .medium)
        remainingTitle.textColor = .secondaryLabel

        let dailyColumn = UIStackView(arrangedSubviews: [dailyTitle, dailyGoalValueLabel])
        dailyColumn.axis = .vertical
        dailyColumn.alignment = .center
        dailyColumn.spacing = 4

        let remainingColumn = UIStackView(arrangedSubviews: [remainingTitle, remainingValueLabel])
        remainingColumn.axis = .vertical
        remainingColumn.alignment = .center
        remainingColumn.spacing = 4

        let row = UIStackView(arrangedSubviews: [dailyColumn, remainingColumn])
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 16

        return row
    }

    func makeValueLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.valueFontSize, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center

        return label
    }

    func rebuildPresets(amounts: [Int]) {
        presetsRow.arrangedSubviews.forEach { $0.removeFromSuperview() }
        presetCards = amounts.map { amount in
            let card = TodayPresetCardView(amount: amount)
            card.onTap = { [weak self] in
                guard let self else { return }
                self.delegate?.todayView(self, didSelectPreset: amount)
            }
            return card
        }
        for card in presetCards {
            presetsRow.addArrangedSubview(card)
        }
    }

    func rebuildQuickButtons(amounts: [Int]) {
        quickRow.arrangedSubviews.forEach { $0.removeFromSuperview() }
        quickButtons = amounts.map { amount in
            let button = TodayQuickAmountButton(amount: amount)
            button.onTap = { [weak self] in
                guard let self else { return }
                self.delegate?.todayView(self, didTapQuickAmount: amount)
            }
            return button
        }
        for button in quickButtons {
            quickRow.addArrangedSubview(button)
        }
    }

    func applyMode(isRemoveMode: Bool) {
        let accent: UIColor = isRemoveMode ? .systemRed : .systemIndigo
        modeIconBackground.backgroundColor = accent.withAlphaComponent(0.12)
        if let icon = modeIconBackground.subviews.first as? UIImageView {
            icon.image = isRemoveMode ? Images.minus : Images.plus
            icon.tintColor = accent
        }
        modeLabel.text = isRemoveMode ? "Remove intake" : "Add intake"
        modeLabel.textColor = isRemoveMode ? .systemRed : .label
        logButton.configure(title: isRemoveMode ? "− Remove Intake" : "+ Log Intake")
        logButton.backgroundColor = accent
    }

    @objc
    func handleModeChanged() {
        delegate?.todayView(self, didToggleRemoveMode: modeSwitch.isOn)
    }
}

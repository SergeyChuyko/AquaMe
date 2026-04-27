//
//  SettingsView.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - SettingsViewDelegate

protocol SettingsViewDelegate: AnyObject {

    func settingsView(_ view: SettingsView, didChangeDailyGoal value: Int)
    func settingsView(_ view: SettingsView, didChangeWeight value: Double)
    func settingsView(_ view: SettingsView, didChangeAge value: Int)
    func settingsView(_ view: SettingsView, didChangeUnit unit: UserProfile.MeasureUnit)
    func settingsView(_ view: SettingsView, didToggleReminders isOn: Bool)
    func settingsView(_ view: SettingsView, didChangeReminderTime value: String)
}

// MARK: - SettingsView

final class SettingsView: UIView {

    // MARK: - Private enums

    private enum Constants {

        static let horizontalPadding: CGFloat = 20
        static let sectionSpacing: CGFloat = 24
        static let groupSpacing: CGFloat = 12
        static let columnSpacing: CGFloat = 12
        static let footerFontSize: CGFloat = 11
    }

    private enum Images {

        static let goal = UIImage(systemName: "target")
        static let bell = UIImage(systemName: "bell.fill")
        static let person = UIImage(systemName: "person.fill")
        static let gear = UIImage(systemName: "gearshape.fill")
    }

    // MARK: - Public properties

    weak var delegate: SettingsViewDelegate?

    // MARK: - Private properties

    private var currentUnit: UserProfile.MeasureUnit = .ml

    // MARK: - Private properties

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.keyboardDismissMode = .onDrag

        return view
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = Constants.sectionSpacing

        return stack
    }()

    private lazy var dailyTargetCard: SettingsValueCard = {
        let card = SettingsValueCard()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.delegate = self

        return card
    }()

    private lazy var remindersCard: SettingsRemindersCard = {
        let card = SettingsRemindersCard()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.delegate = self

        return card
    }()

    private lazy var weightCard: SettingsValueCard = {
        let card = SettingsValueCard()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.delegate = self

        return card
    }()

    private lazy var ageCard: SettingsValueCard = {
        let card = SettingsValueCard()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.delegate = self

        return card
    }()

    private lazy var unitToggle: SettingsUnitToggle = {
        let toggle = SettingsUnitToggle()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.delegate = self

        return toggle
    }()

    private lazy var footerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.footerFontSize, weight: .medium)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center

        return label
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - SettingsView + Public

extension SettingsView {

    func update(with state: SettingsState) {
        currentUnit = state.unit
        let unitSuffix = state.unit.rawValue

        dailyTargetCard.configure(
            title: "Daily Target",
            value: state.unit.format(ml: state.dailyGoal),
            suffix: unitSuffix,
            badge: "Recommended: \(formatRecommended(state.recommendedDailyGoal, unit: state.unit))",
            footnote: "Based on your weight and activity level."
        )

        remindersCard.update(enabled: state.remindersEnabled, time: state.reminderStartTime)

        weightCard.configure(
            title: "WEIGHT (\(state.unit.weightLabel))",
            value: state.unit.formatWeight(kg: state.weight),
            suffix: nil,
            badge: nil,
            footnote: nil
        )

        ageCard.configure(
            title: "AGE (YEARS)",
            value: "\(state.age)",
            suffix: nil,
            badge: nil,
            footnote: nil
        )

        unitToggle.update(selected: state.unit, animated: false)

        footerLabel.text = state.appVersion
    }
}

// MARK: - SettingsView + Delegates

extension SettingsView: SettingsValueCardDelegate {

    func valueCard(_ card: SettingsValueCard, didEnter value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        switch card {
        case dailyTargetCard:
            if let parsed = Double(trimmed.replacingOccurrences(of: ",", with: ".")) {
                delegate?.settingsView(self, didChangeDailyGoal: currentUnit.mlValue(from: parsed))
            }

        case weightCard:
            if let parsed = Double(trimmed.replacingOccurrences(of: ",", with: ".")) {
                delegate?.settingsView(self, didChangeWeight: currentUnit.kgValue(from: parsed))
            }

        case ageCard:
            if let parsed = Int(trimmed) {
                delegate?.settingsView(self, didChangeAge: parsed)
            }

        default:
            break
        }
    }
}

extension SettingsView: SettingsRemindersCardDelegate {

    func remindersCard(_ card: SettingsRemindersCard, didToggleEnabled isOn: Bool) {
        delegate?.settingsView(self, didToggleReminders: isOn)
    }

    func remindersCard(_ card: SettingsRemindersCard, didChangeTime value: String) {
        delegate?.settingsView(self, didChangeReminderTime: value)
    }
}

extension SettingsView: SettingsUnitToggleDelegate {

    func unitToggle(_ toggle: SettingsUnitToggle, didSelect unit: UserProfile.MeasureUnit) {
        delegate?.settingsView(self, didChangeUnit: unit)
    }
}

// MARK: - SettingsView + Setup

private extension SettingsView {

    func setup() {
        backgroundColor = .systemBackground
        addSubview(scrollView)
        scrollView.addSubview(contentStack)
        setupContent()
        setupConstraints()
        setupKeyboardDismiss()
    }

    func setupContent() {
        addSection(
            icon: Images.goal,
            title: "Your goal",
            content: [dailyTargetCard]
        )

        addSection(
            icon: Images.bell,
            title: "Reminders",
            content: [remindersCard]
        )

        addSection(
            icon: Images.person,
            title: "Profile details",
            content: [makeRow(views: [weightCard, ageCard])]
        )

        addSection(
            icon: Images.gear,
            title: "Preferences",
            content: [unitToggle]
        )

        let footerWrapper = UIView()
        footerWrapper.addSubview(footerLabel)
        NSLayoutConstraint.activate([
            footerLabel.centerXAnchor.constraint(equalTo: footerWrapper.centerXAnchor),
            footerLabel.topAnchor.constraint(equalTo: footerWrapper.topAnchor, constant: 16),
            footerLabel.bottomAnchor.constraint(equalTo: footerWrapper.bottomAnchor, constant: -8),
        ])
        contentStack.addArrangedSubview(footerWrapper)
    }

    func addSection(icon: UIImage?, title: String, content: [UIView]) {
        let header = SettingsSectionHeader(icon: icon, title: title)
        header.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(header)
        contentStack.setCustomSpacing(Constants.groupSpacing, after: header)
        for view in content {
            contentStack.addArrangedSubview(view)
        }
    }

    func makeRow(views: [UIView]) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = Constants.columnSpacing

        return stack
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

    func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
    }

    func formatRecommended(_ ml: Int, unit: UserProfile.MeasureUnit) -> String {
        switch unit {
        case .ml:
            let liters = Double(ml) / 1000

            return String(format: "%.1fL", liters)

        case .oz:
            return "\(unit.format(ml: ml)) oz"
        }
    }

    @objc
    func handleBackgroundTap() {
        endEditing(true)
    }
}

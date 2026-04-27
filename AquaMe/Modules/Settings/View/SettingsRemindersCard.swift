//
//  SettingsRemindersCard.swift
//  AquaMe
//
//  Created by Friday on 26.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - SettingsRemindersCardDelegate

protocol SettingsRemindersCardDelegate: AnyObject {

    func remindersCard(_ card: SettingsRemindersCard, didToggleEnabled isOn: Bool)
    func remindersCard(_ card: SettingsRemindersCard, didChangeTime value: String)
}

// MARK: - SettingsRemindersCard

/// Карточка с двумя строками: переключатель напоминаний + строка с временем старта.
/// Между строками — тонкая разделительная линия.
final class SettingsRemindersCard: UIView {

    // MARK: - Private enums

    private enum Constants {

        static let cornerRadius: CGFloat = 16
        static let borderWidth: CGFloat = 1
        static let rowHeight: CGFloat = 64
        static let horizontalPadding: CGFloat = 16
        static let titleFontSize: CGFloat = 15
        static let subtitleFontSize: CGFloat = 12
        static let valueFontSize: CGFloat = 14
        static let dividerHeight: CGFloat = 0.5
        static let chevronSize: CGFloat = 12
    }

    private enum Images {

        static let clock = UIImage(systemName: "clock")
        static let chevron = UIImage(systemName: "chevron.right")
    }

    // MARK: - Public properties

    weak var delegate: SettingsRemindersCardDelegate?

    // MARK: - Private properties

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        return formatter
    }()

    private let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        return formatter
    }()

    private lazy var alertsTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.titleFontSize, weight: .semibold)
        label.textColor = .label
        label.text = "Hydration Alerts"

        return label
    }()

    private lazy var alertsSubtitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.subtitleFontSize)
        label.textColor = .secondaryLabel
        label.text = "Get notified to drink water"

        return label
    }()

    private lazy var alertsToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.onTintColor = .systemIndigo
        toggle.addTarget(self, action: #selector(handleToggle), for: .valueChanged)

        return toggle
    }()

    private lazy var clockIconBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.12)
        view.layer.cornerRadius = 16

        let icon = UIImageView(image: Images.clock)
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

        return view
    }()

    private lazy var timeTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.titleFontSize, weight: .semibold)
        label.textColor = .label
        label.text = "Start Reminders at"

        return label
    }()

    private lazy var timeSubtitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.subtitleFontSize)
        label.textColor = .secondaryLabel
        label.text = "Daily starting time"

        return label
    }()

    private lazy var timeValue: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.valueFontSize, weight: .semibold)
        label.textColor = .systemIndigo

        return label
    }()

    private lazy var chevron: UIImageView = {
        let imageView = UIImageView(image: Images.chevron)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .systemIndigo
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    private lazy var timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "en_US_POSIX")
        picker.addTarget(self, action: #selector(handlePickerChanged), for: .valueChanged)

        return picker
    }()

    private lazy var hiddenTimeField: UITextField = {
        let field = UITextField(frame: .zero)
        field.inputView = timePicker
        field.tintColor = .clear
        field.alpha = 0

        return field
    }()

    private lazy var divider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.separator.withAlphaComponent(0.3)

        return view
    }()

    private lazy var timeRow: UIView = {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(clockIconBackground)
        row.addSubview(timeTitle)
        row.addSubview(timeSubtitle)
        row.addSubview(timeValue)
        row.addSubview(chevron)
        row.addSubview(hiddenTimeField)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTimeRowTap))
        row.addGestureRecognizer(tap)
        row.isUserInteractionEnabled = true

        return row
    }()

    private lazy var alertsRow: UIView = {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(alertsTitle)
        row.addSubview(alertsSubtitle)
        row.addSubview(alertsToggle)

        return row
    }()

    // MARK: - Initialization

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - SettingsRemindersCard + Public

extension SettingsRemindersCard {

    func update(enabled: Bool, time: String) {
        if alertsToggle.isOn != enabled {
            alertsToggle.setOn(enabled, animated: false)
        }

        if let date = timeFormatter.date(from: time) {
            timePicker.setDate(date, animated: false)
            timeValue.text = displayFormatter.string(from: date)
        } else {
            timeValue.text = time
        }
    }
}

// MARK: - SettingsRemindersCard + Actions

private extension SettingsRemindersCard {

    @objc
    func handleToggle() {
        delegate?.remindersCard(self, didToggleEnabled: alertsToggle.isOn)
    }

    @objc
    func handleTimeRowTap() {
        hiddenTimeField.becomeFirstResponder()
    }

    @objc
    func handlePickerChanged() {
        let stored = timeFormatter.string(from: timePicker.date)
        timeValue.text = displayFormatter.string(from: timePicker.date)
        delegate?.remindersCard(self, didChangeTime: stored)
    }
}

// MARK: - SettingsRemindersCard + Setup

private extension SettingsRemindersCard {

    func setup() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = Constants.cornerRadius
        layer.borderWidth = Constants.borderWidth
        layer.borderColor = UIColor.separator.withAlphaComponent(0.3).cgColor

        addSubview(alertsRow)
        addSubview(divider)
        addSubview(timeRow)

        NSLayoutConstraint.activate([
            alertsRow.topAnchor.constraint(equalTo: topAnchor),
            alertsRow.leadingAnchor.constraint(equalTo: leadingAnchor),
            alertsRow.trailingAnchor.constraint(equalTo: trailingAnchor),
            alertsRow.heightAnchor.constraint(equalToConstant: Constants.rowHeight),

            divider.topAnchor.constraint(equalTo: alertsRow.bottomAnchor),
            divider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),
            divider.heightAnchor.constraint(equalToConstant: Constants.dividerHeight),

            timeRow.topAnchor.constraint(equalTo: divider.bottomAnchor),
            timeRow.leadingAnchor.constraint(equalTo: leadingAnchor),
            timeRow.trailingAnchor.constraint(equalTo: trailingAnchor),
            timeRow.heightAnchor.constraint(equalToConstant: Constants.rowHeight),
            timeRow.bottomAnchor.constraint(equalTo: bottomAnchor),

            alertsTitle.leadingAnchor.constraint(
                equalTo: alertsRow.leadingAnchor,
                constant: Constants.horizontalPadding
            ),
            alertsTitle.topAnchor.constraint(equalTo: alertsRow.topAnchor, constant: 14),
            alertsSubtitle.leadingAnchor.constraint(equalTo: alertsTitle.leadingAnchor),
            alertsSubtitle.topAnchor.constraint(equalTo: alertsTitle.bottomAnchor, constant: 2),
            alertsToggle.trailingAnchor.constraint(
                equalTo: alertsRow.trailingAnchor,
                constant: -Constants.horizontalPadding
            ),
            alertsToggle.centerYAnchor.constraint(equalTo: alertsRow.centerYAnchor),

            clockIconBackground.leadingAnchor.constraint(
                equalTo: timeRow.leadingAnchor,
                constant: Constants.horizontalPadding
            ),
            clockIconBackground.centerYAnchor.constraint(equalTo: timeRow.centerYAnchor),
            clockIconBackground.widthAnchor.constraint(equalToConstant: 32),
            clockIconBackground.heightAnchor.constraint(equalToConstant: 32),

            timeTitle.leadingAnchor.constraint(equalTo: clockIconBackground.trailingAnchor, constant: 12),
            timeTitle.topAnchor.constraint(equalTo: timeRow.topAnchor, constant: 14),
            timeSubtitle.leadingAnchor.constraint(equalTo: timeTitle.leadingAnchor),
            timeSubtitle.topAnchor.constraint(equalTo: timeTitle.bottomAnchor, constant: 2),

            chevron.trailingAnchor.constraint(
                equalTo: timeRow.trailingAnchor,
                constant: -Constants.horizontalPadding
            ),
            chevron.centerYAnchor.constraint(equalTo: timeRow.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: Constants.chevronSize),
            chevron.heightAnchor.constraint(equalToConstant: Constants.chevronSize),

            timeValue.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),
            timeValue.centerYAnchor.constraint(equalTo: timeRow.centerYAnchor),
        ])
    }
}

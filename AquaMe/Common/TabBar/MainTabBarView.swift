//
//  MainTabBarView.swift
//  AquaMe
//
//  Created by Friday on 28.03.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - MainTabBarViewDelegate

protocol MainTabBarViewDelegate: AnyObject {

    func mainTabBarView(_ view: MainTabBarView, didSelectTab tab: MainTabBarView.Tab)
}

// MARK: - MainTabBarView

/// Плоский плавающий таб-бар: белая плашка со светло-серым бордером, скруглённые углы.
/// Активный таб подсвечен крупным индиго-овалом внутри бара. Без анимации, без выреза —
/// овал просто перепрыгивает к выбранному табу.
final class MainTabBarView: UIView {

    // MARK: - Tab

    enum Tab: Int, CaseIterable {

        case progress = 0
        case today = 1
        case settings = 2
        case profile = 3
    }

    // MARK: - Private enums

    private enum Constants {

        static let barHeight: CGFloat = 64
        static let cornerRadius: CGFloat = 32
        static let borderWidth: CGFloat = 1
        static let indicatorInset: CGFloat = 8
        static let indicatorCornerRadius: CGFloat = 24
        static let iconSize: CGFloat = 22
        static let labelFontSize: CGFloat = 11
        static let animationDuration: TimeInterval = 0.32
    }

    private enum Style {

        static let activeColor = UIColor.systemIndigo
        static let inactiveColor = UIColor.secondaryLabel
        static let barColor = UIColor.systemBackground
        static let borderColor = UIColor.separator.withAlphaComponent(0.4)
    }

    fileprivate struct TabModel {

        let icon: UIImage?
        let title: String
    }

    /// Один таб = его контейнер + иконка + лейбл.
    fileprivate struct TabSlot {

        let container: UIControl
        let iconView: UIImageView
        let label: UILabel
    }

    // MARK: - Public properties

    weak var delegate: MainTabBarViewDelegate?

    // MARK: - Private properties

    private var selectedTab: Tab = .today

    private let tabsByCase: [Tab: TabModel] = [
        .progress: TabModel(icon: UIImage(systemName: "chart.bar.fill"), title: "Progress"),
        .today: TabModel(icon: UIImage(systemName: "drop.fill"), title: "Today"),
        .settings: TabModel(icon: UIImage(systemName: "gearshape.fill"), title: "Settings"),
        .profile: TabModel(icon: UIImage(systemName: "person.fill"), title: "Profile"),
    ]

    private lazy var indicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Style.activeColor
        view.layer.cornerRadius = Constants.indicatorCornerRadius
        view.isUserInteractionEnabled = false

        return view
    }()

    private var indicatorLeading: NSLayoutConstraint?
    private var indicatorTrailing: NSLayoutConstraint?
    private var slots: [Tab: TabSlot] = [:]

    private lazy var tabsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually

        return stack
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: Constants.cornerRadius
        ).cgPath
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyDynamicColors()
    }
}

// MARK: - MainTabBarView + Public

extension MainTabBarView {

    func selectTab(_ tab: Tab) {
        guard tab != selectedTab else { return }

        selectedTab = tab
        moveIndicator(to: tab, animated: true)
        applySelection(to: tab, animated: true)
    }
}

// MARK: - MainTabBarView + Setup

private extension MainTabBarView {

    func setup() {
        backgroundColor = Style.barColor
        layer.cornerRadius = Constants.cornerRadius
        layer.borderWidth = Constants.borderWidth
        layer.borderColor = Style.borderColor.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.10
        layer.shadowRadius = 16
        layer.shadowOffset = CGSize(width: 0, height: 6)

        addSubview(indicatorView)
        setupTabContainers()
        setupIndicatorConstraints()
        applySelection(to: selectedTab, animated: false)
    }

    func setupTabContainers() {
        addSubview(tabsStack)
        NSLayoutConstraint.activate([
            tabsStack.topAnchor.constraint(equalTo: topAnchor),
            tabsStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabsStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            tabsStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        for tab in Tab.allCases {
            guard let model = tabsByCase[tab] else { continue }

            let slot = makeSlot(for: tab, model: model)
            slots[tab] = slot
            tabsStack.addArrangedSubview(slot.container)
        }
    }

    func setupIndicatorConstraints() {
        guard let initialSlot = slots[selectedTab] else { return }

        let leading = indicatorView.leadingAnchor.constraint(
            equalTo: initialSlot.container.leadingAnchor,
            constant: Constants.indicatorInset
        )
        let trailing = indicatorView.trailingAnchor.constraint(
            equalTo: initialSlot.container.trailingAnchor,
            constant: -Constants.indicatorInset
        )
        indicatorLeading = leading
        indicatorTrailing = trailing

        NSLayoutConstraint.activate([
            leading,
            trailing,
            indicatorView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.indicatorInset),
            indicatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.indicatorInset),
        ])
    }

    func makeSlot(for tab: Tab, model: TabModel) -> TabSlot {
        let action = UIAction { [weak self] _ in
            self?.handleTap(on: tab)
        }
        let container = UIControl(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addAction(action, for: .touchUpInside)

        let iconView = UIImageView(image: model.icon)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = Style.inactiveColor
        iconView.contentMode = .scaleAspectFit
        container.addSubview(iconView)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = model.title
        label.font = .systemFont(ofSize: Constants.labelFontSize, weight: .medium)
        label.textColor = Style.inactiveColor
        label.textAlignment = .center
        container.addSubview(label)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            iconView.heightAnchor.constraint(equalToConstant: Constants.iconSize),
            iconView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iconView.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),

            label.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 4),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])

        return TabSlot(container: container, iconView: iconView, label: label)
    }

    func handleTap(on tab: Tab) {
        selectTab(tab)
        delegate?.mainTabBarView(self, didSelectTab: tab)
    }

    func applyDynamicColors() {
        layer.borderColor = Style.borderColor.resolvedColor(with: traitCollection).cgColor
    }
}

// MARK: - MainTabBarView + Indicator

private extension MainTabBarView {

    func moveIndicator(to tab: Tab, animated: Bool) {
        guard let slot = slots[tab],
              let leading = indicatorLeading,
              let trailing = indicatorTrailing else { return }

        NSLayoutConstraint.deactivate([leading, trailing])
        let newLeading = indicatorView.leadingAnchor.constraint(
            equalTo: slot.container.leadingAnchor,
            constant: Constants.indicatorInset
        )
        let newTrailing = indicatorView.trailingAnchor.constraint(
            equalTo: slot.container.trailingAnchor,
            constant: -Constants.indicatorInset
        )
        NSLayoutConstraint.activate([newLeading, newTrailing])
        indicatorLeading = newLeading
        indicatorTrailing = newTrailing

        guard animated else {
            layoutIfNeeded()

            return
        }

        UIView.animate(
            withDuration: Constants.animationDuration,
            delay: 0,
            usingSpringWithDamping: 0.78,
            initialSpringVelocity: 0.4
        ) {
            self.layoutIfNeeded()
        }
    }

    func applySelection(to tab: Tab, animated: Bool) {
        let block: () -> Void = {
            for (slotTab, slot) in self.slots {
                let isSelected = slotTab == tab
                slot.iconView.tintColor = isSelected ? .white : Style.inactiveColor
                slot.label.textColor = isSelected ? .white : Style.inactiveColor
            }
        }

        if animated {
            UIView.transition(
                with: self,
                duration: Constants.animationDuration,
                options: .transitionCrossDissolve,
                animations: block
            )
        } else {
            block()
        }
    }
}

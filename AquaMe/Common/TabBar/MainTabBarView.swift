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
    func mainTabBarViewDidTapProfile(_ view: MainTabBarView)
}

// MARK: - MainTabBarView

/// Кастомный таб-бар: белая плашка с круговым вырезом под активным табом и
/// плавающим индиго-кругом, в котором сидит иконка активного таба.
/// При смене таба круг и вырез скользят с пружинной анимацией.
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
        static let activeRadius: CGFloat = 28
        /// Сколько круг выглядывает над верхней кромкой бара.
        static let activeBumpHeight: CGFloat = 14
        static let cutoutHorizontalCurve: CGFloat = 18
        /// Запас, на который cutout не должен заходить в скруглённый угол.
        static let cutoutCornerPadding: CGFloat = 4
        static let iconSize: CGFloat = 22
        static let activeIconSize: CGFloat = 22
        static let labelFontSize: CGFloat = 11
        static let animationDuration: TimeInterval = 0.32
    }

    private enum Style {

        static let activeColor = UIColor.systemIndigo
        static let inactiveColor = UIColor.secondaryLabel
        static let barColor = UIColor.systemBackground
        static let shadowColor = UIColor.black
    }

    fileprivate struct TabModel {

        let icon: UIImage?
        let title: String
    }

    /// Один таб = его контейнер + иконка + лейбл. Один массив `slots` вместо трёх параллельных.
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

    private let backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: -2)

        return layer
    }()

    private lazy var activeCircle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Style.activeColor
        view.layer.cornerRadius = Constants.activeRadius
        view.isUserInteractionEnabled = false

        return view
    }()

    private lazy var activeIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    private var activeCircleCenterX: NSLayoutConstraint?
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

        backgroundLayer.frame = bounds
        // Constant обновляется без layoutIfNeeded — мы уже внутри layout-pass.
        activeCircleCenterX?.constant = tabCenterX(for: selectedTab)
        let path = barPath(for: selectedTab).cgPath
        backgroundLayer.path = path
        backgroundLayer.shadowPath = path
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
        updateBarPath(animated: true)
        updateCirclePosition(animated: true)
        applySelection(to: tab, animated: true)
    }
}

// MARK: - MainTabBarView + Setup

private extension MainTabBarView {

    func setup() {
        backgroundColor = .clear
        layer.addSublayer(backgroundLayer)
        applyDynamicColors()

        addSubview(activeCircle)
        activeCircle.addSubview(activeIcon)

        NSLayoutConstraint.activate([
            activeCircle.widthAnchor.constraint(equalToConstant: Constants.activeRadius * 2),
            activeCircle.heightAnchor.constraint(equalToConstant: Constants.activeRadius * 2),
            activeCircle.centerYAnchor.constraint(
                equalTo: topAnchor,
                constant: Constants.barHeight / 2 - Constants.activeBumpHeight
            ),

            activeIcon.centerXAnchor.constraint(equalTo: activeCircle.centerXAnchor),
            activeIcon.centerYAnchor.constraint(equalTo: activeCircle.centerYAnchor),
            activeIcon.widthAnchor.constraint(equalToConstant: Constants.activeIconSize),
            activeIcon.heightAnchor.constraint(equalToConstant: Constants.activeIconSize),
        ])

        // Стартовая позиция круга — у активного таба по центру (а не у leading).
        activeIcon.image = tabsByCase[selectedTab]?.icon
        let centerX = activeCircle.centerXAnchor.constraint(equalTo: leadingAnchor)
        centerX.isActive = true
        activeCircleCenterX = centerX

        setupTabContainers()
        applySelection(to: selectedTab, animated: false)
    }

    func setupTabContainers() {
        addSubview(tabsStack)
        NSLayoutConstraint.activate([
            tabsStack.topAnchor.constraint(equalTo: topAnchor),
            tabsStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabsStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            tabsStack.heightAnchor.constraint(equalToConstant: Constants.barHeight),
        ])

        for tab in Tab.allCases {
            guard let model = tabsByCase[tab] else { continue }

            let slot = makeSlot(for: tab, model: model)
            slots[tab] = slot
            tabsStack.addArrangedSubview(slot.container)
        }
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
        if tab == .profile {
            delegate?.mainTabBarViewDidTapProfile(self)

            return
        }

        selectTab(tab)
        delegate?.mainTabBarView(self, didSelectTab: tab)
    }

    func applyDynamicColors() {
        backgroundLayer.fillColor = Style.barColor.resolvedColor(with: traitCollection).cgColor
        backgroundLayer.shadowColor = Style.shadowColor.resolvedColor(with: traitCollection).cgColor
    }
}

// MARK: - MainTabBarView + Path & Animation

private extension MainTabBarView {

    /// X центра таба в баре. Для крайних табов клампим так, чтобы вырез не зашёл в `cornerRadius`.
    func tabCenterX(for tab: Tab) -> CGFloat {
        let tabsCount = CGFloat(Tab.allCases.count)
        let segmentWidth = bounds.width / tabsCount
        let raw = segmentWidth * (CGFloat(tab.rawValue) + 0.5)

        let halfBump = Constants.activeRadius
            + Constants.cutoutHorizontalCurve
            + Constants.cutoutCornerPadding
        let minX = Constants.cornerRadius + halfBump
        let maxX = bounds.width - Constants.cornerRadius - halfBump

        return raw.clamped(to: minX...maxX)
    }

    func updateCirclePosition(animated: Bool) {
        let center = tabCenterX(for: selectedTab)
        activeCircleCenterX?.constant = center

        guard animated else { return }

        UIView.animate(
            withDuration: Constants.animationDuration,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.4
        ) {
            self.layoutIfNeeded()
        }
    }

    func applySelection(to tab: Tab, animated: Bool) {
        activeIcon.image = tabsByCase[tab]?.icon

        let block: () -> Void = {
            for (slotTab, slot) in self.slots {
                let isSelected = slotTab == tab
                slot.iconView.alpha = isSelected ? 0 : 1
                slot.label.alpha = isSelected ? 0 : 1
            }
        }

        if animated {
            UIView.animate(withDuration: Constants.animationDuration, animations: block)
        } else {
            block()
        }
    }

    func updateBarPath(animated: Bool) {
        let path = barPath(for: selectedTab).cgPath

        if animated {
            backgroundLayer.removeAnimation(forKey: "path")
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = backgroundLayer.path
            animation.toValue = path
            animation.duration = Constants.animationDuration
            animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
            backgroundLayer.add(animation, forKey: "path")
        }

        backgroundLayer.path = path
        backgroundLayer.shadowPath = path
    }

    /// Строит путь плашки с круговым вырезом сверху под активный таб.
    /// Все четыре угла скруглены — бар плавающий, а не приклеен к низу экрана.
    func barPath(for tab: Tab) -> UIBezierPath {
        let rect = bounds
        let radius = Constants.cornerRadius
        let cutoutCenterX = tabCenterX(for: tab)
        let cutoutRadius = Constants.activeRadius + 6
        let curveWidth = Constants.cutoutHorizontalCurve

        let path = UIBezierPath()

        // top edge — стартуем после левого верхнего скругления, идём вправо до выреза
        path.move(to: CGPoint(x: radius, y: 0))
        path.addLine(to: CGPoint(x: cutoutCenterX - cutoutRadius - curveWidth, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: cutoutCenterX - cutoutRadius, y: cutoutRadius * 0.55),
            controlPoint: CGPoint(x: cutoutCenterX - cutoutRadius, y: 0)
        )
        path.addArc(
            withCenter: CGPoint(x: cutoutCenterX, y: cutoutRadius * 0.55),
            radius: cutoutRadius,
            startAngle: .pi,
            endAngle: 0,
            clockwise: false
        )
        path.addQuadCurve(
            to: CGPoint(x: cutoutCenterX + cutoutRadius + curveWidth, y: 0),
            controlPoint: CGPoint(x: cutoutCenterX + cutoutRadius, y: 0)
        )
        path.addLine(to: CGPoint(x: rect.width - radius, y: 0))
        // top-right corner
        path.addArc(
            withCenter: CGPoint(x: rect.width - radius, y: radius),
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: 0,
            clockwise: true
        )
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - radius))
        // bottom-right corner
        path.addArc(
            withCenter: CGPoint(x: rect.width - radius, y: rect.height - radius),
            radius: radius,
            startAngle: 0,
            endAngle: .pi / 2,
            clockwise: true
        )
        path.addLine(to: CGPoint(x: radius, y: rect.height))
        // bottom-left corner
        path.addArc(
            withCenter: CGPoint(x: radius, y: rect.height - radius),
            radius: radius,
            startAngle: .pi / 2,
            endAngle: .pi,
            clockwise: true
        )
        path.addLine(to: CGPoint(x: 0, y: radius))
        // top-left corner
        path.addArc(
            withCenter: CGPoint(x: radius, y: radius),
            radius: radius,
            startAngle: .pi,
            endAngle: -.pi / 2,
            clockwise: true
        )
        path.close()

        return path
    }
}

// MARK: - Comparable + Clamp helper

private extension Comparable {

    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

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
        static let cornerRadius: CGFloat = 24
        static let activeRadius: CGFloat = 30
        /// Сколько круг выглядывает над верхней кромкой бара.
        static let activeBumpHeight: CGFloat = 26
        static let cutoutHorizontalCurve: CGFloat = 18
        static let iconSize: CGFloat = 22
        static let activeIconSize: CGFloat = 22
        static let labelFontSize: CGFloat = 11
        static let animationDuration: TimeInterval = 0.32
    }

    private enum Style {

        static let activeColor = UIColor.systemIndigo
        static let inactiveColor = UIColor.secondaryLabel
        static let barColor = UIColor.systemBackground
    }

    private struct TabModel {

        let tab: Tab
        let icon: UIImage?
        let title: String
    }

    // MARK: - Public properties

    weak var delegate: MainTabBarViewDelegate?

    // MARK: - Private properties

    private var selectedTab: Tab = .today

    private let tabs: [TabModel] = [
        TabModel(tab: .progress, icon: UIImage(systemName: "chart.bar.fill"), title: "Progress"),
        TabModel(tab: .today, icon: UIImage(systemName: "drop.fill"), title: "Today"),
        TabModel(tab: .settings, icon: UIImage(systemName: "gearshape.fill"), title: "Settings"),
        TabModel(tab: .profile, icon: UIImage(systemName: "person.fill"), title: "Profile"),
    ]

    private let backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = Style.barColor.cgColor
        layer.shadowColor = UIColor.black.cgColor
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

    private var tabContainers: [UIControl] = []
    private var inactiveIconViews: [UIImageView] = []
    private var inactiveLabels: [UILabel] = []

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
        updateBarPath(animated: false)
        updateCirclePosition(animated: false)
        applySelection(to: selectedTab, animated: false)
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

        let centerX = activeCircle.centerXAnchor.constraint(equalTo: leadingAnchor)
        centerX.isActive = true
        activeCircleCenterX = centerX

        setupTabContainers()
    }

    func setupTabContainers() {
        addSubview(tabsStack)
        NSLayoutConstraint.activate([
            tabsStack.topAnchor.constraint(equalTo: topAnchor),
            tabsStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabsStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            tabsStack.heightAnchor.constraint(equalToConstant: Constants.barHeight),
        ])

        for (index, model) in tabs.enumerated() {
            let container = UIControl()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.tag = index
            container.addTarget(self, action: #selector(handleTabTap(_:)), for: .touchUpInside)
            tabsStack.addArrangedSubview(container)
            tabContainers.append(container)

            let iconView = UIImageView(image: model.icon)
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconView.tintColor = Style.inactiveColor
            iconView.contentMode = .scaleAspectFit
            container.addSubview(iconView)
            inactiveIconViews.append(iconView)

            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = model.title
            label.font = .systemFont(ofSize: Constants.labelFontSize, weight: .medium)
            label.textColor = Style.inactiveColor
            label.textAlignment = .center
            container.addSubview(label)
            inactiveLabels.append(label)

            NSLayoutConstraint.activate([
                iconView.widthAnchor.constraint(equalToConstant: Constants.iconSize),
                iconView.heightAnchor.constraint(equalToConstant: Constants.iconSize),
                iconView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                iconView.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),

                label.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 4),
                label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            ])
        }
    }

    @objc
    func handleTabTap(_ sender: UIControl) {
        guard let tab = Tab(rawValue: sender.tag) else { return }

        selectTab(tab)
        delegate?.mainTabBarView(self, didSelectTab: tab)
    }
}

// MARK: - MainTabBarView + Path & Animation

private extension MainTabBarView {

    func tabCenterX(for tab: Tab) -> CGFloat {
        let segmentWidth = bounds.width / CGFloat(tabs.count)

        return segmentWidth * (CGFloat(tab.rawValue) + 0.5)
    }

    func updateCirclePosition(animated: Bool) {
        let center = tabCenterX(for: selectedTab)
        activeCircleCenterX?.constant = center

        if animated {
            UIView.animate(
                withDuration: Constants.animationDuration,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.4
            ) {
                self.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
    }

    func applySelection(to tab: Tab, animated: Bool) {
        activeIcon.image = tabs[tab.rawValue].icon

        for (index, iconView) in inactiveIconViews.enumerated() {
            let isSelected = index == tab.rawValue
            iconView.alpha = isSelected ? 0 : 1
            inactiveLabels[index].alpha = isSelected ? 0 : 1
        }
    }

    func updateBarPath(animated: Bool) {
        let path = barPath(for: selectedTab).cgPath

        if animated {
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = backgroundLayer.path
            animation.toValue = path
            animation.duration = Constants.animationDuration
            animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
            backgroundLayer.add(animation, forKey: "path")
        }

        backgroundLayer.path = path
        backgroundLayer.frame = bounds
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


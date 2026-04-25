//
//  TodayProgressRingView.swift
//  AquaMe
//
//  Created by Friday on 25.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - TodayProgressRingView

/// Круговой индикатор дневного прогресса по воде с градиентной заливкой и центральной подписью.
final class TodayProgressRingView: UIView {

    // MARK: - Private enums

    private enum Constants {

        static let lineWidth: CGFloat = 14
        static let trackAlpha: CGFloat = 0.12
        static let startAngle: CGFloat = -.pi / 2
        static let animationDuration: CFTimeInterval = 0.45
        static let dropSize: CGFloat = 22
        static let valueFontSize: CGFloat = 44
        static let unitFontSize: CGFloat = 16
        static let badgeFontSize: CGFloat = 12
        static let badgeHeight: CGFloat = 22
        static let dropToValueSpacing: CGFloat = 6
        static let valueToBadgeSpacing: CGFloat = 10
        static let badgeMinWidth: CGFloat = 88
    }

    private enum Images {

        static let drop = UIImage(systemName: "drop.fill")
    }

    // MARK: - Public properties

    /// Текущий прогресс в диапазоне 0...1.
    private(set) var progress: Double = 0

    // MARK: - Private properties

    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()

    private lazy var dropImageView: UIImageView = {
        let imageView = UIImageView(image: Images.drop)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemIndigo

        return imageView
    }()

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.valueFontSize, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6

        return label
    }()

    private lazy var unitLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.unitFontSize, weight: .medium)
        label.textColor = .secondaryLabel

        return label
    }()

    private lazy var valueStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [valueLabel, unitLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .lastBaseline
        stack.spacing = 4

        return stack
    }()

    private lazy var percentBadge: PaddedLabel = {
        let label = PaddedLabel(insets: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.badgeFontSize, weight: .semibold)
        label.textColor = .systemIndigo
        label.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.12)
        label.textAlignment = .center
        label.layer.cornerRadius = Constants.badgeHeight / 2
        label.layer.masksToBounds = true

        return label
    }()

    private lazy var centerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [dropImageView, valueStack, percentBadge])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = Constants.valueToBadgeSpacing
        stack.setCustomSpacing(Constants.dropToValueSpacing, after: dropImageView)

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
        let rect = bounds
        let radius = (min(rect.width, rect.height) - Constants.lineWidth) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: Constants.startAngle,
            endAngle: Constants.startAngle + 2 * .pi,
            clockwise: true
        )
        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
        gradientLayer.frame = rect
    }
}

// MARK: - TodayProgressRingView + Public

extension TodayProgressRingView {

    func update(progress: Double, valueText: String, unitText: String, percentText: String) {
        let clamped = max(0, min(1, progress))
        valueLabel.text = valueText
        unitLabel.text = unitText
        percentBadge.text = percentText
        animateProgress(to: clamped)
    }
}

// MARK: - TodayProgressRingView + Setup

private extension TodayProgressRingView {

    func setup() {
        backgroundColor = .clear
        setupLayers()
        setupSubviews()
        setupConstraints()
    }

    func setupLayers() {
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.systemIndigo.withAlphaComponent(Constants.trackAlpha).cgColor
        trackLayer.lineWidth = Constants.lineWidth
        layer.addSublayer(trackLayer)

        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.black.cgColor
        progressLayer.lineWidth = Constants.lineWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0

        gradientLayer.colors = [
            UIColor.systemIndigo.cgColor,
            UIColor.systemPurple.cgColor,
            UIColor.systemPink.cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.mask = progressLayer
        layer.addSublayer(gradientLayer)
    }

    func setupSubviews() {
        addSubview(centerStack)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            centerStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            centerStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
            centerStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24),

            dropImageView.widthAnchor.constraint(equalToConstant: Constants.dropSize),
            dropImageView.heightAnchor.constraint(equalToConstant: Constants.dropSize),

            percentBadge.heightAnchor.constraint(equalToConstant: Constants.badgeHeight),
            percentBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.badgeMinWidth),
        ])
    }

    func animateProgress(to value: Double) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = progress
        animation.toValue = value
        animation.duration = Constants.animationDuration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        progressLayer.strokeEnd = CGFloat(value)
        progressLayer.add(animation, forKey: "progress")
        progress = value
    }
}

// MARK: - PaddedLabel

/// UILabel с произвольными внутренними отступами.
/// Используется для пилюли «50% OF GOAL» внутри кольца — у системного UILabel нет insets из коробки.
final class PaddedLabel: UILabel {

    // MARK: - Public properties

    var insets: UIEdgeInsets

    // MARK: - Initialization

    init(insets: UIEdgeInsets) {
        self.insets = insets
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Layout

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + insets.left + insets.right,
            height: size.height + insets.top + insets.bottom
        )
    }
}


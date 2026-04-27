//
//  GreetingView.swift
//  AquaMe
//
//  Created by Sergey on 30.03.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - GreetingViewDelegate

/// Сообщает контроллеру о действиях пользователя на экране приветствия.
protocol GreetingViewDelegate: AnyObject {

    func greetingViewDidTapNext(_ view: GreetingView)
    func greetingViewDidTapCamera(_ view: GreetingView)
    func greetingViewDidTapLogout(_ view: GreetingView)
    func greetingViewDidTapBack(_ view: GreetingView)
}

// MARK: - GreetingView

/// Вью первого экрана онбординга — пользователь заполняет фото, имя, возраст и вес.
final class GreetingView: UIView {

    // MARK: - Private enums

    private enum Constants {

        static let profileImageSize: CGFloat = 120
        static let profileImageCornerRadius: CGFloat = profileImageSize / 2
        static let profileImageTopOffset: CGFloat = 70
        static let dashedBorderSize: CGFloat = 134
        static let dashedBorderLineWidth: CGFloat = 2
        static let dashedBorderDash: CGFloat = 6
        static let dashedBorderGap: CGFloat = 4
        static let cameraButtonSize: CGFloat = 40
        static let cameraButtonCornerRadius: CGFloat = 20
        static let cameraButtonOffset: CGFloat = 4
        static let uploadPhotoFontSize: CGFloat = 14
        static let uploadPhotoTopSpacing: CGFloat = 20
        static let nameInputTopSpacing: CGFloat = 52
        static let curveStackSpacing: CGFloat = 12
        static let curveStackTopSpacing: CGFloat = 24
        static let curveStackBottomSpacing: CGFloat = 32
        static let nextButtonSpacing: CGFloat = 12
        static let sidePadding: CGFloat = 16
    }

    private enum Strings {

        static let navigationTitle = "Profile Setup"
        static let uploadPhoto = "TAP TO UPLOAD PHOTO"
        static let nextButton = "Next"
    }

    // MARK: - Public properties

    weak var delegate: GreetingViewDelegate?

    var name: String? { nameInput.text }
    var age: String? { ageInput.text }
    var weight: String? { weightInput.text }

    func setProfileImage(_ image: UIImage) {
        profileImageView.image = image
        profileImageView.contentMode = .scaleAspectFill
    }

    func showBackButton() {
        navigationBar.configure(
            title: Strings.navigationTitle,
            leftIcon: UIImage(systemName: "chevron.left")
        )
        navigationBar.onTapLeft = { [weak self] in
            guard let self else { return }

            handleBackTap()
        }
    }

    func configure(name: String, age: Int, weight: Double, avatarPath: String?) {
        nameInput.text = name
        ageInput.text = "\(age)"
        weightInput.text = "\(Int(weight))"
        updateNextButtonState()

        guard let avatarPath else { return }

        let url = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent(avatarPath)

        if let image = UIImage(contentsOfFile: url.path) {
            setProfileImage(image)
        }
    }

    // MARK: - Private properties

    private lazy var navigationBar: CUINavigationBar = {
        let bar = CUINavigationBar(
            title: Strings.navigationTitle,
            rightIcon: UIImage(systemName: "rectangle.portrait.and.arrow.right")
        )
        bar.rightButtonTintColor = .systemRed
        bar.onTapRight = { [weak self] in
            guard let self else { return }
            handleLogoutTap()
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

    private lazy var dashedBorderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear

        return view
    }()

    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.1)
        imageView.layer.cornerRadius = Constants.profileImageCornerRadius
        imageView.clipsToBounds = true

        return imageView
    }()

    private lazy var cameraButton: UIButton = {
        let action = UIAction { [weak self] _ in
            guard let self else { return }
            handleAddPhotoTap()
        }
        let button = UIButton(primaryAction: action)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemIndigo
        button.layer.cornerRadius = Constants.cameraButtonCornerRadius
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        button.setImage(UIImage(systemName: "camera.fill", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit

        return button
    }()

    private lazy var uploadPhotoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Strings.uploadPhoto
        label.font = .systemFont(ofSize: Constants.uploadPhotoFontSize)
        label.textColor = .gray

        return label
    }()

    private lazy var nameInput: CUITextField = {
        let input = CUITextField(title: "Full Name", placeholder: "Your Name")
        input.translatesAutoresizingMaskIntoConstraints = false
        input.returnKeyType = .done
        input.onReturn = { [weak self] in
            guard let self else { return }
            endEditing(true)
        }
        input.onTextChange = { [weak self] _ in
            guard let self else { return }
            updateNextButtonState()
        }

        return input
    }()

    private lazy var ageInput: CUITextField = {
        let input = CUITextField(title: "Age", placeholder: "25", suffix: "years")
        input.translatesAutoresizingMaskIntoConstraints = false
        input.keyboardType = .numberPad
        input.onTextChange = { [weak self] _ in
            guard let self else { return }
            updateNextButtonState()
        }

        return input
    }()

    private lazy var weightInput: CUITextField = {
        let input = CUITextField(title: "Weight", placeholder: "75", suffix: "kg")
        input.translatesAutoresizingMaskIntoConstraints = false
        input.keyboardType = .numberPad
        input.onTextChange = { [weak self] _ in
            guard let self else { return }
            updateNextButtonState()
        }

        return input
    }()

    private lazy var curveStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [ageInput, weightInput])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = Constants.curveStackSpacing

        return stack
    }()

    private lazy var nextButton: CUIButton = {
        let button = CUIButton(title: Strings.nextButton)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.onTap = { [weak self] in
            guard let self else { return }
            delegate?.greetingViewDidTapNext(self)
        }

        return button
    }()

    private var nextButtonBottomConstraint: NSLayoutConstraint?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - GreetingView + Actions

private extension GreetingView {

    func handleBackTap() {
        delegate?.greetingViewDidTapBack(self)
    }

    func handleLogoutTap() {
        delegate?.greetingViewDidTapLogout(self)
    }

    @objc func handleAddPhotoTap() {
        print("ты нажал добавить фото")
        delegate?.greetingViewDidTapCamera(self)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        guard
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else {

            return
        }

        nextButtonBottomConstraint?.isActive = false
        let constraint = nextButton.bottomAnchor.constraint(
            equalTo: bottomAnchor,
            constant: -(keyboardFrame.height + 8)
        )
        constraint.isActive = true
        nextButtonBottomConstraint = constraint

        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
        } completion: { _ in
            self.scrollToActiveInput()
        }
    }

    func updateNextButtonState() {
        let allFilled = [nameInput, ageInput, weightInput].allSatisfy {
            !($0.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty
        }

        nextButton.isEnabled = allFilled
    }

    func scrollToActiveInput() {
        let inputs: [CUITextField] = [nameInput, ageInput, weightInput]

        guard let active = inputs.first(where: { $0.isEditing }) else {

            return
        }

        let rect = active.convert(active.bounds, to: contentView)
        scrollView.scrollRectToVisible(rect.insetBy(dx: 0, dy: -16), animated: true)
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else {

            return
        }

        nextButtonBottomConstraint?.isActive = false
        let constraint = nextButton.bottomAnchor.constraint(
            equalTo: safeAreaLayoutGuide.bottomAnchor,
            constant: -Constants.nextButtonSpacing
        )
        constraint.isActive = true
        nextButtonBottomConstraint = constraint

        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
        }
    }
}

// MARK: - GreetingView + Setup

private extension GreetingView {

    func setup() {
        setupViews()
        setupConstraints()
        setupDashedBorder()
        setupGestures()
        setupKeyboardObservers()
        updateNextButtonState()
    }

    func setupViews() {
        backgroundColor = .white
        addSubview(navigationBar)
        addSubview(nextButton)
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(dashedBorderView)
        contentView.addSubview(profileImageView)
        contentView.addSubview(cameraButton)
        contentView.addSubview(uploadPhotoLabel)
        contentView.addSubview(nameInput)
        contentView.addSubview(curveStack)
    }

    func setupConstraints() {
        setupConstraintsForNavigationBar()
        setupConstraintsForNextButton()
        setupConstraintsForScrollView()
        setupConstraintsForContentView()
        setupConstraintsForDashedBorderView()
        setupConstraintsForProfileImageView()
        setupConstraintsForCameraButton()
        setupConstraintsForUploadPhotoLabel()
        setupConstraintsForNameInput()
        setupConstraintsForCurveStack()
    }

    func setupConstraintsForNavigationBar() {
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    func setupConstraintsForNextButton() {
        let bottomConstraint = nextButton.bottomAnchor.constraint(
            equalTo: safeAreaLayoutGuide.bottomAnchor,
            constant: -Constants.nextButtonSpacing
        )
        bottomConstraint.isActive = true
        nextButtonBottomConstraint = bottomConstraint

        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Constants.sidePadding
            ),
            nextButton.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Constants.sidePadding
            ),
        ])
    }

    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    func setupConstraintsForScrollView() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: nextButton.topAnchor),
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

    func setupConstraintsForDashedBorderView() {
        NSLayoutConstraint.activate([
            dashedBorderView.widthAnchor.constraint(equalToConstant: Constants.dashedBorderSize),
            dashedBorderView.heightAnchor.constraint(equalToConstant: Constants.dashedBorderSize),
            dashedBorderView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dashedBorderView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.profileImageTopOffset - (Constants.dashedBorderSize - Constants.profileImageSize) / 2
            ),
        ])
    }

    func setupConstraintsForProfileImageView() {
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: Constants.profileImageSize),
            profileImageView.heightAnchor.constraint(equalToConstant: Constants.profileImageSize),
            profileImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.profileImageTopOffset
            ),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }

    func setupConstraintsForCameraButton() {
        NSLayoutConstraint.activate([
            cameraButton.widthAnchor.constraint(equalToConstant: Constants.cameraButtonSize),
            cameraButton.heightAnchor.constraint(equalToConstant: Constants.cameraButtonSize),
            cameraButton.trailingAnchor.constraint(
                equalTo: profileImageView.trailingAnchor,
                constant: Constants.cameraButtonOffset
            ),
            cameraButton.bottomAnchor.constraint(
                equalTo: profileImageView.bottomAnchor,
                constant: Constants.cameraButtonOffset
            ),
        ])
    }

    func setupConstraintsForUploadPhotoLabel() {
        NSLayoutConstraint.activate([
            uploadPhotoLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            uploadPhotoLabel.topAnchor.constraint(
                equalTo: profileImageView.bottomAnchor,
                constant: Constants.uploadPhotoTopSpacing
            ),
        ])
    }

    func setupConstraintsForNameInput() {
        NSLayoutConstraint.activate([
            nameInput.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.sidePadding
            ),
            nameInput.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.sidePadding
            ),
            nameInput.topAnchor.constraint(
                equalTo: uploadPhotoLabel.bottomAnchor,
                constant: Constants.nameInputTopSpacing
            ),
        ])
    }

    func setupConstraintsForCurveStack() {
        NSLayoutConstraint.activate([
            curveStack.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.sidePadding
            ),
            curveStack.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.sidePadding
            ),
            curveStack.topAnchor.constraint(
                equalTo: nameInput.bottomAnchor,
                constant: Constants.curveStackTopSpacing
            ),
            curveStack.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Constants.curveStackBottomSpacing
            ),
        ])
    }

    func setupDashedBorder() {
        let shapeLayer = CAShapeLayer()
        let size = Constants.dashedBorderSize
        let rect = CGRect(x: 0, y: 0, width: size, height: size)
        shapeLayer.path = UIBezierPath(ovalIn: rect).cgPath
        shapeLayer.strokeColor = UIColor.systemIndigo.withAlphaComponent(0.5).cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = Constants.dashedBorderLineWidth
        shapeLayer.lineDashPattern = [
            NSNumber(value: Constants.dashedBorderDash),
            NSNumber(value: Constants.dashedBorderGap),
        ]
        dashedBorderView.layer.addSublayer(shapeLayer)
    }

    func setupGestures() {
        let photoViews: [UIView] = [dashedBorderView, profileImageView, uploadPhotoLabel]

        photoViews.forEach { view in
            view.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleAddPhotoTap))
            view.addGestureRecognizer(tap)
        }
    }
}

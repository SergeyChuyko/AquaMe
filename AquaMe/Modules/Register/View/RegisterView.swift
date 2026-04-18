//
//  RegisterView.swift
//  AquaMe
//
//  Created by Sergey on 04.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - RegisterViewDelegate

protocol RegisterViewDelegate: AnyObject {

    func registerViewDidTapBack(_ view: RegisterView)
    func registerViewDidTapRegister(_ view: RegisterView)
    func registerViewDidTapLogin(_ view: RegisterView)
    func registerViewDidTapApple(_ view: RegisterView)
    func registerViewDidTapGoogle(_ view: RegisterView)
}

// MARK: - RegisterView

final class RegisterView: UIView {

    // MARK: - Private enums

    private enum Constants {

        static let navBarHeight: CGFloat = 44
        static let logoIconSize: CGFloat = 36
        static let logoIconCornerRadius: CGFloat = 10
        static let logoSymbolSize: CGFloat = 18
        static let logoSpacing: CGFloat = 8
        static let logoTopSpacing: CGFloat = 16
        static let titleFontSize: CGFloat = 28
        static let titleTopSpacing: CGFloat = 20
        static let subtitleFontSize: CGFloat = 16
        static let subtitleTopSpacing: CGFloat = 8
        static let emailTopSpacing: CGFloat = 32
        static let fieldSpacing: CGFloat = 20
        static let createButtonTopSpacing: CGFloat = 32
        static let loginLabelTopSpacing: CGFloat = 20
        static let orDividerTopSpacing: CGFloat = 20
        static let orDividerFontSize: CGFloat = 12
        static let orDividerLineHeight: CGFloat = 1
        static let socialButtonTopSpacing: CGFloat = 16
        static let socialButtonHeight: CGFloat = 56
        static let socialButtonsSpacing: CGFloat = 12
        static let agreementTopSpacing: CGFloat = 16
        static let agreementBottomSpacing: CGFloat = 32
        static let agreementFontSize: CGFloat = 13
        static let loginFontSize: CGFloat = 15
        static let sidePadding: CGFloat = 16
    }

    private enum Strings {

        static let title = "Create Account"
        static let subtitle = "Start your journey to the perfect water balance today."
        static let appName = "AquaMe"
        static let emailTitle = "Email"
        static let emailPlaceholder = "example@mail.com"
        static let passwordTitle = "Password"
        static let passwordPlaceholder = "Password"
        static let confirmTitle = "Confirm password"
        static let confirmPlaceholder = "Repeat password"
        static let createButton = "Create Account"
        static let alreadyHave = "Already have an account? "
        static let signIn = "Sign In"
        static let orThrough = "OR CONTINUE WITH"
        static let agreementPrefix = "By tapping «Create Account», you agree to our "
        static let agreementTerms = "Terms of Service"
        static let agreementAnd = " and "
        static let agreementPrivacy = "Privacy Policy"
    }

    // MARK: - Public properties

    weak var delegate: RegisterViewDelegate?

    // MARK: - Private properties

    private lazy var navigationBar: CUINavigationBar = {
        let bar = CUINavigationBar(
            title: "",
            leftIcon: UIImage(systemName: "chevron.left")
        )
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.onTapLeft = { [weak self] in
            guard let self else { return }
            delegate?.registerViewDidTapBack(self)
        }

        return bar
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.alwaysBounceVertical = false

        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var logoContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemIndigo
        view.layer.cornerRadius = Constants.logoIconCornerRadius

        return view
    }()

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: Constants.logoSymbolSize, weight: .medium)
        imageView.image = UIImage(systemName: "drop.fill", withConfiguration: config)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    private lazy var appNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Strings.appName
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .label

        return label
    }()

    private lazy var logoRowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(logoContainerView)
        view.addSubview(appNameLabel)

        NSLayoutConstraint.activate([
            logoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            logoContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            logoContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            logoContainerView.widthAnchor.constraint(equalToConstant: Constants.logoIconSize),
            logoContainerView.heightAnchor.constraint(equalToConstant: Constants.logoIconSize),

            logoImageView.centerXAnchor.constraint(equalTo: logoContainerView.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: logoContainerView.centerYAnchor),

            appNameLabel.leadingAnchor.constraint(
                equalTo: logoContainerView.trailingAnchor,
                constant: Constants.logoSpacing
            ),
            appNameLabel.centerYAnchor.constraint(equalTo: logoContainerView.centerYAnchor),
            appNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Strings.title
        label.font = .boldSystemFont(ofSize: Constants.titleFontSize)
        label.textColor = .label
        label.numberOfLines = 0

        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Strings.subtitle
        label.font = .systemFont(ofSize: Constants.subtitleFontSize)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0

        return label
    }()

    private lazy var emailInput: CUITextField = {
        let input = CUITextField(
            title: Strings.emailTitle,
            placeholder: Strings.emailPlaceholder,
            leftIcon: UIImage(systemName: "envelope")
        )
        input.translatesAutoresizingMaskIntoConstraints = false
        input.keyboardType = .emailAddress
        input.returnKeyType = .next
        input.onReturn = { [weak self] in
            self?.passwordInput.focus()
        }

        return input
    }()

    private lazy var passwordInput: CUITextField = {
        let input = CUITextField(
            title: Strings.passwordTitle,
            placeholder: Strings.passwordPlaceholder,
            leftIcon: UIImage(systemName: "lock")
        )
        input.translatesAutoresizingMaskIntoConstraints = false
        input.returnKeyType = .next
        input.onReturn = { [weak self] in
            self?.confirmPasswordInput.focus()
        }

        return input
    }()

    private lazy var confirmPasswordInput: CUITextField = {
        let input = CUITextField(
            title: Strings.confirmTitle,
            placeholder: Strings.confirmPlaceholder,
            leftIcon: UIImage(systemName: "shield")
        )
        input.translatesAutoresizingMaskIntoConstraints = false
        input.returnKeyType = .done
        input.onReturn = { [weak self] in
            self?.endEditing(true)
        }

        return input
    }()

    private lazy var createButton: CUIButton = {
        let button = CUIButton(title: Strings.createButton)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.onTap = { [weak self] in
            guard let self else { return }
            print("tapped create account")
            delegate?.registerViewDidTapRegister(self)
        }

        return button
    }()

    private lazy var loginLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.isUserInteractionEnabled = true

        let prefix = NSAttributedString(
            string: Strings.alreadyHave,
            attributes: [
                .foregroundColor: UIColor.secondaryLabel,
                .font: UIFont.systemFont(ofSize: Constants.loginFontSize),
            ]
        )
        let link = NSAttributedString(
            string: Strings.signIn,
            attributes: [
                .foregroundColor: UIColor.systemIndigo,
                .font: UIFont.systemFont(ofSize: Constants.loginFontSize),
            ]
        )
        let attributed = NSMutableAttributedString()
        attributed.append(prefix)
        attributed.append(link)
        label.attributedText = attributed

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleLoginTap))
        label.addGestureRecognizer(tap)

        return label
    }()

    private lazy var orDividerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let leftLine = UIView()
        leftLine.translatesAutoresizingMaskIntoConstraints = false
        leftLine.backgroundColor = .systemGray4

        let rightLine = UIView()
        rightLine.translatesAutoresizingMaskIntoConstraints = false
        rightLine.backgroundColor = .systemGray4

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Strings.orThrough
        label.font = .systemFont(ofSize: Constants.orDividerFontSize)
        label.textColor = .secondaryLabel

        view.addSubview(leftLine)
        view.addSubview(label)
        view.addSubview(rightLine)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            leftLine.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -12),
            leftLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leftLine.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            leftLine.heightAnchor.constraint(equalToConstant: Constants.orDividerLineHeight),

            rightLine.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 12),
            rightLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rightLine.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            rightLine.heightAnchor.constraint(equalToConstant: Constants.orDividerLineHeight),
        ])

        return view
    }()

    private lazy var appleButton: CUISocialButton = {
        let button = CUISocialButton(provider: .apple)
        button.onTap = { [weak self] in
            guard let self else { return }
            print("tapped continue with Apple")
            delegate?.registerViewDidTapApple(self)
        }

        return button
    }()

    private lazy var googleButton: CUISocialButton = {
        let button = CUISocialButton(provider: .google)
        button.onTap = { [weak self] in
            guard let self else { return }
            print("tapped continue with Google")
            delegate?.registerViewDidTapGoogle(self)
        }

        return button
    }()

    private lazy var socialButtonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [appleButton, googleButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = Constants.socialButtonsSpacing
        stack.distribution = .fillEqually

        return stack
    }()

    private lazy var agreementLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center

        label.isUserInteractionEnabled = true

        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.secondaryLabel,
            .font: UIFont.systemFont(ofSize: Constants.agreementFontSize),
        ]
        let indigoAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemIndigo,
            .font: UIFont.systemFont(ofSize: Constants.agreementFontSize),
        ]

        let attributed = NSMutableAttributedString()
        attributed.append(NSAttributedString(string: Strings.agreementPrefix, attributes: attrs))
        attributed.append(NSAttributedString(string: Strings.agreementTerms, attributes: indigoAttrs))
        attributed.append(NSAttributedString(string: Strings.agreementAnd, attributes: attrs))
        attributed.append(NSAttributedString(string: Strings.agreementPrivacy, attributes: indigoAttrs))
        label.attributedText = attributed

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleAgreementTap))
        label.addGestureRecognizer(tap)

        return label
    }()

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

// MARK: - RegisterView + Actions

private extension RegisterView {

    @objc func handleLoginTap() {
        delegate?.registerViewDidTapLogin(self)
    }

    @objc func handleAgreementTap() {
        print("tapped agreement on register screen")
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        guard
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else {

            return
        }

        scrollView.contentInset.bottom = keyboardFrame.height
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardFrame.height

        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
        } completion: { _ in
            self.scrollToActiveInput()
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else {

            return
        }

        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0

        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
        }
    }

    func scrollToActiveInput() {
        let inputs: [CUITextField] = [emailInput, passwordInput, confirmPasswordInput]

        guard let active = inputs.first(where: { $0.isEditing }) else {

            return
        }

        let rect = active.convert(active.bounds, to: contentView)
        scrollView.scrollRectToVisible(rect.insetBy(dx: 0, dy: -16), animated: true)
    }
}

// MARK: - RegisterView + Setup

private extension RegisterView {

    func setup() {
        setupViews()
        setupConstraints()
        setupKeyboardObservers()
    }

    func setupViews() {
        backgroundColor = .white
        addSubview(navigationBar)
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        logoContainerView.addSubview(logoImageView)
        contentView.addSubview(logoRowView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(emailInput)
        contentView.addSubview(passwordInput)
        contentView.addSubview(confirmPasswordInput)
        contentView.addSubview(createButton)
        contentView.addSubview(loginLabel)
        contentView.addSubview(orDividerView)
        contentView.addSubview(socialButtonsStackView)
        contentView.addSubview(agreementLabel)
    }

    func setupConstraints() {
        setupConstraintsForNavigationBar()
        setupConstraintsForScrollView()
        setupConstraintsForContentView()
        setupConstraintsForLogoRow()
        setupConstraintsForTitleLabel()
        setupConstraintsForSubtitleLabel()
        setupConstraintsForEmailInput()
        setupConstraintsForPasswordInput()
        setupConstraintsForConfirmPasswordInput()
        setupConstraintsForCreateButton()
        setupConstraintsForLoginLabel()
        setupConstraintsForOrDivider()
        setupConstraintsForSocialButtons()
        setupConstraintsForAgreementLabel()
    }

    func setupConstraintsForNavigationBar() {
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    func setupConstraintsForScrollView() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
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

    func setupConstraintsForLogoRow() {
        NSLayoutConstraint.activate([
            logoRowView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.logoTopSpacing
            ),
            logoRowView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }

    func setupConstraintsForTitleLabel() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: logoRowView.bottomAnchor,
                constant: Constants.titleTopSpacing
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.sidePadding
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.sidePadding
            ),
        ])
    }

    func setupConstraintsForSubtitleLabel() {
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: Constants.subtitleTopSpacing
            ),
            subtitleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.sidePadding
            ),
            subtitleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.sidePadding
            ),
        ])
    }

    func setupConstraintsForEmailInput() {
        NSLayoutConstraint.activate([
            emailInput.topAnchor.constraint(
                equalTo: subtitleLabel.bottomAnchor,
                constant: Constants.emailTopSpacing
            ),
            emailInput.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.sidePadding
            ),
            emailInput.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.sidePadding
            ),
        ])
    }

    func setupConstraintsForPasswordInput() {
        NSLayoutConstraint.activate([
            passwordInput.topAnchor.constraint(
                equalTo: emailInput.bottomAnchor,
                constant: Constants.fieldSpacing
            ),
            passwordInput.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.sidePadding
            ),
            passwordInput.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.sidePadding
            ),
        ])
    }

    func setupConstraintsForConfirmPasswordInput() {
        NSLayoutConstraint.activate([
            confirmPasswordInput.topAnchor.constraint(
                equalTo: passwordInput.bottomAnchor,
                constant: Constants.fieldSpacing
            ),
            confirmPasswordInput.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.sidePadding
            ),
            confirmPasswordInput.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.sidePadding
            ),
        ])
    }

    func setupConstraintsForCreateButton() {
        NSLayoutConstraint.activate([
            createButton.topAnchor.constraint(
                equalTo: confirmPasswordInput.bottomAnchor,
                constant: Constants.createButtonTopSpacing
            ),
            createButton.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.sidePadding
            ),
            createButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.sidePadding
            ),
        ])
    }

    func setupConstraintsForLoginLabel() {
        NSLayoutConstraint.activate([
            loginLabel.topAnchor.constraint(
                equalTo: createButton.bottomAnchor,
                constant: Constants.loginLabelTopSpacing
            ),
            loginLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.sidePadding
            ),
            loginLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.sidePadding
            ),
        ])
    }

    func setupConstraintsForOrDivider() {
        NSLayoutConstraint.activate([
            orDividerView.topAnchor.constraint(
                equalTo: loginLabel.bottomAnchor,
                constant: Constants.orDividerTopSpacing
            ),
            orDividerView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.sidePadding
            ),
            orDividerView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.sidePadding
            ),
        ])
    }

    func setupConstraintsForSocialButtons() {
        NSLayoutConstraint.activate([
            socialButtonsStackView.topAnchor.constraint(
                equalTo: orDividerView.bottomAnchor,
                constant: Constants.socialButtonTopSpacing
            ),
            socialButtonsStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.sidePadding
            ),
            socialButtonsStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.sidePadding
            ),
            socialButtonsStackView.heightAnchor.constraint(equalToConstant: Constants.socialButtonHeight),
        ])
    }

    func setupConstraintsForAgreementLabel() {
        NSLayoutConstraint.activate([
            agreementLabel.topAnchor.constraint(
                equalTo: socialButtonsStackView.bottomAnchor,
                constant: Constants.agreementTopSpacing
            ),
            agreementLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.sidePadding
            ),
            agreementLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.sidePadding
            ),
            agreementLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Constants.agreementBottomSpacing
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
}

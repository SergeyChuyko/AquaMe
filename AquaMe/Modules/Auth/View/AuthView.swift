//
//  AuthView.swift
//  AquaMe
//
//  Created by Sergey on 04.04.2026.
//  Copyright © 2026. All rights reserved.
//

import UIKit

// MARK: - AuthViewDelegate

protocol AuthViewDelegate: AnyObject {

    func authViewDidTapLogin(_ view: AuthView)
    func authViewDidTapForgotPassword(_ view: AuthView)
    func authViewDidTapApple(_ view: AuthView)
    func authViewDidTapGoogle(_ view: AuthView)
    func authViewDidTapRegister(_ view: AuthView)
}

// MARK: - AuthView

/// Вью экрана авторизации — email/пароль, соц кнопки, переход на регистрацию.
final class AuthView: UIView {

    // MARK: - Private enums

    private enum Constants {

        static let logoSize: CGFloat = 80
        static let logoCornerRadius: CGFloat = 40
        static let logoIconSize: CGFloat = 36
        static let logoTopSpacing: CGFloat = 22
        static let titleFontSize: CGFloat = 28
        static let titleTopSpacing: CGFloat = 24
        static let subtitleFontSize: CGFloat = 16
        static let subtitleTopSpacing: CGFloat = 8
        static let emailInputTopSpacing: CGFloat = 36
        static let passwordTitleTopSpacing: CGFloat = 20
        static let passwordInputTopSpacing: CGFloat = 8
        static let loginButtonTopSpacing: CGFloat = 24
        static let orDividerTopSpacing: CGFloat = 24
        static let orDividerFontSize: CGFloat = 12
        static let orDividerLineHeight: CGFloat = 1
        static let socialButtonTopSpacing: CGFloat = 16
        static let socialButtonHeight: CGFloat = 56
        static let registerLabelTopSpacing: CGFloat = 24
        static let agreementTopSpacing: CGFloat = 16
        static let agreementBottomSpacing: CGFloat = 32
        static let agreementFontSize: CGFloat = 13
        static let passwordTitleFontSize: CGFloat = 16
        static let registerFontSize: CGFloat = 15
        static let sidePadding: CGFloat = 16
    }

    private enum Strings {

        static let title = "Welcome back"
        static let subtitle = "Sign in to track your daily water intake"
        static let emailTitle = "Email"
        static let emailPlaceholder = "example@mail.com"
        static let passwordTitle = "Password"
        static let forgotPassword = "Forgot password?"
        static let passwordPlaceholder = "Password"
        static let loginButton = "Sign In"
        static let orThrough = "OR CONTINUE WITH"
        static let noAccount = "Don't have an account? "
        static let createAccount = "Sign Up ›"
        static let agreementPrefix = "By continuing, you agree to our "
        static let agreementTerms = "Terms of Service"
        static let agreementAnd = " and "
        static let agreementPrivacy = "Privacy Policy"
    }

    // MARK: - Public properties

    weak var delegate: AuthViewDelegate?

    var email: String? { emailInput.text }
    var password: String? { passwordInput.text }

    func setLoginLoading(_ loading: Bool) {
        loginButton.isLoading = loading
    }

    // MARK: - Private properties

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
        view.layer.cornerRadius = Constants.logoCornerRadius

        return view
    }()

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: Constants.logoIconSize, weight: .medium)
        imageView.image = UIImage(systemName: "drop.fill", withConfiguration: config)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Strings.title
        label.font = .boldSystemFont(ofSize: Constants.titleFontSize)
        label.textAlignment = .center

        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Strings.subtitle
        label.font = .systemFont(ofSize: Constants.subtitleFontSize)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
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

    private lazy var passwordTitleRow: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = Strings.passwordTitle
        titleLabel.font = .boldSystemFont(ofSize: Constants.passwordTitleFontSize)
        titleLabel.textColor = .label

        let action = UIAction { [weak self] _ in
            guard let self else { return }
            delegate?.authViewDidTapForgotPassword(self)
        }
        let forgotButton = UIButton(primaryAction: action)
        forgotButton.translatesAutoresizingMaskIntoConstraints = false
        forgotButton.setTitle(Strings.forgotPassword, for: .normal)
        forgotButton.setTitleColor(.systemIndigo, for: .normal)
        forgotButton.titleLabel?.font = .systemFont(ofSize: Constants.passwordTitleFontSize)

        view.addSubview(titleLabel)
        view.addSubview(forgotButton)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            forgotButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            forgotButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        return view
    }()

    private lazy var passwordInput: CUITextField = {
        let input = CUITextField(
            placeholder: Strings.passwordPlaceholder,
            leftIcon: UIImage(systemName: "lock")
        )
        input.translatesAutoresizingMaskIntoConstraints = false
        input.isSecureTextEntry = true
        input.returnKeyType = .done
        input.onReturn = { [weak self] in
            guard let self else { return }
            endEditing(true)
        }

        return input
    }()

    private lazy var loginButton: CUIButton = {
        let button = CUIButton(title: Strings.loginButton)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.onTap = { [weak self] in
            guard let self else { return }
            print("tapped sign in")
            delegate?.authViewDidTapLogin(self)
        }

        return button
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
        button.isEnabled = false

        return button
    }()

    private lazy var googleButton: CUISocialButton = {
        let button = CUISocialButton(provider: .google)
        button.onTap = { [weak self] in
            guard let self else { return }
            print("tapped continue with Google")
            delegate?.authViewDidTapGoogle(self)
        }

        return button
    }()

    private lazy var socialButtonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [appleButton, googleButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually

        return stack
    }()

    private lazy var registerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.isUserInteractionEnabled = true

        let prefix = NSAttributedString(
            string: Strings.noAccount,
            attributes: [
                .foregroundColor: UIColor.secondaryLabel,
                .font: UIFont.systemFont(ofSize: Constants.registerFontSize),
            ]
        )
        let link = NSAttributedString(
            string: Strings.createAccount,
            attributes: [
                .foregroundColor: UIColor.systemIndigo,
                .font: UIFont.systemFont(ofSize: Constants.registerFontSize),
            ]
        )
        let attributed = NSMutableAttributedString()
        attributed.append(prefix)
        attributed.append(link)
        label.attributedText = attributed

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleRegisterTap))
        label.addGestureRecognizer(tap)

        return label
    }()

    private lazy var agreementLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center

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

        label.isUserInteractionEnabled = true
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

// MARK: - AuthView + Actions

private extension AuthView {

    @objc func handleRegisterTap() {
        delegate?.authViewDidTapRegister(self)
    }

    @objc func handleAgreementTap() {
        print("tapped agreement on auth screen")
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
        let inputs: [CUITextField] = [emailInput, passwordInput]

        guard let active = inputs.first(where: { $0.isEditing }) else {

            return
        }

        let rect = active.convert(active.bounds, to: contentView)
        scrollView.scrollRectToVisible(rect.insetBy(dx: 0, dy: -16), animated: true)
    }
}

// MARK: - AuthView + Setup

private extension AuthView {

    func setup() {
        setupViews()
        setupConstraints()
        setupKeyboardObservers()
    }

    func setupViews() {
        backgroundColor = .white
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(logoContainerView)
        logoContainerView.addSubview(logoImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(emailInput)
        contentView.addSubview(passwordTitleRow)
        contentView.addSubview(passwordInput)
        contentView.addSubview(loginButton)
        contentView.addSubview(orDividerView)
        contentView.addSubview(socialButtonsStackView)
        contentView.addSubview(registerLabel)
        contentView.addSubview(agreementLabel)
    }

    func setupConstraints() {
        setupConstraintsForScrollView()
        setupConstraintsForContentView()
        setupConstraintsForLogo()
        setupConstraintsForTitleLabel()
        setupConstraintsForSubtitleLabel()
        setupConstraintsForEmailInput()
        setupConstraintsForPasswordTitleRow()
        setupConstraintsForPasswordInput()
        setupConstraintsForLoginButton()
        setupConstraintsForOrDivider()
        setupConstraintsForSocialButtons()
        setupConstraintsForRegisterLabel()
        setupConstraintsForAgreementLabel()
    }

    func setupConstraintsForScrollView() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
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

    func setupConstraintsForLogo() {
        NSLayoutConstraint.activate([
            logoContainerView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.logoTopSpacing
            ),
            logoContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoContainerView.widthAnchor.constraint(equalToConstant: Constants.logoSize),
            logoContainerView.heightAnchor.constraint(equalToConstant: Constants.logoSize),

            logoImageView.centerXAnchor.constraint(equalTo: logoContainerView.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: logoContainerView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: Constants.logoIconSize),
            logoImageView.heightAnchor.constraint(equalToConstant: Constants.logoIconSize),
        ])
    }

    func setupConstraintsForTitleLabel() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: logoContainerView.bottomAnchor,
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
                constant: Constants.emailInputTopSpacing
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

    func setupConstraintsForPasswordTitleRow() {
        NSLayoutConstraint.activate([
            passwordTitleRow.topAnchor.constraint(
                equalTo: emailInput.bottomAnchor,
                constant: Constants.passwordTitleTopSpacing
            ),
            passwordTitleRow.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.sidePadding
            ),
            passwordTitleRow.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.sidePadding
            ),
        ])
    }

    func setupConstraintsForPasswordInput() {
        NSLayoutConstraint.activate([
            passwordInput.topAnchor.constraint(
                equalTo: passwordTitleRow.bottomAnchor,
                constant: Constants.passwordInputTopSpacing
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

    func setupConstraintsForLoginButton() {
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(
                equalTo: passwordInput.bottomAnchor,
                constant: Constants.loginButtonTopSpacing
            ),
            loginButton.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.sidePadding
            ),
            loginButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.sidePadding
            ),
        ])
    }

    func setupConstraintsForOrDivider() {
        NSLayoutConstraint.activate([
            orDividerView.topAnchor.constraint(
                equalTo: loginButton.bottomAnchor,
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

    func setupConstraintsForRegisterLabel() {
        NSLayoutConstraint.activate([
            registerLabel.topAnchor.constraint(
                equalTo: socialButtonsStackView.bottomAnchor,
                constant: Constants.registerLabelTopSpacing
            ),
            registerLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.sidePadding
            ),
            registerLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.sidePadding
            ),
        ])
    }

    func setupConstraintsForAgreementLabel() {
        NSLayoutConstraint.activate([
            agreementLabel.topAnchor.constraint(
                equalTo: registerLabel.bottomAnchor,
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

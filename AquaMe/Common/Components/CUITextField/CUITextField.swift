//
//  CUITextField.swift
//  AquaMe
//

import UIKit

// MARK: - CUITextField

final class CUITextField: UIView {

    // MARK: - Private enums

    private enum Constants {

        static let cornerRadius: CGFloat = 14
        static let borderWidth: CGFloat = 1
        static let fieldHeight: CGFloat = 48
        static let horizontalPadding: CGFloat = 16
        static let titleToFieldSpacing: CGFloat = 12
        static let fieldToHintSpacing: CGFloat = 6
        static let fieldInnerSpacing: CGFloat = 8
        static let titleFontSize: CGFloat = 16
        static let inputFontSize: CGFloat = 16
        static let suffixFontSize: CGFloat = 16
        static let hintFontSize: CGFloat = 13
    }

    // MARK: - Public properties

    var onTextChange: ((String?) -> Void)?

    var text: String? {
        get {
            textField.text
        }
        set {
            textField.text = newValue
        }
    }

    var keyboardType: UIKeyboardType {
        get {
            textField.keyboardType
        }
        set {
            textField.keyboardType = newValue
        }
    }

    var isEditing: Bool { textField.isEditing }

    var returnKeyType: UIReturnKeyType {
        get {
            textField.returnKeyType
        }
        set {
            textField.returnKeyType = newValue
        }
    }

    var onReturn: (() -> Void)?

    // MARK: - Private properties

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: Constants.titleFontSize)
        label.textColor = .label

        return label
    }()

    private lazy var fieldContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.borderWidth = Constants.borderWidth
        view.layer.borderColor = UIColor.systemGray4.cgColor

        return view
    }()

    private lazy var textField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = .systemFont(ofSize: Constants.inputFontSize)
        field.borderStyle = .none
        field.delegate = self
        field.addTarget(self, action: #selector(textDidChange), for: .editingChanged)

        return field
    }()

    private lazy var suffixLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.suffixFontSize)
        label.textColor = .secondaryLabel
        label.isHidden = true
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)

        return label
    }()

    private lazy var fieldStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [textField, suffixLabel])
        stack.axis = .horizontal
        stack.spacing = Constants.fieldInnerSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }()

    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.hintFontSize)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.isHidden = true

        return label
    }()

    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, fieldContainerView, hintLabel])
        stack.axis = .vertical
        stack.spacing = Constants.titleToFieldSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }()

    // MARK: - Initialization

    init(
        title: String? = nil,
        placeholder: String? = nil,
        suffix: String? = nil,
        hint: String? = nil
    ) {
        super.init(frame: .zero)
        setup()
        configure(title: title, placeholder: placeholder, suffix: suffix, hint: hint)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}

// MARK: - CUITextField + Public

extension CUITextField {

    func configure(
        title: String? = nil,
        placeholder: String? = nil,
        suffix: String? = nil,
        hint: String? = nil
    ) {
        titleLabel.text = title
        titleLabel.isHidden = title == nil

        textField.placeholder = placeholder

        suffixLabel.text = suffix
        suffixLabel.isHidden = suffix == nil

        hintLabel.text = hint
        hintLabel.isHidden = hint == nil
    }
}

// MARK: - CUITextField + UITextFieldDelegate

extension CUITextField: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let onReturn {
            onReturn()
        } else {
            textField.resignFirstResponder()
        }

        return true
    }
}

// MARK: - CUITextField + Actions

private extension CUITextField {

    @objc func textDidChange() {
        onTextChange?(textField.text)
    }
}

// MARK: - CUITextField + Setup

private extension CUITextField {

    func setup() {
        setupViews()
        setupConstraints()
    }

    func setupViews() {
        addSubview(mainStackView)
        fieldContainerView.addSubview(fieldStackView)
    }

    func setupConstraints() {
        setupConstraintsForMainStackView()
        setupConstraintsForFieldContainer()
        setupConstraintsForFieldStackView()
    }

    func setupConstraintsForMainStackView() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    func setupConstraintsForFieldContainer() {
        NSLayoutConstraint.activate([
            fieldContainerView.heightAnchor.constraint(equalToConstant: Constants.fieldHeight),
        ])
    }

    func setupConstraintsForFieldStackView() {
        NSLayoutConstraint.activate([
            fieldStackView.leadingAnchor.constraint(
                equalTo: fieldContainerView.leadingAnchor,
                constant: Constants.horizontalPadding
            ),
            fieldStackView.trailingAnchor.constraint(
                equalTo: fieldContainerView.trailingAnchor,
                constant: -Constants.horizontalPadding
            ),
            fieldStackView.centerYAnchor.constraint(equalTo: fieldContainerView.centerYAnchor),
        ])
    }
}

//
//  ModalAlertController.swift
//  Evexia
//
//  Created by  Artem Klimov on 07.07.2021.
//

import UIKit

// MARK: - ModalAlertController Dimensions
enum Dimensions {

    static func width(from size: CGSize) -> CGFloat {
        let calculatedSize = size.width - 48.0
        if calculatedSize > 400.0 {
            return 420.0
        } else {
            return calculatedSize
        }
    }
}

class ModalAlertController: UIViewController {

    // MARK: - Properties
    internal var alertViewHeight: NSLayoutConstraint?
    internal var alertViewWidth: NSLayoutConstraint?
    internal var messageTextViewHeightConstraint: NSLayoutConstraint?
    internal var titleLabelHeight: CGFloat = 20
    internal var messageLabelHeight: CGFloat = 20
    internal var buttonHeight: CGFloat = 52.0

    internal var iconHeightConstraint: NSLayoutConstraint?
    internal var isNeedToDismiss = false

    open var onDismissed: (() -> Void)?

    internal lazy var backgroundView: UIView = {
        let bgView = UIView()
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.backgroundColor = .black
        bgView.alpha = 0.6
        return bgView
    }()

    internal var alertView: UIView = {
        let alertView = UIView()
        alertView.translatesAutoresizingMaskIntoConstraints = false
        alertView.backgroundColor = .white
        alertView.layer.cornerRadius = 16.0
        alertView.clipsToBounds = false
        alertView.layer.masksToBounds = false

        return alertView
    }()

    internal var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Outfit-SemiBold", size: 24.0)
        label.textAlignment = .center
        label.textColor = .blue84
        label.numberOfLines = 0

        return label
    }()

    internal var messageTextView: UILabel = {
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        textLabel.font = UIFont(name: "Outfit-Regular", size: 16.0)
        textLabel.textColor = .blue84
        textLabel.backgroundColor = UIColor.clear
        return textLabel
    }()

    internal let topStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 25.0
        return stackView
    }()

    internal let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 16.0
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()

    public var cornerRadius: CGFloat? {
        willSet {
            self.alertView.layer.cornerRadius = newValue!
        }
    }

    public var titleText: String? {
        get {
            return self.titleLabel.text
        }
        set {
            self.titleLabel.text = newValue
        }
    }

    public var messageText: String? {
        get {
            return self.messageTextView.attributedText?.string
        }
        set {
            self.messageTextView.text = (newValue ?? "")

            guard newValue != nil, let constraint = messageTextViewHeightConstraint else { return }

            self.messageLabelHeight = 20.0
            self.messageTextView.removeConstraint(constraint)
            self.messageTextViewHeightConstraint = self.messageTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: messageLabelHeight)
            self.messageTextViewHeightConstraint!.isActive = true
        }
    }

    public var titleColor: UIColor? {
        willSet {
            self.titleLabel.textColor = newValue
        }
    }

    /// Alert background color
    public var backgroundColor: UIColor? {
        willSet {
            self.alertView.backgroundColor = newValue
        }
    }

    public var backgroundViewColor: UIColor? {
        willSet {
            self.backgroundView.backgroundColor = newValue
        }
    }

    public var backgroundViewAlpha: CGFloat? {
        willSet {
            self.backgroundView.alpha = newValue!
        }
    }

    /// Spacing between actions when presenting two actions in horizontal
    public var buttonSpacing: CGFloat = 16.0 {
        willSet {
            self.buttonStackView.spacing = newValue
        }
    }

    public var cancelable: Bool = false {
        didSet {
            if self.cancelable {
                let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapBehind(_:)))
                self.backgroundView.addGestureRecognizer(tap)
            }
        }
    }
    
    /// Drop Shadow Alert View
    open func dropShadow(radius: CGFloat, xOffset: CGFloat, yOffset: CGFloat, shadowOpacity: Float, shadowColor: UIColor) {
        self.alertView.dropShadow(radius: radius, xOffset: xOffset, yOffset: yOffset, shadowOpacity: shadowOpacity, shadowColor: shadowColor)
    }

    // MARK: - Initializers
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /// Creates a EMAlertController object with the specified title and message
    public init(title: String?, message: String?) {
        super.init(nibName: nil, bundle: nil)

        (title != nil) ? (self.titleLabelHeight = 20.0) : (self.titleLabelHeight = 0.0)
        (message != nil) ? (self.messageLabelHeight = 20.0) : (self.messageLabelHeight = 0.0)

        self.titleText = title
        self.messageText = message

        self.setUp()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
            let transform = CGAffineTransform(translationX: 0, y: 50)
            self.alertView.transform = transform
        }, completion: nil)

        self.setNeedsStatusBarAppearanceUpdate()
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

        if size.height < size.width {
            self.alertViewHeight?.constant = size.height - 40.0
            self.iconHeightConstraint?.constant = 0
        } else {
            self.alertViewHeight?.constant = size.height - 80.0
        }

        self.alertViewWidth?.constant = Dimensions.width(from: size)

        UIView.animate(withDuration: 0.3) {
            self.alertView.updateConstraints()
        }
    }
}

// MARK: - Setup Methods
extension ModalAlertController {

    internal func setUp() {
        self.modalPresentationStyle = .custom
        self.modalTransitionStyle = .crossDissolve
        self.addConstraits()
        self.view.dropShadow(radius: 24.0, xOffset: 0.0, yOffset: 2.0, shadowOpacity: 0.4, shadowColor: .white)
    }

    internal func addConstraits() {
        view.addSubview(alertView)
        view.insertSubview(backgroundView, at: 0)

        alertView.addSubview(topStackView)
        alertView.addSubview(buttonStackView)

        topStackView.addArrangedSubview(titleLabel)
        topStackView.addArrangedSubview(messageTextView)

        backgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        alertView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor).isActive = true
        alertView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        alertViewWidth = alertView.widthAnchor.constraint(equalToConstant: Dimensions.width(from: view.bounds.size))
        alertViewWidth?.isActive = true
        alertViewHeight = alertView.heightAnchor.constraint(lessThanOrEqualToConstant: view.bounds.height - 80.0)
        alertViewHeight?.isActive = true

        topStackView.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 37.0).isActive = true
        topStackView.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 16.0).isActive = true
        topStackView.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -16.0).isActive = true

        buttonStackView.axis = .horizontal
        buttonStackView.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 25.0).isActive = true
        buttonStackView.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 16.0).isActive = true
        buttonStackView.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -16.0).isActive = true
        buttonStackView.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -32.0).isActive = true

        buttonStackView.spacing = self.buttonSpacing
    }
}

// MARK: - Internal Methods
extension ModalAlertController {
    @objc
    internal func dismissFromTap() {
        dismiss(animated: true, completion: nil)
    }

    @objc
    internal func keyboardWillShow() {
        UIView.animate(withDuration: 0.3) {
            let transform = CGAffineTransform(translationX: 0, y: -200.0)
            self.alertView.transform = transform
        }
    }

    @objc
    internal func keyboardWillHide() {
        UIView.animate(withDuration: 0.3) {
            let transform = CGAffineTransform(translationX: 0, y: -100.0)
            self.alertView.transform = transform
        }
    }
}

// MARK: - Action Methods
extension ModalAlertController {

    open func addAction(_ action: AlertAction) {
        action.titleLabel?.lineBreakMode = .byTruncatingTail
        action.translatesAutoresizingMaskIntoConstraints = false
        action.addConstraint(NSLayoutConstraint(item: action, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.buttonHeight))
        action.cornerRadius = self.buttonHeight / 2

        self.buttonStackView.addArrangedSubview(action)
        
        if self.buttonStackView.subviews.count > 1 {
            self.buttonStackView.distribution = .fillProportionally
            self.buttonStackView.layoutMargins = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
        } else {
            self.buttonStackView.layoutMargins = UIEdgeInsets(top: 0.0, left: 66.0, bottom: 0.0, right: 66.0)
        }
        
        if self.isNeedToDismiss {
            action.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        }
    }

    @objc
    func buttonAction(_ sender: AlertAction) {
        dismiss(animated: true) { [weak self] in
            self?.onDismissed?()
        }
    }

    @objc
    func handleTapBehind(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
}

//
//  RescountsAlert.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-08-05.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class RescountsAlert: UIView {
	
	typealias AlertCallback = (RescountsAlert, Int) -> Void
	public var callback: AlertCallback?
	public var textValue: String { return textFields.map({ $0.text ?? "" }).joined(separator: "") }
	
	private let alertView  = UIView()
	private let titleLabel = UILabel()
	private let textLabel  = UILabel()
	private let textLabel2 = UILabel()
	private let iconView   = UIImageView()
	private var buttons: [RescountsButton] = []
	private var textFields: [TextFieldWithDelete] = []
	
	private var removedObserver: Bool = false
	
	private let kMarginSide: CGFloat = 22
	private let kPaddingSide: CGFloat = 22
	private let kPaddingTop: CGFloat = 15
	private let kSpacerV: CGFloat = 12
	private let kSpacerH: CGFloat = 15
	private let kButtonHeight: CGFloat = 44
	private let kIconSize: CGFloat = 44
	private let kMaxTextHeight: CGFloat = 300
	private let kTextFieldWidth: CGFloat = 36
	private let kTextFieldHeight: CGFloat = 30
	private let kTextFieldSpacer: CGFloat = 13
	private let kUnderlineHeight: CGFloat = 2

	enum IconType {
		case checkmark
	}
	
	
	// MARK: - Initialization
	
	convenience init() {
		self.init(frame: .arbitrary)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		self.backgroundColor = .dimmedBackground
		
		setupAlert()
	}
	
	
	// MARK: - UIView Methods
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let alertWidth  = frame.width - 2*kMarginSide
		let textWidth   = alertWidth - 2*kPaddingSide
		let titleHeight = titleLabel.sizeThatFits(CGSize(textWidth, 400)).height
        let textHeight  = min(textLabel.sizeThatFits(CGSize(textWidth, 400)).height, kMaxTextHeight)
		var maxY: CGFloat = 0
		
		// Title / Text
		titleLabel.frame = CGRect(kPaddingSide, kPaddingTop, textWidth, titleHeight)
		textLabel.frame = CGRect(kPaddingSide, titleLabel.frame.maxY + kSpacerV, textWidth, textHeight)
		maxY = textLabel.frame.maxY
		
		// Icon
		if iconView.image != nil {
			let iconX = floor((alertWidth - kIconSize)/2)
			iconView.frame = CGRect(iconX, maxY + kSpacerV, kIconSize, kIconSize)
			maxY = iconView.frame.maxY
		}
		
		// Textfields
		if textFields.count > 0 {
			let totalTextWidth = (CGFloat(textFields.count) * kTextFieldWidth + CGFloat(textFields.count - 1) * kTextFieldSpacer)
			let textX = floor((alertWidth - totalTextWidth) / 2)
			for (i, t) in textFields.enumerated() {
				t.frame = CGRect(textX + CGFloat(i)*(kTextFieldWidth + kTextFieldSpacer), maxY + kSpacerV, kTextFieldWidth, kTextFieldHeight)
			}
			maxY = textFields.first?.frame.maxY ?? maxY
		}
		
		// Post-icon Text
		if textLabel2.superview != nil {
			let textHeight2  = textLabel2.sizeThatFits(CGSize(textWidth, 400)).height
			textLabel2.frame = CGRect(kPaddingSide, maxY + kSpacerV, textWidth, textHeight2)
			maxY = textLabel2.frame.maxY
		}
		
		// Buttons
		if buttons.count > 0 {
			let buttonWidth = ceil((textWidth - CGFloat(buttons.count - 1) * kSpacerH) / CGFloat(buttons.count))
			for (i, button) in buttons.enumerated() {
				button.frame = CGRect(kPaddingSide + CGFloat(i) * (kSpacerH + buttonWidth), maxY + kSpacerV, buttonWidth, kButtonHeight)
			}
			maxY = buttons[buttons.count - 1].frame.maxY
		}
		
		// Only update frame if we're not currently transitioning
		if (alertView.transform.isIdentity) {
			let alertHeight = maxY + kPaddingTop
			let alertY = textFields.count > 0 ? floor((frame.height - alertHeight) / 4) : floor((frame.height - alertHeight) / 2) // A bit high if keyboard is needed
			alertView.frame = CGRect(kMarginSide, alertY, alertWidth, alertHeight)
		}
	}
	
	
	// MARK: - Public Methods
	
	@discardableResult
	public static func showAlert(title: String, text: String, icon: IconType? = nil, postIconText: NSAttributedString? = nil, options: [String]? = nil, numTextFields: Int = 0, callback: AlertCallback? = nil) -> RescountsAlert {
		let alert = RescountsAlert()
		
		alert.setupText(title: title, text: text)
		alert.setupIcon(icon)
		alert.setupPostIconText(postIconText)
		alert.setupButtons(options)
		alert.setupTextFields(numTextFields)
		
		alert.callback = callback
		
		// Animate entry
		alert.alertView.alpha = 0
		UIApplication.shared.keyWindow?.addSubview(alert)
		
		alert.setupObserver()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			alert.alertView.transform = CGAffineTransform(scaleX: 0, y: 0)
			alert.alertView.alpha = 1
			UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut], animations: {
				alert.alertView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
			}) { (completed: Bool) in
				UIView.animate(withDuration: 0.09, delay: 0, options: [.curveEaseInOut], animations: {
					alert.alertView.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
				}) { (completed: Bool) in
					UIView.animate(withDuration: 0.05, delay: 0, options: [.curveEaseIn], animations: {
						alert.alertView.transform = .identity
					}) { (completed: Bool) in
						alert.textFields.first?.becomeFirstResponder()
					}
				}
			}
		}
		
		let rootViewController = UIApplication.shared.keyWindow?.rootViewController
		rootViewController?.view.endEditing(true)
		
		return alert
	}
	
	public static func dismissAlerts() {
		UIApplication.shared.keyWindow?.subviews.forEach {
			if let view = $0 as? RescountsAlert {
				view.dismiss()
			}
		}
	}
	
	public func dismiss() {
		alertView.transform = .identity
		
		UIView.animate(withDuration: 0.1, animations: { [weak self] in
			self?.alertView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
		}, completion: { [weak self] (completed: Bool) in
			self?.removeObserver()
			if let _ = self?.superview {
				self?.removeFromSuperview()
			}
		})
	}
	
	
	// MARK: - Private Methods
	
	private func setupAlert() {
		frame = UIScreen.main.bounds;
		autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		alertView.backgroundColor = .white
		addSubview(alertView)
	}
	
	private func setupLabel(_ label: UILabel, text: String, font: UIFont = UIFont.lightRescounts(ofSize: 15)) {
		label.text = text
		label.textColor = .dark
		label.font = font
		label.textAlignment = .center
		label.numberOfLines = 0
		alertView.addSubview(label)
	}
	
	private func setupText(title: String, text: String) {
		setupLabel(titleLabel, text: title, font: UIFont.rescounts(ofSize: 15))
		setupLabel(textLabel, text: text)
	}
	
	private func setupIcon(_ icon: IconType?) {
		if let icon = icon {
			switch (icon) {
			case .checkmark:
				iconView.image = UIImage(named: "iconCheckmarkLarge")
			}
			alertView.addSubview(iconView)
		}
	}
	
	private func setupPostIconText(_ text: NSAttributedString?) {
		if let text = text, text.string.count > 0 {
			setupLabel(textLabel2, text: "")
			textLabel2.attributedText = text
		}
	}
	
	private func setupButtons(_ titles: [String]?) {
		let buttTitles = (titles?.isEmpty == false) ? titles! : [l10n("ok").uppercased()]
		
		for (i, title) in buttTitles.enumerated() {
			let button = RescountsButton()
			button.displayType = (i==buttTitles.count-1) ? .primary : .secondary
			button.setTitle(title, for: .normal)
			button.setTitleColor(.dark, for: .normal)
			button.titleLabel?.font = UIFont.rescounts(ofSize: 15)
			button.titleLabel?.adjustsFontSizeToFitWidth = true
			button.titleLabel?.minimumScaleFactor = 0.95 // Allow only a very slight amount of shrinking (to handle "Check Availability" without completely refactoring this to allow variable button widths)
			button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
			button.addAction(for: .touchUpInside) { [weak self] in
				self?.tappedButton(i)
			}
            for title in titles ?? [] {
                if title == l10n("dineIn") {
                    button.displayType = .primary
                }
            }
			alertView.addSubview(button)
			buttons.append(button)
		}
	}
	
	private func setupTextFields(_ numFields: Int) {
		for _ in 0..<numFields {
			let t = TextFieldWithDelete(frame: .arbitrary)
			t.textAlignment = .center
			t.textColor = .primary
			t.font = .rescounts(ofSize: 33)
			t.delegate = self
			t.deleteDelegate = self
			t.autocapitalizationType = .allCharacters
			t.autocorrectionType = .no
			t.addAction(for: .editingChanged) { [weak self] in
				self?.textFieldChanged(t)
			}
			
			let v = UIView(frame: CGRect(0, t.frame.height - kUnderlineHeight, t.frame.width, kUnderlineHeight))
			v.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
			v.backgroundColor = .dark
			t.addSubview(v)
			
			alertView.addSubview(t)
			textFields.append(t)
		}
	}
	
	private func tappedButton(_ index: Int) {
		removeObserver()
		callback?(self, index)
		dismiss()
	}
	
	private func setupObserver() {
		addObserver(self, forKeyPath: #keyPath(superview.layer.sublayers), options: [.old, .new], context: nil)
	}
	
	private func removeObserver() {
		if !removedObserver {
			removeObserver(self, forKeyPath: #keyPath(superview.layer.sublayers))
			removedObserver = true
		}
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		// Keep navBarTinter at front when new views are added
		if let newLayers = change?[.newKey] as? [Any] {
			if  let newLayer = newLayers.last as? CALayer,
				let _ = newLayer.delegate as? RescountsAlert
			{
				// New view is also a Rescounts alert, so let it take over
				
			} else if let superview = self.superview {
				// New view is not an alert, stop it from taking over
				
				superview.bringSubview(toFront: self)
			}
		}
	}
}

extension RescountsAlert: UITextFieldDelegate, TextFieldDeleteDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		guard let text = textField.text,
			let textRange = Range(range, in: text),
			text.replacingCharacters(in: textRange, with: string).count <= 1
		else {
			// Don't let user type more than 1 character
			return false
		}
		
		return true
	}
	
	func textFieldDidDelete(_ textField: TextFieldWithDelete, oldText: String?) {
		if oldText?.count == 0,
			let i = textFields.firstIndex(of: textField)
		{
			// Move to previous text field
			if i > 0 {
				textFields[i-1].text = nil
				textFields[i-1].becomeFirstResponder()
			}
		}
    }
	
	func textFieldChanged(_ textField: UITextField) {
		print ("Changed.")
		
		if textField.text?.count == 1,
			let textField = textField as? TextFieldWithDelete,
			let i = textFields.firstIndex(of: textField)
		{
			// Move to next text field
			if i < (textFields.count - 1) {
				textFields[i+1].becomeFirstResponder()
			}
		}
	}
}

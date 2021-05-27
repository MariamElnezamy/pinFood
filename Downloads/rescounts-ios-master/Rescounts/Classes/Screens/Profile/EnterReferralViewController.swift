//
//  EnterReferralViewController.swift
//  RescountsTests
//
//  Created by Patrick Weekes on 2018-10-03.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class EnterReferralViewController: BaseViewController {
	
	private let instructions = UILabel()
	private let textField = RescountsTextField()
	private let textLine = UIView()
	private let doneButton = RescountsButton()
	private let container = UIView()
	
	private let kMargin: CGFloat = 25
	private let kTextFieldWidth: CGFloat = 200
	
	weak var delegate: ProfileViewControllerDelegate?
	
	private let tapCatchingView = UIView()
	
	
	// MARK: UIViewController Methods
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = l10n("referralCode").uppercased()
		
		view.backgroundColor = .white
		
		setupInstructions()
		setupTextField()
		setupButton()
		
		view.addSubview(container)
		
		view.addSubview(tapCatchingView)
		tapCatchingView.isHidden = true
		
		setupKeyboardDismissView()
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		let containerWidth = view.frame.width - 2*kMargin
		instructions.frame = CGRect(0, 0, containerWidth, 100)
		textField.frame    = CGRect(floor((containerWidth - kTextFieldWidth) / 2), instructions.frame.maxY + 40, kTextFieldWidth, 40)
		textLine.frame     = CGRect(textField.frame.minX, textField.frame.maxY, kTextFieldWidth, 2)
		doneButton.frame   = CGRect(0, textLine.frame.maxY + 40, containerWidth, 44)
		
		updateContainerFrame()
		
		tapCatchingView.frame = CGRect(0,0,self.view.frame.width, self.view.frame.height)
	}
	
	private func updateContainerFrame(keyboardOffset: CGFloat = 0) {
		let containerWidth = view.frame.width - 2*kMargin
		let containerHeight = doneButton.frame.maxY
		let y = floor((view.frame.height - containerHeight) / 2) - keyboardOffset
		container.frame = CGRect(kMargin, y, containerWidth, containerHeight)
	}
	
	// MARK: - UITextfield setup
	
	private func setupKeyboardDismissView() {
		tapCatchingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
		tapCatchingView.addGestureRecognizer(tap)
	}
	
	@objc func dismissKeyboard() {
		self.view.endEditing(true)
	}
	
	@objc func keyboardWillShow(notification:  NSNotification){
		tapCatchingView.isHidden = false
		
		var moveBy: CGFloat = 0
		if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
			let bottomGap = view.frame.height - container.frame.maxY
			moveBy = max(0, keyboardSize.height - bottomGap + 5)
		}
		updateContainerFrame(keyboardOffset: moveBy)
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
		tapCatchingView.isHidden = true
		updateContainerFrame(keyboardOffset: 0)
	}
	
	// MARK: - UI Helpers
	
	private func setupInstructions() {
		instructions.font = UIFont.rescounts(ofSize: 15)
		instructions.textAlignment = .center
		instructions.textColor = .dark
		instructions.numberOfLines = 0
		instructions.text = l10n("referIns")
		
		container.addSubview(instructions)
	}
	
	private func setupTextField() {
		textField.font = UIFont.rescounts(ofSize: 20)
		textField.textColor = .primary
		textField.placeholder = l10n("enterReferralCode")
		textField.autocorrectionType = .no
		textField.autocapitalizationType = .none
		textField.textAlignment = .center
		container.addSubview(textField)
		
		textLine.backgroundColor = UIColor.lightGray
		container.addSubview(textLine)
	}
	
	private func setupButton() {
		doneButton.setTitle(l10n("submit"), for: .normal)
		doneButton.titleLabel?.font = UIFont.rescounts(ofSize: 15)
		doneButton.addAction(for: .touchUpInside) { [weak self] in
			
			if let code = self?.textField.text, code.count > 0 {
				FullScreenSpinner.show()
				self?.view.endEditing(true)
				
				UserService.referFriend(sharingCode: code, callback: { (error) in
					FullScreenSpinner.hideAll()
					if (error == nil) {
						RescountsAlert.showAlert(title: l10n("succeeded"), text: l10n("referSucc"), icon: nil, postIconText: nil, options: nil) { [weak self] (alert, buttonIndex) in
							self?.navigationController?.popViewController(animated: true)
							self?.delegate?.removeEnterReferralCode()
						}
					} else {
						RescountsAlert.showAlert(title: l10n("oops"), text: error?.localizedDescription ?? l10n("referFailed"), icon: nil, postIconText: nil, options: nil, callback: nil)
					}
				})
			}
		}
		container.addSubview(doneButton)
	}
}

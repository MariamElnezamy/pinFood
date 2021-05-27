//
//  ForgotPasswordViewController.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-10-03.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
	
	private let emailContainer = UIView()
	private let instructions = UILabel()
	private let emailTextField = RescountsTextField()
	private let emailLine = UIView()
	private let sendEmailButton = RescountsButton()
	private let postEmailInstructions = UILabel()
	
	private let newPasswordContainer = UIView()
	private let codeTextField = RescountsTextField()
	private let codeLine = UIView()
	private let passwordTextField = RescountsTextField()
	private let passwordLine = UIView()
	private let confirmPasswordTextField = RescountsTextField()
	private let confirmPasswordLine = UIView()
	private let submitPasswordButton = RescountsButton()
	
	private let kMarginSide: CGFloat = 25
	private let kSpacer: CGFloat = 15
	private let kCodeWidth: CGFloat = 100
	private let kTextHeight: CGFloat = 30
	private let kButtonHeight: CGFloat = 44
	
	// MARK: UIViewController Methods
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = .white

        setupInstructions()
		setupEmail()
		setupEmailButton()
		setupEmailContainer()
		
		setupPasswordInstructions()
		setupPasswordFields()
		setupPasswordButton()
		setupPasswordContainer()
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		let textWidth = view.frame.width - 2*kMarginSide
		
		// Enter Email UI
		instructions.frame    = CGRect(0, 0, textWidth, 80)
		emailTextField.frame  = CGRect(0, instructions.frame.maxY + kSpacer, textWidth, kTextHeight)
		emailLine.frame       = CGRect(0, emailTextField.frame.maxY, textWidth, Constants.Profile.separatorHeight)
		sendEmailButton.frame = CGRect(0, emailTextField.frame.maxY + 2*kSpacer, textWidth, kButtonHeight)
		
		emailContainer.frame = CGRect(kMarginSide, 120, textWidth, sendEmailButton.frame.maxY)
		
		// New Password UI
		postEmailInstructions.frame = CGRect(0, 0, textWidth, kButtonHeight)
		
		codeTextField.frame = CGRect(floor((textWidth - kCodeWidth)/2), postEmailInstructions.frame.maxY + 2*kSpacer, kCodeWidth, kTextHeight)
		codeLine.frame      = CGRect(codeTextField.frame.minX, codeTextField.frame.maxY, codeTextField.frame.width, Constants.Profile.separatorHeight)
		
		passwordTextField.frame = CGRect(0, codeTextField.frame.maxY + kSpacer, textWidth, kTextHeight)
		passwordLine.frame      = CGRect(0, passwordTextField.frame.maxY, textWidth, Constants.Profile.separatorHeight)
		
		confirmPasswordTextField.frame = CGRect(0, passwordTextField.frame.maxY + kSpacer, textWidth, kTextHeight)
		confirmPasswordLine.frame      = CGRect(0, confirmPasswordTextField.frame.maxY, textWidth, Constants.Profile.separatorHeight)
		
		submitPasswordButton.frame = CGRect(0, confirmPasswordTextField.frame.maxY + 2*kSpacer, textWidth, kButtonHeight)
		
		newPasswordContainer.frame = CGRect(kMarginSide, 120, textWidth, submitPasswordButton.frame.maxY)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.setNavigationBarHidden(false, animated: true)
		
		self.transitionCoordinator?.animate(alongsideTransition: { [weak self](context) in
			self?.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
			self?.navigationController?.navigationBar.shadowImage = UIImage()
			self?.navigationController?.navigationBar.backgroundColor = .clear
			self?.navigationController?.navigationBar.barTintColor = .clear
			self?.navigationController?.navigationBar.tintColor = .dark
			}, completion: nil)
	}
	
	
	// MARK: - UI Helpers
	
	private func setupInstructions() {
		setupLabel(instructions, text: "Enter your email to receive a verification code.", parent: emailContainer)
	}
	
	private func setupEmail() {
		setupTextField(emailTextField, placeholder: l10n("email"), parent: emailContainer)
		setupLine(emailLine, parent: emailContainer)
	}
	
	private func setupEmailButton() {
		setupButton(sendEmailButton, title: "Submit Email", parent: emailContainer)
		
		sendEmailButton.addAction(for: .touchUpInside) { [weak self] in
			if let email = self?.emailTextField.text, email.count > 0 {
				FullScreenSpinner.show()
				
				UserService.forgotPassword(email: email) { (error) in
					FullScreenSpinner.hideAll()
					if (error == nil) {
						self?.showPasswordContainer()
					} else {
						RescountsAlert.showAlert(title: "Ooops!", text: error?.localizedDescription ?? "Unknown error, please try again later.")
					}
				}
			}
		}
	}
	
	private func setupEmailContainer() {
		view.addSubview(emailContainer)
	}
	
	private func setupPasswordInstructions() {
		setupLabel(postEmailInstructions, text: l10n("postEmailIns"), parent: newPasswordContainer)
	}
	
	private func setupPasswordFields() {
		setupTextField(codeTextField, placeholder: "XXXX", capitalization: .allCharacters, parent: newPasswordContainer)
		setupLine(codeLine, parent: newPasswordContainer)
		codeTextField.textAlignment = .center
		codeTextField.clearButtonMode = .never
		
		setupTextField(passwordTextField, placeholder: l10n("newPassword"), parent: newPasswordContainer)
		setupLine(passwordLine, parent: newPasswordContainer)
		passwordTextField.isSecureTextEntry = true
		
		setupTextField(confirmPasswordTextField, placeholder: l10n("confirmPassword"), parent: newPasswordContainer)
		setupLine(confirmPasswordLine, parent: newPasswordContainer)
		confirmPasswordTextField.isSecureTextEntry = true
	}
	
	private func setupPasswordButton() {
		setupButton(submitPasswordButton, title: l10n("subNewPass"), parent: newPasswordContainer)
		
		submitPasswordButton.addAction(for: .touchUpInside) { [weak self] in
			if (self?.passwordTextField.text?.count ?? 0) == 0 {
				RescountsAlert.showAlert(title: l10n("oops"), text: l10n("passIsMissing"))
				return
			} else if self?.passwordTextField.text != self?.confirmPasswordTextField.text {
				RescountsAlert.showAlert(title: l10n("oops"), text: l10n("passNotMatch"))
				return
			} else if (self?.codeTextField.text?.count ?? 0) == 0 {
				RescountsAlert.showAlert(title: l10n("oops"), text: l10n("codeIsMissing"))
				return
			} else if let text = self?.passwordTextField.text, let code = self?.codeTextField.text, let email = self?.emailTextField.text {
				
				UserService.resetPassword(code: code, email: email, password: text) { [weak self] (error) in
					if (error == nil) {
						RescountsAlert.showAlert(title: l10n("succeeded"), text: l10n("passUpdated")) { [weak self] (alert, buttonIndex) in
							self?.navigationController?.popViewController(animated: true)
						}
					} else {
						RescountsAlert.showAlert(title: l10n("oops"), text: l10n("resetPassErrorText")) { [weak self] (alert, buttonIndex) in
							self?.navigationController?.popViewController(animated: true)
						}
					}
				}
			}
		}
	}
	
	private func setupPasswordContainer() {
		view.addSubview(newPasswordContainer)
		
		newPasswordContainer.isUserInteractionEnabled = false
		newPasswordContainer.alpha = 0.0
	}
	
	private func setupTextField(_ textField: RescountsTextField, placeholder: String? = nil, capitalization: UITextAutocapitalizationType = .none, parent: UIView? = nil) {
		textField.placeholder = placeholder
		textField.font = .rescounts(ofSize: 15)
		textField.textColor = UIColor.nearBlack
		textField.autocorrectionType = .no
		textField.autocapitalizationType = capitalization
		textField.clearButtonMode = .whileEditing
		
		(parent ?? view).addSubview(textField)
	}
	
	private func setupLine(_ line: UIView, parent: UIView? = nil) {
		line.backgroundColor = UIColor.lightGray
		
		(parent ?? view).addSubview(line)
	}
	
	private func setupButton(_ button: RescountsButton, title: String, parent: UIView? = nil) {
		button.setTitle(title.uppercased(), for: .normal)
		button.titleLabel?.font = UIFont.rescounts(ofSize: 15.0)
		
		(parent ?? view).addSubview(button)
	}
	
	private func setupLabel(_ label: UILabel, text: String? = nil, parent: UIView? = nil) {
		label.font = UIFont.rescounts(ofSize: 15)
		label.textAlignment = .center
		label.textColor = .dark
		label.numberOfLines = 0
		label.text = text
		
		(parent ?? view).addSubview(label)
	}
	
	private func showPasswordContainer() {
		self.emailContainer.isUserInteractionEnabled = false
		newPasswordContainer.isUserInteractionEnabled = true
		
		UIView.animate(withDuration: 0.4) { [weak self] in
			self?.emailContainer.alpha = 0
			self?.newPasswordContainer.alpha = 1
		}
	}
	
	
	// MARK: - Public Methods
	
	public func setEmail(_ email: String?) {
		emailTextField.text = email
	}
}

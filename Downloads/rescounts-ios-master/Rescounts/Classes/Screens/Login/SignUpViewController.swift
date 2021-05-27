//
//  SignUpViewController.swift
//  Rescounts
//
//  Created by Monica Luo on 2018-09-04.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation
import UIKit

class SignUpViewController : UIViewController, UITextFieldDelegate {
	
	private let rescountsLogoImageView = UIImageView(image: UIImage(named: "logoLogin"))
	
	private let backgroundView = UIView()
	
	private let tapCatchingView = UIView()
	
	private let emailTextField = RescountsTextField()
	private let emailLine = UIView()
	
	private let passwordTextField = RescountsTextField()
	private let passwordLine = UIView()
	
	private let confirmedPasswordTextField = RescountsTextField()
	private let confirmedPasswordLine = UIView()
	
	private let signUpButton = RescountsButton()
	
	private let loginButton = UIButton()
	
	private let spinner = CircularLoadingSpinner()
	
	private var carsouselSize : CGFloat = 320
	private let kGap : CGFloat = 35
	private let kMiniGap : CGFloat = 10
	private let kTextFieldDetails: (width: CGFloat, height: CGFloat, topPadding: CGFloat) = (300.0 + 10.0 * 2, 40.0, 15.0)
	private let kRescountsLogoDetails: (width: CGFloat, height: CGFloat, bottomPadding: CGFloat, topPadding: CGFloat) = (300.0, 100.0, 40.0, 100)
	private let kRescountsButtonDetails: (width: CGFloat, height: CGFloat, topPadding: CGFloat) = (303, 51, 26)
	private let kLoginButtonDetails : (lineHeight: CGFloat, topPadding: CGFloat) = (20.0, 12)
	
	// MARK: - Initialization
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	
	// MARK: -  View Controllers funcs
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "CREATE ACCOUNT"
		
		backgroundView.backgroundColor = .white
		view.backgroundColor = .white
		view.addSubview(backgroundView)
		
		backgroundView.addSubview(rescountsLogoImageView)
		backgroundView.addSubview(tapCatchingView)
		tapCatchingView.isHidden = true
		
		// email
		setupTextfield(emailTextField, placeholder: l10n("email"))
		emailTextField.keyboardType = .emailAddress
		setupLine(emailLine)
		
		// password
		setupTextfield(passwordTextField, placeholder: l10n("password"))
		passwordTextField.isSecureTextEntry = true
		setupLine(passwordLine)
		
		// confirm password
		setupTextfield(confirmedPasswordTextField, placeholder: l10n("confirmPassword"))
		confirmedPasswordTextField.isSecureTextEntry = true
		setupLine(confirmedPasswordLine)
		
		setupSignUpButton()
		setupLoginButton()
		
		spinner.isHidden = true
		backgroundView.addSubview(spinner)
		
		setupKeyboardDismissView()
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
		
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.setNavigationBarHidden(false, animated: true)
		navigationController?.navigationBar.backgroundColor = .dark
		navigationController?.navigationBar.barTintColor = .dark
		navigationController?.navigationBar.tintColor = .white
		navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
		navigationController?.navigationBar.barStyle = .black
		
		hideSpinner(true)
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		backgroundView.frame = CGRect(0,0,self.view.frame.width, self.view.frame.height * 2)

		let totalHeight = kRescountsLogoDetails.height + kRescountsLogoDetails.bottomPadding + kTextFieldDetails.height + 2.0 + kTextFieldDetails.topPadding + kTextFieldDetails.height + 2.0 + kTextFieldDetails.topPadding + kTextFieldDetails.height + 2.0 + kRescountsButtonDetails.topPadding + kRescountsButtonDetails.height + kLoginButtonDetails.topPadding + kLoginButtonDetails.lineHeight
		
		rescountsLogoImageView.frame = CGRect(self.view.frame.width/2.0 - kRescountsButtonDetails.width/2, self.view.frame.height/2 - totalHeight/2.0, kRescountsLogoDetails.width, kRescountsLogoDetails.height)
		
		
		emailTextField.frame = CGRect((self.view.frame.width - kTextFieldDetails.width ) / 2.0, rescountsLogoImageView.frame.maxY + kRescountsLogoDetails.bottomPadding, kTextFieldDetails.width, kTextFieldDetails.height )
		emailLine.frame = CGRect(self.view.frame.width/2.0 - kRescountsButtonDetails.width/2.0, emailTextField.frame.maxY, kRescountsButtonDetails.width, 2.0)
		
		passwordTextField.frame = CGRect((self.view.frame.width - kTextFieldDetails.width ) / 2.0, emailLine.frame.maxY + kTextFieldDetails.topPadding, kTextFieldDetails.width, kTextFieldDetails.height )
		passwordLine.frame = CGRect(self.view.frame.width/2.0 - kRescountsButtonDetails.width/2.0, passwordTextField.frame.maxY, kRescountsButtonDetails.width, 2.0)
		
		confirmedPasswordTextField.frame = CGRect((self.view.frame.width - kTextFieldDetails.width ) / 2.0, passwordLine.frame.maxY + kTextFieldDetails.topPadding, kTextFieldDetails.width, kTextFieldDetails.height )
		confirmedPasswordLine.frame = CGRect(self.view.frame.width/2 - kRescountsButtonDetails.width/2.0, confirmedPasswordTextField.frame.maxY, kRescountsButtonDetails.width, 2.0)
		
		signUpButton.frame = CGRect(self.view.frame.width/2.0 - kRescountsButtonDetails.width/2.0, confirmedPasswordTextField.frame.maxY + kRescountsButtonDetails.topPadding, kRescountsButtonDetails.width, kRescountsButtonDetails.height)
		
		loginButton.frame = CGRect(0, signUpButton.frame.maxY + kLoginButtonDetails.topPadding, self.view.frame.width, kLoginButtonDetails.lineHeight)
		
		tapCatchingView.frame =  CGRect(0, 0 ,self.backgroundView.frame.width, self.backgroundView.frame.height)
		
		spinner.frame = signUpButton.frame
		spinner.frame.centerInPlace(size: CGSize(spinner.frame.height, spinner.frame.height))
	}
	
	// MARK: - UITextfield setup
	
	private func setupKeyboardDismissView() {
		tapCatchingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
		tapCatchingView.addGestureRecognizer(tap)
	}
	
	@objc func dismissKeyboard() {
		self.backgroundView.endEditing(true)
	}
	
	@objc func keyboardWillShow(notification:  NSNotification){
		//self.backgroundView.frame.origin.y = -nameTextField.frame.minY + kGap - kMiniGap
		/*
		if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
			self.backgroundView.frame.origin.y = -keyboardSize.height / 2.0
		}*/
		self.backgroundView.frame.origin.y = -136
		//self.backgroundView.addSubview(tapCatchingView)
		tapCatchingView.isHidden = false
	}
	
	@objc func keyboardWillHide(notification: NSNotification){
		self.backgroundView.frame.origin.y = 0
		//tapCatchingView.removeFromSuperview()
		tapCatchingView.isHidden = true
	}
	
	
	/*
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}*/
	
	//MARK: - private funcs

	private func setupLine(_ line: UIView) {
		line.backgroundColor = UIColor.lightGray
		backgroundView.addSubview(line)
	}
	
	private func setupTextfield(_ textField: RescountsTextField, placeholder: String){
		textField.placeholder = placeholder
		textField.font = .rescounts(ofSize: 15)
		textField.textColor = UIColor.nearBlack
		textField.autocorrectionType = .no
		textField.autocapitalizationType = .none
		backgroundView.addSubview(textField)
	}

	private func setupSignUpButton() {
		signUpButton.setTitle(l10n("next").uppercased(), for: .normal)
		signUpButton.titleLabel?.font = UIFont.rescounts(ofSize: 15.0)
		signUpButton.addAction(for: UIControlEvents.touchUpInside, tappedNext)
		backgroundView.addSubview(signUpButton)
	}
	
	private func setupLoginButton() {
		loginButton.titleLabel?.font = .lightRescounts(ofSize: 15)
		loginButton.setTitleColor(.dark, for: .normal)
		loginButton.setTitle(l10n("haveAccountSignIn"), for:.normal)
		loginButton.applyAttributes([.foregroundColor: UIColor.primary], toSubstring: l10n("login") )
		loginButton.addAction(for: .touchUpInside, tappedLogin)
		backgroundView.addSubview(loginButton)
	}
	
	private func tappedLogin() {
		let vc = LoginViewController()
		navigationController?.pushViewController(vc, animated: true)
	}
	
	private func tappedSkip() {
		Helper.printTodoImplement(#file, #function)
	}
	
	private func isValidEmail(testStr:String) -> Bool {
		
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
		let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
		let result = emailTest.evaluate(with: testStr)
		return result
		
	}
	
	private func tappedNext() {
		
		if (emailTextField.text != "" && passwordTextField.text != "" && confirmedPasswordTextField.text != "") {
			if (self.passwordTextField.text == self.confirmedPasswordTextField.text) {
				createAccount()
			} else if (!self.isValidEmail(testStr: self.emailTextField.text ?? "")){
				RescountsAlert.showAlert(title: l10n("oops"), text: l10n("invalidEmail"), callback: nil)
			} else {
				//show the password not equal to confirmed password alert
				RescountsAlert.showAlert(title: l10n("oops"), text: l10n("passwordsDontMatch"), callback: nil)
			}
		} else {
			//Show up empty textfield alert
			RescountsAlert.showAlert(title: l10n("oops"), text: l10n("emptyFields"), callback: nil)
		}
	}
	
	private func createAccount() {
		// Assumes we've already done all validation
		
		hideSpinner(false)
		
		if let email = emailTextField.text, let password = passwordTextField.text {
			UserService.createUser(email: email, password: password, callback: { [weak self] (user, error) in
				if (error != nil) {
					print(error?.localizedDescription ?? "")
					//Probably came back from sign up page 2, so go to login.
					UserService.login(email: email, password: password, callback: { (user, error2) in
						if error2 != nil  {
							RescountsAlert.showAlert(title: l10n("signUpErrorTitle"), text: "\(error2?.localizedDescription ?? error?.localizedDescription ?? l10n("signUpErrorText1")) \(l10n("signUpErrorText2"))" , callback: nil)
							print(error2?.localizedDescription ?? "User reset password when in sign up process.")
							self?.hideSpinner(true)
							return
						} else {
                            self?.moveToNextPage()
							//self?.navigationController?.pushViewController(SignUpContinueViewController(), animated: true)
						}
					})
				} else {
                    self?.moveToNextPage()
					//self?.navigationController?.pushViewController(SignUpContinueViewController(), animated: true)
				}
			})
		}
	}
    
    func moveToNextPage() {
        RescountsAlert.showAlert(title: "Please verify your email", text: "Almost there! We sent you an email on " + (emailTextField.text ?? ""), options: [l10n("ok").uppercased()]) { [weak self](alert, buttonIndex) in
            
            
            self?.navigationController?.pushViewController(SignUpContinueViewController(), animated: true)
        }
    }
	
	private func hideSpinner(_ spinnerHidden: Bool) {
		spinner.isHidden = spinnerHidden
		signUpButton.isHidden = !spinnerHidden
	}

}

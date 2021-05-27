//
//  LoginViewController.swift
//  Rescounts
//
//  Created by Kittiphong Xayasane on 2018-08-23.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import GoogleSignIn
import AuthenticationServices

class LoginViewController: UIViewController, LoginButtonDelegate , GIDSignInUIDelegate {
    private let rescountLogoImageView = UIImageView(image: UIImage(named: "logoLogin"))
    private let nameLine = UIView()
	private let emailTextField = RescountsTextField()
    private let emailLine = UIView()
	private let passwordTextField = RescountsTextField()
    private let passwordLine = UIView()
	private let loginButton = RescountsButton()
	private let orLabel = UILabel()
	private let fbLoginButton = LoginButton(readPermissions: [ .publicProfile, .email ])
	private let goLoginButton = GIDSignInButton(frame: .arbitrary)
    private let forgotPasswordButton = UIButton()
	private let signUpButton = UIButton()
	private let tapCatchingView = UIView()
	private let kTextFieldDetails: (width: CGFloat, height: CGFloat, topPadding: CGFloat) = (300.0 + 10.0 * 2, 40.0, 20.0)
    private let kRescountsLogoDetails: (width: CGFloat, height: CGFloat, bottomPadding: CGFloat, topPadding: CGFloat) = (200.0, 100.0, 30.0, 70)
    private let kRescountsButtonDetails: (width: CGFloat, height: CGFloat, topPadding: CGFloat) = (233, 51, 20)
    private let kSignUpButtonDetails: (lineHeight: CGFloat, topPadding: CGFloat) = (18.0, 24)
	private let kOrLabelDetails:(width: CGFloat, height: CGFloat, bottomPadding: CGFloat, topPadding: CGFloat) = (303, 25, 5, 5)
	private let kFBGOLoginButtonDetails: (width: CGFloat, height: CGFloat, bottomPadding: CGFloat, topPadding: CGFloat) = (233, 51, 10, 10)

	
	// MARK: - UIVIewController Methods
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.backgroundColor = .white
		
		view.addSubview(tapCatchingView)
		tapCatchingView.isHidden = true
		
		rescountLogoImageView.contentMode = .scaleAspectFit
        view.addSubview(rescountLogoImageView)
        
        nameLine.backgroundColor = UIColor.lightGray
        view.addSubview(nameLine)

		emailTextField.text = UserDefaults.standard.string(forKey: Constants.UserDefaults.lastUsedEmail)
		emailTextField.placeholder = l10n("email")
        emailTextField.font = .rescounts(ofSize: 15)
        emailTextField.textColor = UIColor.nearBlack
		emailTextField.autocorrectionType = .no
		emailTextField.autocapitalizationType = .none
		emailTextField.clearButtonMode = .whileEditing
		view.addSubview(emailTextField)

        emailLine.backgroundColor = UIColor.lightGray
        view.addSubview(emailLine)

		passwordTextField.placeholder = l10n("password")
        passwordTextField.font = .rescounts(ofSize: 15)
        passwordTextField.textColor = UIColor.nearBlack
		passwordTextField.isSecureTextEntry = true
		view.addSubview(passwordTextField)

        passwordLine.backgroundColor = UIColor.lightGray
        view.addSubview(passwordLine)
		
		loginButton.setTitle(l10n("login").uppercased(), for: .normal)
        loginButton.titleLabel?.font = UIFont.rescounts(ofSize: 15.0)
		loginButton.addAction(for: .touchUpInside) { [weak self] in
			self?.tappedLogin()
		}
		view.addSubview(loginButton)
		
		orLabel.text = "- \(l10n("or").uppercased()) -"
		orLabel.font = .rescounts(ofSize: 15)
		orLabel.textColor = UIColor.lightGray
		orLabel.textAlignment = .center
		view.addSubview(orLabel)
		
		fbLoginButton.delegate = self
		setButtonCornerRadius(fbLoginButton)
		view.addSubview(fbLoginButton)
		
		goLoginButton.colorScheme = .light
		goLoginButton.style = .wide
		setButtonCornerRadius(goLoginButton)
		view.addSubview(goLoginButton)
		GIDSignIn.sharedInstance().uiDelegate = self
		
        forgotPasswordButton.titleLabel?.font = UIFont.lightRescounts(ofSize: 15)
        forgotPasswordButton.setTitleColor(.dark, for: .normal)
		forgotPasswordButton.setTitle(l10n("forgotPassword"), for:.normal)
		forgotPasswordButton.addAction(for: .touchUpInside) { [weak self] in
			let vc = ForgotPasswordViewController()
			vc.setEmail(self?.emailTextField.text)
			self?.navigationController?.pushViewController(vc, animated: true)
		}
        view.addSubview(forgotPasswordButton)
		
        signUpButton.titleLabel?.font = UIFont.lightRescounts(ofSize: 15)
		signUpButton.setTitleColor(.dark, for:.normal)
		signUpButton.setTitle(l10n("noAccountSignUp"), for:.normal)
		signUpButton.applyAttributes([.foregroundColor: UIColor.primary], toSubstring: l10n("signUp"))
		signUpButton.addAction(for: .touchUpInside) { [weak self] in
			self?.tappedSignUp()
		}
        view.addSubview(signUpButton)
		
		setupKeyboardDismissView()
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationBar.backgroundColor = .dark
        self.navigationController?.navigationBar.barTintColor = .dark
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.barStyle = .black
		
		NotificationCenter.default.addObserver(self, selector: #selector(loggedIn), name: .loggedIn, object: nil)
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: .loggedIn, object: nil)
	}

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
	
	override func viewWillLayoutSubviews() {
        let totalHeight = kRescountsLogoDetails.height + kRescountsLogoDetails.bottomPadding + kTextFieldDetails.height + 2.0 + kTextFieldDetails.topPadding + kTextFieldDetails.height + 2.0 + kTextFieldDetails.topPadding + kTextFieldDetails.height + 2.0 + kRescountsButtonDetails.topPadding + kRescountsButtonDetails.height + kSignUpButtonDetails.topPadding + kSignUpButtonDetails.lineHeight + 8.0 + kSignUpButtonDetails.lineHeight
        
        rescountLogoImageView.frame = CGRect(self.view.frame.width/2 - kRescountsLogoDetails.width/2, self.view.frame.height/2 - totalHeight/2, kRescountsLogoDetails.width, kRescountsLogoDetails.height)
		
		let leftTextMargin = floor(self.view.frame.width/2 - kTextFieldDetails.width/2)
		let textLineWidth  = kTextFieldDetails.width - 16
		let leftLineMargin = floor(self.view.frame.width/2 - textLineWidth/2)
		
		emailTextField.frame = CGRect(leftTextMargin, rescountLogoImageView.frame.maxY + kRescountsLogoDetails.bottomPadding, kTextFieldDetails.width , kTextFieldDetails.height)
		emailLine.frame = CGRect(leftLineMargin, emailTextField.frame.maxY, textLineWidth, 2.0)
        
		passwordTextField.frame = CGRect(leftTextMargin, emailTextField.frame.maxY + kTextFieldDetails.topPadding, kTextFieldDetails.width, kTextFieldDetails.height)
		passwordLine.frame = CGRect(leftLineMargin, passwordTextField.frame.maxY, textLineWidth, 2.0)
        
		loginButton.frame = CGRect(leftTextMargin, passwordTextField.frame.maxY + kRescountsButtonDetails.topPadding, kTextFieldDetails.width, kRescountsButtonDetails.height)
		
		orLabel.frame = CGRect(self.view.frame.width/2 - kOrLabelDetails.width/2, loginButton.frame.maxY + kOrLabelDetails.topPadding, kOrLabelDetails.width, kOrLabelDetails.height)
		
		fbLoginButton.frame = CGRect(leftTextMargin, orLabel.frame.maxY + kOrLabelDetails.bottomPadding, kTextFieldDetails.width, kFBGOLoginButtonDetails.height)
		
		goLoginButton.frame = CGRect(leftTextMargin, fbLoginButton.frame.maxY + kFBGOLoginButtonDetails.bottomPadding, kTextFieldDetails.width + 6, kFBGOLoginButtonDetails.height)
		
        
        if #available(iOS 13.0, *) {
              let appleButton = ASAuthorizationAppleIDButton()
//              appleButton.translatesAutoresizingMaskIntoConstraints = false
              view.addSubview(appleButton)
                appleButton.frame = CGRect(leftTextMargin, goLoginButton.frame.maxY + kFBGOLoginButtonDetails.bottomPadding, kTextFieldDetails.width + 6, kFBGOLoginButtonDetails.height)
            forgotPasswordButton.frame = CGRect(0.0, appleButton.frame.maxY + /*kSignUpButtonDetails.topPadding*/ kFBGOLoginButtonDetails.bottomPadding, view.frame.width, kSignUpButtonDetails.lineHeight + 8.0)
            appleButton.addAction(for: .touchUpInside) { [weak self] in
                self?.tappedAppleButton()
            }

          } else {
              forgotPasswordButton.frame = CGRect(0.0, goLoginButton.frame.maxY + /*kSignUpButtonDetails.topPadding*/ kFBGOLoginButtonDetails.bottomPadding, view.frame.width, kSignUpButtonDetails.lineHeight + 8.0)
      
            
        }
   
        
        if forgotPasswordButton.isHidden {
                  signUpButton.frame = forgotPasswordButton.frame
              } else {
                  signUpButton.frame = CGRect(0.0, forgotPasswordButton.frame.maxY, view.frame.width, kSignUpButtonDetails.lineHeight)
              }

		
		tapCatchingView.frame = CGRect(0,0,self.view.frame.width, self.view.frame.height)
	}
	
	
	// MARK: - UITextfield setup
    @available(iOS 13.0, *)
    @objc
    func tappedAppleButton() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName,.email]
        
        let controller  =  ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
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
	}
	
	@objc func keyboardWillHide(notification: NSNotification){
		self.view.frame.origin.y = 0
		//tapCatchingView.removeFromSuperview()
		tapCatchingView.isHidden = true
	}
	
	
    // MARK: - Private Helpers
	//UNREVIEWED TAG
	private func tappedLogin() {
		if let email = emailTextField.text, let password = passwordTextField.text {
			UserService.login(email: email, password: password, callback: { (user, error) in
				if let error = error {
					RescountsAlert.showAlert(title: l10n("loginErrorTitle"), text: error.localizedDescription)
					print(error.localizedDescription)
					return
				}
				// The 'loggedIn' notification will move us to the next screen
			})
		}
	}
	
    private func tappedSignUp() {
        navigationController?.popToRootViewController(animated: true)
    }

    private func addLineToView(view : UIView, color: UIColor, width: Double) {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false // This is important!
        view.addSubview(lineView)

        let metrics = ["width" : NSNumber(value: width)]
        let views = ["lineView" : lineView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options:NSLayoutFormatOptions(rawValue: 0), metrics:metrics, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(width)]|", options:NSLayoutFormatOptions(rawValue: 0), metrics:metrics, views:views))
    }
	
	private func setButtonCornerRadius(_ view: UIView) {
		view.layer.cornerRadius = 10
		view.layer.masksToBounds = true
	}
	
	@objc private func loggedIn() {
		moveToLoadingScreen()
	}
	
	private func moveToLoadingScreen() {
		navigationController?.pushViewController(LoadingViewController(), animated: true)
	}
	
	// MARK: - LoginButtonDelegate
	
	func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
		print("Logged in: \(String(describing:AccessToken.current))  --  \(AccessToken.current?.authenticationToken ?? "nope")")
		if let fbToken = AccessToken.current?.authenticationToken {
			UserService.login(fbToken: fbToken) { (user, error) in
				if let error = error {
					RescountsAlert.showAlert(title: l10n("loginErrorTitle"), text: error.localizedDescription)
					print(error.localizedDescription)
					return
				}
			}
		}
	}
	
	func loginButtonDidLogOut(_ loginButton: LoginButton) {
		
	}
}


@available(iOS 13.0, *)
extension LoginViewController: ASAuthorizationControllerDelegate {

    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        

        switch authorization.credential {
        case let credentials as ASAuthorizationAppleIDCredential:
//            print(credentials.fullName!)
//            print(credentials.email!)
//            print(credentials.identityToken!.base64EncodedString())
            guard let appleToken = credentials.identityToken?.base64EncodedString() else {
                return
            }
            UserService.login(appleToken: appleToken) { (user, error) in
                    if let error = error {
                        RescountsAlert.showAlert(title: l10n("loginErrorTitle"), text: error.localizedDescription)
                        print(error.localizedDescription)
                        return
                    }
                }
            
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("somrthing happened" ,error)
    }
}
@available(iOS 13.0, *)
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    
}

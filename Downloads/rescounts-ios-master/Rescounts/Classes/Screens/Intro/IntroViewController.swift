//
//  IntroViewController.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-06.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import GoogleSignIn
import AuthenticationServices

class IntroViewController: UIViewController, UIScrollViewDelegate, LoginButtonDelegate, GIDSignInUIDelegate {

	private let rescountLogoImageView = UIImageView(image: UIImage(named: "logoLogin"))
	
	let carouselImageViews = [UIImageView(image: UIImage(named: "slide1")),
							  UIImageView(image: UIImage(named: "slide2")),
							  UIImageView(image: UIImage(named: "slide3")),
							  UIImageView(image: UIImage(named: "slide4")),
							  UIImageView(image: UIImage(named: "slide5")),
							  UIImageView(image: UIImage(named: "slide6")),
							  UIImageView(image: UIImage(named: "slide7"))]
	let carouselText = [l10n("carousel1"),
						l10n("carousel2"),
						l10n("carousel3"),
						l10n("carousel4"),
						l10n("carousel5"),
						l10n("carousel6"),
						l10n("carousel7")]
	var currentTextIndex: Int = -1
	
	let carousel = UIScrollView()
	let dots = UIPageControl()
	let carouselLabel = UILabel()
	let fbButt  = LoginButton(readPermissions: [ .publicProfile, .email ])
	let gooButt = GIDSignInButton(frame: .arbitrary)
	let resButt = UIButton(type: .custom)
	let logButt = UIButton(type: .custom)
	let skpButt = UIButton(type: .custom)
	
	let kMinCarouselMargin: CGFloat = 25
	let kTextMargin: CGFloat = 8
	let kDotsHeight: CGFloat = 20
	let kDotsVerticalSpacer: CGFloat = 10
	let kButtonHeight: CGFloat = 44
	let kLineButtonHeight: CGFloat = 30
	let kLogoHeight: CGFloat = 44
	
	
	// MARK: - View Controller Methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .white
		self.automaticallyAdjustsScrollViewInsets = false
		
		setupLogo()
		setupCarousel()
		setupButtons()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(loggedIn), name: .loggedIn, object: nil)
		
		navigationController?.setNavigationBarHidden(true, animated: true)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: .loggedIn, object: nil)
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		let topMargin: CGFloat = view.frame.width < 350 ? 20 : 40
		rescountLogoImageView.frame = CGRect(0, topMargin, view.frame.width, kLogoHeight)
		
		let carouselScalar: CGFloat = view.frame.width < 350 ? 0.3 : 0.35
		let carouselWidth = floor(min(view.frame.height * carouselScalar, view.frame.width - 2*kMinCarouselMargin))
		let carouselMargin = floor((view.frame.width - carouselWidth) / 2)
		let carouselHalfMargin = floor(carouselMargin / 2)
		carousel.frame = CGRect(carouselHalfMargin, rescountLogoImageView.frame.maxY + kMinCarouselMargin, view.frame.width - carouselMargin, carouselWidth)
		carousel.contentSize = CGSize(carousel.frame.width * CGFloat(carouselImageViews.count), carousel.frame.height)
		
		for (i,v) in carouselImageViews.enumerated() {
			v.frame = CGRect(CGFloat(i) * (carouselWidth + carouselMargin) + carouselHalfMargin, 0, carouselWidth, carouselWidth)
		}
		
		dots.frame = CGRect(carouselMargin, carousel.frame.maxY + kDotsVerticalSpacer, carouselWidth, kDotsHeight)
		
		carouselLabel.frame = CGRect(kTextMargin, dots.frame.maxY + kDotsVerticalSpacer, view.frame.width - 2*kTextMargin, 40)
		
		let buttonAreaTopY = carouselLabel.frame.maxY
		let buttonAreaHeight = view.frame.height - buttonAreaTopY
		let buttonHeight = min(kButtonHeight, floor(buttonAreaHeight / 6))
		let lineButtonHeight = min(kLineButtonHeight, floor(buttonAreaHeight / 6))
		let buttWidth = view.frame.width - 2*kMinCarouselMargin
		let buttonVMargin = floor((buttonAreaHeight - 5*buttonHeight) / 6)
		let buttonHMargin = floor((view.frame.width - buttWidth) / 2)
		
		resButt.frame = CGRect(x: buttonHMargin, y: buttonAreaTopY + buttonVMargin,        width: buttWidth, height: buttonHeight)
		fbButt.frame  = CGRect(x: buttonHMargin, y: resButt.frame.maxY + buttonVMargin,    width: buttWidth, height: buttonHeight)
		gooButt.frame = CGRect(x: buttonHMargin - 3, y: fbButt.frame.maxY + buttonVMargin, width: buttWidth + 6, height: buttonHeight)
        
        
                if #available(iOS 13.0, *) {
                      let appleButton = ASAuthorizationAppleIDButton()
        //              appleButton.translatesAutoresizingMaskIntoConstraints = false
                      view.addSubview(appleButton)
                        appleButton.frame =  CGRect(x: buttonHMargin, y: gooButt.frame.maxY + buttonVMargin,                width: buttWidth, height: buttonHeight)
                    appleButton.addAction(for: .touchUpInside) { [weak self] in
                        self?.tappedAppleButton()
                    }
                    
                    logButt.frame = CGRect(x: buttonHMargin, y: appleButton.frame.maxY + 2,                width: buttWidth, height: lineButtonHeight)
                    skpButt.frame = CGRect(x: buttonHMargin, y: logButt.frame.maxY + 2,                width: buttWidth, height: lineButtonHeight)

                  } else {
                       logButt.frame = CGRect(x: buttonHMargin, y: gooButt.frame.maxY + 2,                width: buttWidth, height: lineButtonHeight)
                      skpButt.frame = CGRect(x: buttonHMargin, y: logButt.frame.maxY + 2,                width: buttWidth, height: lineButtonHeight)
                }
        
        

	}
	
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
	// MARK: - UI Setup
	
	private func setupLogo() {
		rescountLogoImageView.contentMode = .scaleAspectFit
		rescountLogoImageView.backgroundColor = .clear;
		view.addSubview(rescountLogoImageView)
	}
	
	private func setupCarousel() {
		for v in carouselImageViews {
			carousel.addSubview(v)
		}
		
		carousel.backgroundColor = .clear
		carousel.isPagingEnabled = true
		carousel.clipsToBounds = false
		carousel.delegate = self
		carousel.showsHorizontalScrollIndicator = false
		view.addSubview(carousel)
		
		dots.pageIndicatorTintColor = .lightGrayText
		dots.currentPageIndicatorTintColor = .gold
		dots.numberOfPages = carouselImageViews.count
		dots.addAction(for: .valueChanged) { [weak self] in
			self?.updateCarouselPosition()
			self?.updateCarouselText()
		}
		view.addSubview(dots)
		
		carouselLabel.backgroundColor = .clear
		carouselLabel.textColor = .dark
		carouselLabel.font = UIFont.lightRescounts(ofSize: 15)
		carouselLabel.textAlignment = .center
		carouselLabel.numberOfLines = 2
		carouselLabel.minimumScaleFactor = 0.8
		carouselLabel.adjustsFontSizeToFitWidth = true
		view.addSubview(carouselLabel)
		
		updateCarouselText()
	}
	
	private func setupButtons() {
		setupButton(resButt, title: l10n("createAccount").uppercased(), action: tappedRescounts)
		setupButton(logButt, title: l10n("haveAccountSignIn"), textColour: .dark, colour: .clear, action: tappedLogin)
		setupButton(skpButt, title: l10n("skipSignIn"), textColour: .dark, colour: .clear, action: tappedSkip)
		
		fbButt.delegate = self
		setButtonCornerRadius(fbButt)
		view.addSubview(fbButt)
		
		gooButt.colorScheme = .light
		gooButt.style = .wide
		setButtonCornerRadius(gooButt)
		view.addSubview(gooButt)
		GIDSignIn.sharedInstance().uiDelegate = self
		
		logButt.applyAttributes([.foregroundColor: UIColor.primary], toSubstring: l10n("login"))
		skpButt.applyAttributes([.foregroundColor: UIColor.primary], toSubstring: "Skip" )
	}
	
	private func setupButton(_ button: UIButton, title: String, textColour: UIColor = .dark, colour: UIColor = .gold, action: @escaping ()->()) {
		button.setTitle(title, for: .normal)
		button.addAction(for: .touchUpInside, action)
		button.setTitleColor(textColour, for: .normal)
		button.setBackgroundImage(UIImage(color: colour), for:.normal)
		button.titleLabel?.font = UIFont.lightRescounts(ofSize: 15)
		setButtonCornerRadius(button)
		view.addSubview(button)
	}
	
	private func setButtonCornerRadius(_ view: UIView) {
		view.layer.cornerRadius = 10
		view.layer.masksToBounds = true
	}
	
	private func updateCarouselText() {
		let index = dots.currentPage
		
		if (currentTextIndex != index) {
			currentTextIndex = index
			
			if (0..<carouselText.count).contains(index) {
				let boldedText = attributedStringForBoldTags( carouselText[index] )
				
				UIView.animate(withDuration: 0.1, animations: { [weak self] in
					
					// Fade out old text
					self?.carouselLabel.alpha = 0
					
				}) { [weak self] (completed) in
					
					// Fade in new text
					self?.carouselLabel.attributedText = boldedText
					UIView.animate(withDuration: 0.1) { [weak self] in
						self?.carouselLabel.alpha = 1
					}
				}
			}
		}
	}
	
	private func attributedStringForBoldTags(_ str: String) -> NSAttributedString {
		var text = NSMutableAttributedString(string: str)
		
		// Find bold tags
		let regex = try? NSRegularExpression(pattern: "<b>.*</b>", options: .caseInsensitive)
		let matches = regex?.matches(in: text.string, range: NSMakeRange(0, text.string.count))
		
		matches?.forEach { (match) in
			// Remove the tags
			let oldRange = Range(match.range, in: str)!
			var replacementText = String(str[oldRange])
			replacementText = replacementText.replacingOccurrences(of: "<b>", with: "")
			replacementText = replacementText.replacingOccurrences(of: "</b>", with: "")
			
			// And apply the bold effect to the updated range (with tags removed)
			let newNSRange = NSMakeRange(match.range.location, replacementText.count)
			text = NSMutableAttributedString(string: str.replacingCharacters(in: oldRange, with: replacementText))
			text.addAttribute(NSAttributedStringKey.font, value: UIFont.rescounts(ofSize: 15), range: newNSRange)
			
		}
		return text
	}
	
	
	// MARK: UIScrollView Delegate
	
	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		dots.currentPage = Int((carousel.contentOffset.x / carousel.frame.width) + 0.1)
		updateCarouselText()
	}
	
	
	// MARK: - Private Helpers
	
	func tappedRescounts() {
		let vc = SignUpViewController()
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	func tappedLogin() {
		let vc = LoginViewController()
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	func tappedSkip() {
		if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
			AccountManager.main.clearLoginInfo()
			appDelegate.switchToMainScreens(fromVC: self)
		}
	}
	
	private func updateCarouselPosition() {
		self.carousel.scrollRectToVisible(CGRect(CGFloat(dots.currentPage) * carousel.frame.width, 0, carousel.frame.width, carousel.frame.height), animated: true)
	}
	
	@objc private func loggedIn() {
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
extension IntroViewController: ASAuthorizationControllerDelegate {

    
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
extension IntroViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    
}

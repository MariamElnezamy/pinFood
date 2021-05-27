//
//  CompleteSignupViewController.swift
//  Rescounts
//
//  Created by Kit Xayasane on 2018-08-26.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import Stripe
import PassKit

class PaymentMethodsViewController: BaseViewController, STPAddCardViewControllerDelegate {

    private let completeButton = RescountsButton()

    private let addPaymentLabel = UILabel()
    private let creditCardIcon = UIImageView(image: UIImage(named: "imgAddpayment"))
    private let creditCardLabel = UILabel()
    private let creditCardImageA = UIImageView(image: UIImage(named: "MasterCard"))
    private let creditCardImageB = UIImageView(image: UIImage(named: "Visa"))
	private let creditCardImageC = UIImageView(image: UIImage(named: "visa debit logo"))
	private let creditCardButton = UIControl()
    private let applePayIcon = UIImageView(image: UIImage(named: "imgAddpayment"))
	private let stripeIcon = UIImageView(image: UIImage(named: "powered_by_stripe"))
    private let applePayLabel = UILabel()
	private let applePayButton = UIControl()
	
	private let instruction = UILabel()

	private var paymentOptionSelectedView = UIView() // This is the view for user who selected the payment options already
    private let paymentIcon : UIImageView = UIImageView()
	private let paymentTextLabel : UILabel = UILabel()
	private let paymentEditButton : UILabel = UILabel()
	private let paymentSeparator : UIView = UIView()
	private let removePaymentMethodButton : UILabel = UILabel()
	
	
    private let kTextFieldDetails: (width: CGFloat, height: CGFloat, topPadding: CGFloat) = (200.0, 40.0, 10.0)
    private let kCompleteButtonDetails: (sidePadding: CGFloat, bottomPadding: CGFloat, height: CGFloat, text: String, font: UIFont) = (53, 41, 51, l10n("complete").uppercased(), UIFont.rescounts(ofSize: 15.0))
    private let kAddPaymentDetails: (topPadding: CGFloat, sidePadding: CGFloat, lineHeight: CGFloat, font: UIFont, color: UIColor, text: String) = (100.0, 34.0, 16.0, UIFont.lightRescounts(ofSize: 15.0), UIColor.primary, l10n("addPayment").uppercased())
    private let kAddPaymentIconDetails: (height: CGFloat, topPadding: CGFloat, sidePadding: CGFloat) = (23, 20, 34)
    private let kCreditCardImageDetails: (lineHeight: CGFloat, sidePadding: CGFloat) = (20, 26)
    private let kCreditCardLabelDetails: (lineHeight: CGFloat, sidePadding: CGFloat, font: UIFont, textColor: UIColor, text: String) = (20, 26, UIFont.rescounts(ofSize: 15.0), UIColor.nearBlack, l10n("creditCard"))
    private let kApplePayCardLabelDetails: (lineHeight: CGFloat, sidePadding: CGFloat, font: UIFont, textColor: UIColor, text: String) = (20, 26, UIFont.rescounts(ofSize: 15.0), UIColor.nearBlack, l10n("applePay"))
	private let kInstructionDetails : (width: CGFloat, topPadding : CGFloat, bottomPadding: CGFloat) = (300,30, 30)
	public var displayState = DisplayState.profile
	
	private let kButtonPadding: CGFloat = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = l10n("paymentMethod").uppercased()
        self.view.backgroundColor = .white
		
        
        addPaymentLabel.font = kAddPaymentDetails.font
        addPaymentLabel.textColor = kAddPaymentDetails.color
        addPaymentLabel.text = kAddPaymentDetails.text
        view.addSubview(addPaymentLabel)
		
		// Credit Card
        view.addSubview(creditCardIcon)
        
        creditCardLabel.font = kCreditCardLabelDetails.font
        creditCardLabel.textColor = kCreditCardLabelDetails.textColor
        creditCardLabel.text = kCreditCardLabelDetails.text
        view.addSubview(creditCardLabel)
        
        creditCardImageA.contentMode = .scaleAspectFit
        view.addSubview(creditCardImageA)
        creditCardImageB.contentMode = .scaleAspectFit
        view.addSubview(creditCardImageB)
		creditCardImageC.contentMode = .scaleAspectFit
		view.addSubview(creditCardImageC)
		
		creditCardButton.addAction(for: .touchUpInside, tappedCreditCard)
		view.addSubview(creditCardButton)
		
		// Apple Pay
        view.addSubview(applePayIcon)
		
        applePayLabel.font = kApplePayCardLabelDetails.font
        applePayLabel.textColor = kApplePayCardLabelDetails.textColor
        applePayLabel.text = kApplePayCardLabelDetails.text
        view.addSubview(applePayLabel)
		
		applePayButton.addAction(for: .touchUpInside, tappedApplePay)
		view.addSubview(applePayButton)
		
		stripeIcon.contentMode = .scaleAspectFit
		view.addSubview(stripeIcon)
		
		if displayState == DisplayState.signup {
			setupInstruction()
			view.addSubview(instruction)
			
			completeButton.setTitle(kCompleteButtonDetails.text, for: .normal)
			completeButton.titleLabel?.font = kCompleteButtonDetails.font
			completeButton.addAction(for: .touchUpInside) { [weak self] in
				let loadingVC = LoadingViewController()
				self?.navigationController?.pushViewController(loadingVC, animated: true)
			}
			view.addSubview(completeButton)
		}
		
		setUpPaymentMethodSelectedView()
		view.addSubview(paymentOptionSelectedView)
		
		updateButtonTitle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		
        navigationController?.setNavigationBarHidden(false, animated: true)
		navigationController?.navigationBar.backgroundColor = .dark
		navigationController?.navigationBar.barTintColor = .dark
		navigationController?.navigationBar.tintColor = .white
		navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
		navigationController?.navigationBar.barStyle = .black
		
		setUpPaymentMethodSelectedView()
		updateButtonTitle()
    }

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
        addPaymentLabel.frame = CGRect(kAddPaymentDetails.sidePadding,   kAddPaymentDetails.topPadding, view.frame.width - kAddPaymentDetails.sidePadding, kAddPaymentDetails.lineHeight)
        
        creditCardIcon.frame = CGRect(kAddPaymentIconDetails.sidePadding, addPaymentLabel.frame.maxY + kAddPaymentIconDetails.topPadding - 2.0, kAddPaymentIconDetails.height, kAddPaymentIconDetails.height)
        
        creditCardLabel.frame = CGRect(creditCardIcon.frame.maxX + kCreditCardLabelDetails.sidePadding, creditCardIcon.frame.midY - kCreditCardLabelDetails.lineHeight/2, self.view.frame.width - (creditCardIcon.frame.maxX + kCreditCardLabelDetails.sidePadding), kApplePayCardLabelDetails.lineHeight)
        creditCardLabel.sizeToFit()
        
        creditCardImageA.frame = CGRect(creditCardLabel.frame.maxX + kCreditCardImageDetails.sidePadding, creditCardLabel.frame.minY - 5, 30, 30)
        creditCardImageB.frame = CGRect(creditCardImageA.frame.maxX + kCreditCardImageDetails.sidePadding / 2, creditCardLabel.frame.minY - 5, 30, 30)
		creditCardImageC.frame = CGRect(creditCardImageB.frame.maxX + kCreditCardImageDetails.sidePadding / 2, creditCardLabel.frame.minY - 5, 30, 30)
		
		var buttOrigin = CGPoint(creditCardIcon.frame.minX - kButtonPadding, creditCardIcon.frame.minY - kButtonPadding)
		creditCardButton.frame = CGRect(buttOrigin.x, buttOrigin.y, creditCardImageC.frame.maxX + kButtonPadding - buttOrigin.x, creditCardIcon.frame.maxY + kButtonPadding - buttOrigin.y)
        
        applePayIcon.frame = CGRect(kAddPaymentIconDetails.sidePadding, creditCardIcon.frame.maxY + kAddPaymentIconDetails.topPadding, kAddPaymentIconDetails.height, kAddPaymentIconDetails.height)
        
        applePayLabel.frame = CGRect(applePayIcon.frame.maxX + kApplePayCardLabelDetails.sidePadding, applePayIcon.frame.midY - kApplePayCardLabelDetails.lineHeight/2, self.view.frame.width - (applePayIcon.frame.maxX + kApplePayCardLabelDetails.sidePadding), kApplePayCardLabelDetails.lineHeight)
        applePayLabel.sizeToFit()
		
		buttOrigin = CGPoint(applePayIcon.frame.minX - kButtonPadding, applePayIcon.frame.minY - kButtonPadding)
		applePayButton.frame = CGRect(buttOrigin.x, buttOrigin.y, creditCardImageC.frame.maxX + kButtonPadding - buttOrigin.x, applePayIcon.frame.maxY + kButtonPadding - buttOrigin.y)
		
		instruction.frame = CGRect(view.frame.width/2.0 - kInstructionDetails.width/2.0, applePayLabel.frame.maxY + kInstructionDetails.topPadding, kInstructionDetails.width , getInstructionHeight())
		
		//Layout for payment method selection view
		paymentOptionSelectedView.frame = CGRect(0,creditCardIcon.frame.minY - kButtonPadding, view.frame.width, 100)
        paymentIcon.frame = CGRect(kAddPaymentDetails.sidePadding, -6, 30, 30)
		paymentTextLabel.frame = CGRect(paymentIcon.frame.maxX + 30 ,0, view.frame.width, 20)
		paymentEditButton.frame = CGRect(0, 0, view.frame.width - kAddPaymentDetails.sidePadding, 20)
		paymentSeparator.frame = CGRect(0, paymentTextLabel.frame.maxY + 10, view.frame.width , Constants.Menu.separatorHeight)
		removePaymentMethodButton.frame = CGRect(0, paymentSeparator.frame.maxY + 10, view.frame.width, 20)
		
		let stripeWidth = view.frame.width / 2
		let stripeY = (displayState == DisplayState.signup) ? instruction.frame.maxY + 25 : applePayLabel.frame.maxY + 50
		stripeIcon.frame = CGRect(floor((view.frame.width - stripeWidth)/2), stripeY, stripeWidth, 50)
        
        let completeButtonWidth = view.frame.width - (2.0 * kCompleteButtonDetails.sidePadding)
        completeButton.frame = CGRect(self.view.frame.width/2 - completeButtonWidth/2, view.frame.maxY - kCompleteButtonDetails.bottomPadding - kCompleteButtonDetails.height, completeButtonWidth, kCompleteButtonDetails.height)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Private Helpers
    
	private func setupInstruction() {
		instruction.text = l10n("paymentIns")
		instruction.textAlignment =  .center
		instruction.numberOfLines = 0
		instruction.font = UIFont.lightRescounts(ofSize: 15)
		instruction.textColor = UIColor.nearBlack
	}
    
	private func tappedApplePay() {
		print("Clicked the tapped apple pay")
		if !PaymentManager.main.checkIfApplePayCardsConfigured() {
			RescountsAlert.showAlert(title: l10n("applePayWarnTitle"), text: l10n("applePayNoCard"), callback: nil)
		} else {
			if !PaymentManager.main.checkIfApplePayDeviceAllowed() {
				RescountsAlert.showAlert(title: l10n("applePayWarnTitle"), text: l10n("applePayNoDevice"), callback: nil)
			} else {
				// We will do apple pay
				
				UserService.updatePaymentMethod(method: Constants.PaymentOption.apple) { (user, error) in
					if (error != nil) {
						RescountsAlert.showAlert(title: l10n("applePayErrorTitle"), text: l10n("applePayErrorText"))
						
					} else {
						print("Apple: \(PaymentManager.main.applePayOption)")
						RescountsAlert.showAlert(title: l10n("succeeded"), text: l10n("applePaySetUpText"))
						self.notifyPaymentMethodView(applePay: PaymentManager.main.applePayOption)
						self.paymentOptionSelectedView.isHidden = false

						if let trackingDict = GAIDictionaryBuilder.createEvent(withCategory: "action", action: "added_payment_method", label: "apple", value: nil)?.build() as? [AnyHashable : Any] {
							GAI.sharedInstance()?.defaultTracker.send(trackingDict)
						}
					}
					self.updateButtonTitle()
				}
			}
		}

	}
	
	private func tappedCreditCard() {
		
		// Goto the view
		
		// Setup add card view controller
		let addCardViewController = CreditCardVC()
		//addCardViewController.delegate = self
        addCardViewController.onVCDismiss = { [weak self] in
            DispatchQueue.main.async { [weak self] in
                let vc = self?.navigationController?.viewControllers.filter{$0.isKind(of: BrowseViewController.self)}.first ?? UIViewController()
                self?.navigationController?.popToViewController(vc, animated: false)
            }
        }
		// Present add card view controller
		let navigationController = UINavigationController(rootViewController: addCardViewController)
		present(navigationController, animated: true)
		
	}
	
	private func getInstructionHeight () -> CGFloat{
		let descriptionHeight = instruction.sizeThatFits(CGSize(kInstructionDetails.width, 1000)).height
		return descriptionHeight
	}
	
	
	private func setUpPaymentMethodSelectedView() {
		
		paymentOptionSelectedView.addSubview(paymentIcon)
		
		paymentTextLabel.textColor = UIColor.darkGray
		paymentTextLabel.font = UIFont.lightRescounts(ofSize: 16)
		paymentOptionSelectedView.addSubview(paymentTextLabel)
		paymentOptionSelectedView.backgroundColor = UIColor.white
		
		paymentEditButton.text = l10n("paymentEdit")
		paymentEditButton.textColor = UIColor.highlightRed
		paymentEditButton.textAlignment = .right
		let tappedEditGesture = UITapGestureRecognizer(target: self, action: #selector(tappedEdit))
		paymentEditButton.addGestureRecognizer(tappedEditGesture)
		paymentEditButton.isUserInteractionEnabled = true
		paymentOptionSelectedView.isUserInteractionEnabled = true
		paymentOptionSelectedView.addSubview(paymentEditButton)
		
		paymentSeparator.backgroundColor = UIColor.separators
		paymentOptionSelectedView.addSubview(paymentSeparator)
		
		removePaymentMethodButton.text = l10n("removePayment")
		removePaymentMethodButton.textColor = UIColor.highlightRed
		removePaymentMethodButton.textAlignment = .center
		let tappedRemoveGesture = UITapGestureRecognizer(target: self, action: #selector(tappedRemove))
		removePaymentMethodButton.addGestureRecognizer(tappedRemoveGesture)
		removePaymentMethodButton.isUserInteractionEnabled = true
		paymentOptionSelectedView.addSubview(removePaymentMethodButton)
		
		
		if ((AccountManager.main.user?.card == nil )&&(!PaymentManager.main.applePayOption) ){
			//If the credit card is nil and is non-apple pay user, that means the payment method hasn't been setup or removed
			paymentOptionSelectedView.isHidden = true
		} else if ((!PaymentManager.main.applePayOption) && (AccountManager.main.user?.card != nil)) {
			//This is a credit card user
			paymentOptionSelectedView.isHidden = false
			paymentIcon.image = UIImage(named: "CreditCard")
			paymentTextLabel.text = "\( AccountManager.main.user?.card?.brand ?? "") xxxx\( AccountManager.main.user?.card?.last4 ?? "")"
			
		} else if (PaymentManager.main.applePayOption){
			//Apple pay user
			paymentOptionSelectedView.isHidden = false
			paymentIcon.image = UIImage(named: "ApplePay")
			paymentTextLabel.text = l10n("applePay")
		} else {
			//Doing nothing
			paymentOptionSelectedView.isHidden = false
			paymentTextLabel.text = "Bug here should pause here and check which payment method this user using"
		}
	
	}
	
	private func notifyPaymentMethodView(applePay: Bool){
		if (applePay){
			paymentIcon.image = UIImage(named: "ApplePay")
			paymentTextLabel.text = l10n("applePay")
		} else {
			paymentIcon.image = UIImage(named: "CreditCard")
			paymentTextLabel.text = "\( AccountManager.main.user?.card?.brand ?? "") xxxx\( AccountManager.main.user?.card?.last4 ?? "")"
			
		}
	}
	
	private func updateButtonTitle() {
		let hasMethod = (AccountManager.main.user?.card != nil || PaymentManager.main.applePayOption)
		completeButton.setTitle(hasMethod ? kCompleteButtonDetails.text : l10n("skipPaymentSelection").uppercased(), for: .normal)
	}
	
	@objc private func tappedEdit () {
		paymentOptionSelectedView.isHidden = true
	}
	@objc private func tappedRemove() {
		//When delete a payment method, we should set the paymentMethod - "CreditCard" as default and tokenID - "Delete_all_token"
		
		FullScreenSpinner.show()
		UserService.updatePaymentMethod(method: Constants.PaymentOption.credit, tokenID: Constants.PaymentOption.cleanUpToken) { (user, error) in
			FullScreenSpinner.hideAll()
			
			if error != nil {
				
			} else {
				AccountManager.main.user?.card = nil //Remove the card info
				PaymentManager.main.applePayOption = false //Set up the value to be default value
				self.paymentOptionSelectedView.isHidden = true
			}
		}
		updateButtonTitle()
	}
	

	
	
	// MARK: STPAddCardViewControllerDelegate
	
	func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
		// Dismiss add card view controller
		dismiss(animated: true)
	}
	
	func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
		
		UserService.updatePaymentMethod(method: Constants.PaymentOption.credit, tokenID: token.tokenId) { (user, error) in
			if (error != nil) {
				RescountsAlert.showAlert(title: l10n("addPaymentErrorTitle"), text: l10n("addPaymentErrorText"), callback: nil)
				self.dismiss(animated: true, completion: nil)
			} else {
				RescountsAlert.showAlert(title: l10n("succeeded"), text: l10n("paymentAdded"), callback: nil)
				AccountManager.main.user?.stripeToken = token
				PaymentManager.main.applePayOption = false
				self.notifyPaymentMethodView(applePay: PaymentManager.main.applePayOption)
				self.paymentOptionSelectedView.isHidden = false

				if let trackingDict = GAIDictionaryBuilder.createEvent(withCategory: "action", action: "added_payment_method", label: "credit", value: nil)?.build() as? [AnyHashable : Any] {
					GAI.sharedInstance()?.defaultTracker.send(trackingDict)
				}

				self.dismiss(animated: true, completion: nil)
			}
		}
	}
	
	public enum DisplayState{
		case profile
		case signup
	}
}

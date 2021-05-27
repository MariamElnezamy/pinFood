//
//  FeedbackViewController.swift
//  Rescounts
//
//  Created by Kittiphong Xayasane on 2018-08-20.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import Stripe
import PassKit
import StoreKit


class FeedbackViewController: UIViewController, UITextViewDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	private var unreviewed: Bool //default: false. This feedbackViewController is not initially showing for unreviewed table. If it's true, we gonna hide setup for tip and show instruction labels.
	private var unreviewedView = UIView()
	private let unreviewedText = UILabel()
	private var unreviewedTotal = UILabel()
	private let unreviewedFirstSeparator = UIView()
	private let unreviewedSecondSeparator = UIView()
	
	private var fixedTip: Bool
	
	private var totalAmount : Int = 0
	
    private var tableID: String
	private let restaurantName: String // = ""
	private let serverName: String // = ""
	private let price: Int // = 0
	private var tipAmount: Int = 0
	private let scrollView = UIScrollView()
	private let navBarTinter = UIView()
	private let thanksLabel = UILabel()
	private let restaurantLabel = UILabel()
	private let rateServerLabel = UILabel()
	private let serverNameLabel = UILabel()
    private let serverRating = StarGroup(isSelectable: true)
    private let tipSelector = TipGroup()
	private let tipTextView = UITextView()
	private var tipCover: UIControl? = nil
	private let totalLabel = UILabel()
	private let firstSeparator = UIView()
	private let rateRestaurantLabel = UILabel()
	private let restaurantRating = StarGroup(isSelectable: true)
	private let secondSeparator = UIView()
	private let reviewTextView = UITextView()
	private let addPhotosLabel = UILabel()
	private let thirdSeparator = UIView()
	private let photoButtonGroup: [PhotoButton] = [PhotoButton(), PhotoButton(), PhotoButton()]
	private var activeField : UITextView?
	private let stripePublishableKey = Constants.Stripe.stripePublishableKey
	private let backendBaseURL: String? = Constants.Stripe.backendBaseURL
	private let appleMerchantID: String? = Constants.Stripe.appleMerchantID

    private let doneButton = RescountsFooterButton()
	private var photoButtonIndex: Int?
	
	private let kLineHeight: CGFloat = 18.0
	private let kPhotoButtonDetails: (size: CGFloat, sidePadding: CGFloat, topPadding: CGFloat) = (73.0, 13.0, 10.0)
	
	private let kThanksLabelDetails: (text: String, topPadding: CGFloat, font: UIFont, fontColor: UIColor) = (l10n("resThxTitle"), 16, UIFont.lightRescounts(ofSize: 15), UIColor.dark)
	private let kRestaurantLabelDetails: (text: String, topPadding: CGFloat, font: UIFont, fontColor: UIColor) = ("Le Restaurant", 0.0, UIFont.rescounts(ofSize: 15), UIColor.nearBlack)
	private let kRateServerLabelDetails: (text: String, topPadding: CGFloat, font: UIFont, fontColor: UIColor) = (l10n("rateServer"), 10.0, UIFont.lightRescounts(ofSize: 13), UIColor.dark)
	private let kServerNameLabelDetails: (text: String, topPadding: CGFloat, font: UIFont, fontColor: UIColor) = ("LUKE", 0.0, UIFont.rescounts(ofSize: 15), UIColor.nearBlack)
	private let kServerRatingDetails: (size: CGFloat, topPadding: CGFloat, onColor: UIColor, maxValue: Int) = (38.0, 4.0, UIColor.gold, 5)
	private let kTipSelectorDetails: (height: CGFloat, topPadding: CGFloat) = (46.0, 16.0)
	private let kTipTextViewDetails: (width: CGFloat, height: CGFloat, topPadding: CGFloat, backgroundColor: UIColor, font: UIFont, placeholderText: String, prefixText: String) = (207, 42, 13, UIColor.lighterGray, .lightRescounts(ofSize: 20.0), l10n("tipFormat"), "")
	private let kFirstSeparatorDetails: (color: UIColor, height: CGFloat, topPadding: CGFloat) = (UIColor.separators, 2.0, 10.0)
	private let kRateRestaurantLabelDetails: (text: String, topPadding: CGFloat, font: UIFont, fontColor: UIColor) = (l10n("rateRes"), 12.0, UIFont.lightRescounts(ofSize: 14), UIColor.dark)
	private let kRestaurantRatingDetails: (size: CGFloat, topPadding: CGFloat, onColor: UIColor, maxValue: Int) = (40.0, 4.0, UIColor.gold, 5)
	private let kSecondSeparatorDetails: (color: UIColor, height: CGFloat, topPadding: CGFloat) = (UIColor.separators, 2.0, 13.0)
	private let kReviewTextViewDetails: (height: CGFloat, sidePadding: CGFloat, font: UIFont, textColor: UIColor, placeholdText: String, topPadding: CGFloat) = (100, 25, UIFont.lightRescounts(ofSize: 13), UIColor.lightGrayText, l10n("leaveReview"), 20)
	private let kThirdSeparatorDetails: (color: UIColor, height: CGFloat, topPadding: CGFloat) = (UIColor.separators, 2.0, 13.0)
	private let kAddPhotosLabelDetails: (font: UIFont, fontColor: UIColor, text: String, paddingLeft: CGFloat, paddingTop: CGFloat) = (UIFont.lightRescounts(ofSize: 13), UIColor.lightGrayText, l10n("add3Photos"), 25.0, 14.0)
	private let kDoneButtonDetails: (height: CGFloat, text: String, topPadding: CGFloat) = (51.0, "checkout".uppercased(), 30.0)
	private let kUnreviewedTextLeftPaddingLeft : CGFloat = 20.0
	private let kUnreviewedSeparatorHeight : CGFloat = 2.0
	
	
	private var reviewImageArray:[Int:UIImage] = [:]
	
	//MARK: - Initialization

	init(tableID: String, restaurantName: String, serverName: String,  price: Int, unreviewed: Bool = false, fixedTip: Bool = false) {
        self.tableID = tableID
        self.restaurantName = restaurantName
        self.serverName = serverName
        self.price = price
		self.unreviewed = unreviewed
		self.fixedTip = fixedTip

        super.init(nibName: nil, bundle:nil)
	}

	required init?(coder aDecoder: NSCoder) {
        self.tableID = ""
		self.restaurantName = ""
		self.serverName = ""
		self.price = 0
		self.unreviewed = false
		self.fixedTip = false
		super.init(coder:aDecoder)
	}

	// MARK: - UIView Methods

	override func viewDidLoad() {
        super.viewDidLoad()
		
		scrollView.isScrollEnabled = true
		scrollView.delegate = self
		let tap = UITapGestureRecognizer(target: self, action: #selector(tappedAnywhere))
		tap.cancelsTouchesInView = false
		scrollView.addGestureRecognizer(tap)
		view.addSubview(scrollView)
		view.backgroundColor = .white
		self.title = l10n("reviewPageTitle").uppercased()
		
		tipAmount = OrderManager.main.orders.getTip()
		//UNREVIEWED TAG
		if (!unreviewed) {
        	setupTipSelector()
		}
		setupLabel(thanksLabel,     text:kThanksLabelDetails.text,     font: kThanksLabelDetails.font,      colour: kThanksLabelDetails.fontColor)
		setupLabel(restaurantLabel, text:self.restaurantName,          font: kRestaurantLabelDetails.font,  colour: kRestaurantLabelDetails.fontColor)
		setupLabel(rateServerLabel, text:kRateServerLabelDetails.text, font: kRateServerLabelDetails.font,  colour: kRateServerLabelDetails.fontColor)
		setupLabel(serverNameLabel, text:self.serverName,              font: kServerNameLabelDetails.font,  colour: kServerNameLabelDetails.fontColor)
		//UNREVIEWED TAG
		if (!unreviewed) {
			setupTipTextView()
			setupLabel(totalLabel, text: "", font: kThanksLabelDetails.font, colour: kThanksLabelDetails.fontColor)
		} else {
			setupUnreviewedView()
		}
		setupLabel(rateRestaurantLabel, text:kRateRestaurantLabelDetails.text, font: kRateRestaurantLabelDetails.font, colour: kRateRestaurantLabelDetails.fontColor)
		
		setupSeparator()
		setupReviewTextView()
		setupLabel(addPhotosLabel, text:kAddPhotosLabelDetails.text, font: kAddPhotosLabelDetails.font, colour: kAddPhotosLabelDetails.fontColor)
		
       	setupServerRating()
		setupRestaurantRating()
		
		setupPhotoButtons()
		setupDoneButton()
		setupNavBarTinter()
		
		NotificationCenter.default.addObserver(self,
											   selector: #selector(keyboardDidShow(notification:)),
											   name: NSNotification.Name.UIKeyboardDidShow,
											   object: nil)

		NotificationCenter.default.addObserver(self,
											   selector: #selector(keyboardWillBeHidden(notification:)),
											   name: NSNotification.Name.UIKeyboardDidHide,
											   object: nil)
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "iconCancel"), style: .done, target: self, action: #selector(closeButtonTapped))
		
		updateTipAndTotal()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
		self.navigationController?.navigationBar.backgroundColor = .dark
		self.navigationController?.navigationBar.barTintColor = .dark
		self.navigationController?.navigationBar.tintColor = .white
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
		self.navigationController?.navigationBar.barStyle = .black
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		scrollView.flashScrollIndicators()
	}
    
    override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		let vw = view.frame.width
		navBarTinter.frame = CGRect(0, 0, vw, topLayoutGuide.length)
		
		scrollView.frame = view.frame
		
		let thanksLabelWidth = thanksLabel.text?.width(withConstrainedHeight: kLineHeight, font: kThanksLabelDetails.font) ?? 0
		thanksLabel.frame = CGRect(view.frame.width/2 - thanksLabelWidth/2, kThanksLabelDetails.topPadding, thanksLabelWidth, kLineHeight)
		
		let restaurantLabelWidth = restaurantLabel.text?.width(withConstrainedHeight: kLineHeight, font: kRestaurantLabelDetails.font) ?? 0
		restaurantLabel.frame = CGRect(view.frame.width/2 - restaurantLabelWidth/2, thanksLabel.frame.maxY + kRestaurantLabelDetails.topPadding, restaurantLabelWidth, kLineHeight)
		
		let rateServerLabelWidth = rateServerLabel.text?.width(withConstrainedHeight: kLineHeight, font: kRateServerLabelDetails.font) ?? 0
		rateServerLabel.frame = CGRect(view.frame.width/2 - rateServerLabelWidth/2, restaurantLabel.frame.maxY + kRateServerLabelDetails.topPadding, rateServerLabelWidth, kLineHeight)
		
		let serverNameLabelWidth = serverNameLabel.text?.width(withConstrainedHeight: kLineHeight, font: kServerNameLabelDetails.font) ?? 0
		serverNameLabel.frame = CGRect(view.frame.width/2 - serverNameLabelWidth/2, rateServerLabel.frame.maxY + kServerNameLabelDetails.topPadding, serverNameLabelWidth, kLineHeight)
		
		let serverRatingWidth = kServerRatingDetails.size * CGFloat(kServerRatingDetails.maxValue)
		serverRating.frame = CGRect(view.frame.width/2 - serverRatingWidth/2, serverNameLabel.frame.maxY + kServerRatingDetails.topPadding, serverRatingWidth, kServerRatingDetails.size)
		
		tipSelector.frame = CGRect(0.0, serverRating.frame.maxY + kTipSelectorDetails.topPadding, self.view.frame.width, CGFloat(kTipSelectorDetails.height)) //TODO: Temporary frame... will change
		
		tipTextView.frame = CGRect(view.frame.width/2 - kTipTextViewDetails.width/2, tipSelector.frame.maxY + kTipTextViewDetails.topPadding, kTipTextViewDetails.width, kTipTextViewDetails.height)
		totalLabel.frame = CGRect(0, tipTextView.frame.maxY, view.frame.width, 26)
		tipCover?.frame = CGRect(0, tipSelector.frame.minY, view.frame.width, totalLabel.frame.maxY - tipSelector.frame.minY)
		
		firstSeparator.frame = CGRect(0.0, totalLabel.frame.maxY + kFirstSeparatorDetails.topPadding, view.frame.width, kFirstSeparatorDetails.height)
		//UNREVIEWED TAG
		unreviewedFirstSeparator.frame = CGRect(0.0,0.0, view.frame.width, kUnreviewedSeparatorHeight)
		unreviewedView.frame = CGRect(0.0, serverRating.frame.maxY + kTipSelectorDetails.topPadding, view.frame.width, firstSeparator.frame.minY - (serverRating.frame.maxY + kTipSelectorDetails.topPadding))
		unreviewedText.frame = CGRect(kUnreviewedTextLeftPaddingLeft, unreviewedFirstSeparator.frame.maxY + 10.0, view.frame.width - kUnreviewedTextLeftPaddingLeft * 2,50)
		unreviewedSecondSeparator.frame = CGRect(0, unreviewedText.frame.maxY + 10.0, view.frame.width, kUnreviewedSeparatorHeight)
		unreviewedTotal.frame = CGRect(0, unreviewedSecondSeparator.frame.maxY, view.frame.width, firstSeparator.frame.minY - (unreviewedSecondSeparator.frame.maxY + unreviewedView.frame.minY))
		
		
		let rateRestaurantLabelWidth = rateRestaurantLabel.text?.width(withConstrainedHeight: kLineHeight, font: kRateRestaurantLabelDetails.font) ?? 0
		rateRestaurantLabel.frame = CGRect(view.frame.width/2 - rateRestaurantLabelWidth/2, firstSeparator.frame.maxY + kRateRestaurantLabelDetails.topPadding, rateRestaurantLabelWidth, kLineHeight)
		
		let restaurantRatingWidth = kRestaurantRatingDetails.size * CGFloat(kRestaurantRatingDetails.maxValue)
		restaurantRating.frame = CGRect(view.frame.width/2 - restaurantRatingWidth/2, rateRestaurantLabel.frame.maxY + kRestaurantRatingDetails.topPadding, restaurantRatingWidth, kRestaurantRatingDetails.size)
		
		secondSeparator.frame = CGRect(0.0, restaurantRating.frame.maxY + kSecondSeparatorDetails.topPadding, view.frame.width, kSecondSeparatorDetails.height)
		
		reviewTextView.frame = CGRect(kReviewTextViewDetails.sidePadding, secondSeparator.frame.maxY + kReviewTextViewDetails.topPadding, view.frame.width - kReviewTextViewDetails.sidePadding * 2.0, kReviewTextViewDetails.height - kReviewTextViewDetails.topPadding)
		
		
		thirdSeparator.frame = CGRect(0.0, reviewTextView.frame.maxY + kThirdSeparatorDetails.topPadding, view.frame.width, kThirdSeparatorDetails.height)
		
		let addPhotosLabelWidth = addPhotosLabel.text?.width(withConstrainedHeight: kLineHeight, font: kAddPhotosLabelDetails.font) ?? 0
		addPhotosLabel.frame = CGRect(kAddPhotosLabelDetails.paddingLeft, thirdSeparator.frame.maxY + kAddPhotosLabelDetails.paddingTop, addPhotosLabelWidth, kLineHeight)
		
		photoButtonGroup[1].frame = CGRect(view.frame.width/2 - kPhotoButtonDetails.size/2, addPhotosLabel.frame.maxY + kPhotoButtonDetails.topPadding, kPhotoButtonDetails.size, kPhotoButtonDetails.size)
		
		photoButtonGroup[0].frame = CGRect(photoButtonGroup[1].frame.origin.x - kPhotoButtonDetails.size - kPhotoButtonDetails.sidePadding, addPhotosLabel.frame.maxY + kPhotoButtonDetails.topPadding, kPhotoButtonDetails.size, kPhotoButtonDetails.size)
		
		photoButtonGroup[2].frame = CGRect(photoButtonGroup[1].frame.origin.x + kPhotoButtonDetails.size + kPhotoButtonDetails.sidePadding, addPhotosLabel.frame.maxY + kPhotoButtonDetails.topPadding, kPhotoButtonDetails.size, kPhotoButtonDetails.size)
		
		doneButton.frame = CGRect(0.0, photoButtonGroup[2].frame.maxY + kDoneButtonDetails.topPadding, view.frame.width, CGFloat(kDoneButtonDetails.height))
		
		scrollView.contentSize = CGSize(width: view.frame.width, height: doneButton.frame.maxY)
		
		
    }
	
	// MARK: - UITextView Methods
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if textView == tipTextView {
			let protectedRange = NSMakeRange(0, kTipTextViewDetails.prefixText.count)
			let intersection = NSIntersectionRange(protectedRange, range)
			if intersection.length > 0 {
				return false
			}
			if textView.text == "$0.00" {
				textView.text = text
				return false
			}
		}
		
		return true
	}
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		activeField = textView
		if textView == reviewTextView {
			if (textView.text == kReviewTextViewDetails.placeholdText) {
				textView.text = ""
				textView.textColor = UIColor.nearBlack
			}
			
			textView.becomeFirstResponder()
		}
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		activeField = nil
		if textView == reviewTextView {
			if (textView.text == "") {
				textView.text = kReviewTextViewDetails.placeholdText
				textView.textColor = UIColor.lightGrayText
			}
		}
		if let tipAmount = Double(tipTextView.text.replacingOccurrences(of: "$", with: "")) {
			self.tipAmount = CurrencyManager.main.getRawCost(decimalCost: tipAmount, currency: "CAD")
			updateTipAndTotal()
		} else {
			self.tipAmount = CurrencyManager.main.getRawCost(decimalCost: 0.0, currency: "CAD")
			updateTipAndTotal()
		}
		textView.endEditing(true)
	}
	
	// MARK: - Private Helper

	@objc private func closeButtonTapped() {
		dismiss(orderIsDone: false)
	}

	@objc private func tappedTextView() {
		// Assuming 'Other' is always last
		tipSelector.selectedIndex = tipSelector.tipViews.count - 1
		tipTextView.becomeFirstResponder()
	}

	@objc func keyboardDidShow(notification: NSNotification) {
		let userInfo: NSDictionary = notification.userInfo! as NSDictionary
		let keyboardInfo = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
		let keyboardSize = keyboardInfo.cgRectValue.size
		let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
		scrollView.contentInset = contentInsets
		scrollView.scrollIndicatorInsets = contentInsets

		var aRect: CGRect = view.frame
		aRect.size.height -= keyboardSize.height
		if let activeField = activeField {
			if !aRect.contains(activeField.frame.bottomCenter) {
				scrollView.scrollRectToVisible(activeField.frame, animated: true)
			}
		}
	}

	@objc func keyboardWillBeHidden(notification: NSNotification) {
		let contentInsets = UIEdgeInsets.zero
		
		UIView.animate(withDuration: 0.2) {
			self.scrollView.contentInset = contentInsets
			self.scrollView.scrollIndicatorInsets = contentInsets
		}
	}

	@objc private func tappedAnywhere() {
		view.endEditing(true)
	}

	private func setupSeparator() {
		firstSeparator.backgroundColor = kFirstSeparatorDetails.color
		scrollView.addSubview(firstSeparator)
		secondSeparator.backgroundColor = kSecondSeparatorDetails.color
		scrollView.addSubview(secondSeparator)
		thirdSeparator.backgroundColor = kThirdSeparatorDetails.color
		scrollView.addSubview(thirdSeparator)
	}
	
	private func setupReviewTextView() {
		reviewTextView.font = kReviewTextViewDetails.font
		reviewTextView.textColor = kReviewTextViewDetails.textColor
		reviewTextView.delegate = self
		reviewTextView.text = kReviewTextViewDetails.placeholdText
		reviewTextView.textContainerInset = UIEdgeInsets.zero
		reviewTextView.textContainer.lineFragmentPadding = 0
		scrollView.addSubview(reviewTextView)
	}
	
	private func setupLabel(_ label: UILabel, text: String, font: UIFont, colour: UIColor, alignment: NSTextAlignment = .center) {
		label.text = text
		label.font = font
		label.textColor = colour
		label.textAlignment = alignment
		scrollView.addSubview(label)
	}
	
	private func setupServerRating() {
		
		serverRating.setValue(5.0, maxValue: kServerRatingDetails.maxValue)
		serverRating.setColours(on: kServerRatingDetails.onColor)
		scrollView.addSubview(serverRating)
	}
	
	private func setupRestaurantRating() {
		
		restaurantRating.setValue(5.0, maxValue: kRestaurantRatingDetails.maxValue)
		restaurantRating.setColours(on: kRestaurantRatingDetails.onColor)
		scrollView.addSubview(restaurantRating)
	}
	
	
	// UNREVIEWED TAG
	private func setupUnreviewedView() {

		unreviewedText.text = String.localizedStringWithFormat(l10n("unreviewedTipMess"), CurrencyManager.main.getCost(cost: OrderManager.main.unreviewedTable.Tip ?? 0))
		unreviewedText.textColor = .dark
		unreviewedText.textAlignment = .center
		unreviewedText.font = UIFont.rescounts(ofSize: 14)
		unreviewedText.numberOfLines = 0
		unreviewedFirstSeparator.backgroundColor = UIColor.separators
		unreviewedSecondSeparator.backgroundColor = UIColor.separators
		unreviewedTotal.text = "(\(l10n("total")): \(CurrencyManager.main.getCost(cost: self.price)))"
		unreviewedTotal.textColor = .dark
		unreviewedTotal.textAlignment = .center
		unreviewedTotal.font = UIFont.lightRescounts(ofSize: 15)
		unreviewedTotal.numberOfLines = 0
		unreviewedView.addSubview(unreviewedFirstSeparator)
		unreviewedView.addSubview(unreviewedSecondSeparator)
		unreviewedView.addSubview(unreviewedText)
		unreviewedView.addSubview(unreviewedTotal)
		scrollView.addSubview(unreviewedView)
	}
	
	private func setupTipSelector() {
		tipSelector.tappedActionCallback = { [weak self] tipAmount, isOtherButton in
			guard let sSelf = self else {
				return
			}
			
			if let tipAmount = tipAmount {
				sSelf.tipAmount = CurrencyManager.main.convertIntForMoney(money: sSelf.price * tipAmount)
				sSelf.updateTipAndTotal()
			}
			if isOtherButton && sSelf.tipSelector.tipViews[sSelf.tipSelector.tipViews.count - 1].isTipSelected {
				sSelf.tipTextView.text = "$"
				sSelf.tipTextView.becomeFirstResponder()
			}
		}
		scrollView.addSubview(tipSelector)
		
		guard let restaurant = OrderManager.main.currentRestaurant, let table = OrderManager.main.currentTable else {
			return
		}
		let startingTip = table.shouldApplyTip ? restaurant.defaultTip : 0
		
		if Helper.floatsEqual(startingTip, 0.15) {
			tipSelector.selectedIndex = 0
		} else if Helper.floatsEqual(startingTip, 0.18) {
			tipSelector.selectedIndex = 1
		} else if Helper.floatsEqual(startingTip, 0.2) {
			tipSelector.selectedIndex = 2
		} else {
			tipSelector.selectedIndex = 3
		}
		
		tipSelector.isUserInteractionEnabled = !fixedTip
	}
	
	private func setupTipTextView() {
		textViewPrefix()
		tipTextView.text = CurrencyManager.main.getCost(cost: tipAmount, currency: "CAD")
		tipTextView.backgroundColor = kTipTextViewDetails.backgroundColor
		tipTextView.font = kTipTextViewDetails.font
		tipTextView.textAlignment = .center
		tipTextView.keyboardType = .decimalPad
		tipTextView.delegate = self
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedTextView))
		tipTextView.addGestureRecognizer(tapGestureRecognizer)
		tipTextView.isUserInteractionEnabled = !fixedTip
		
		scrollView.addSubview(tipTextView)
		
		if fixedTip {
			let coverButt = UIControl()
			coverButt.backgroundColor = .clear
			coverButt.addAction(for: .touchUpInside) {
				let tipPct = OrderManager.main.currentRestaurant?.defaultTip ?? 0
				RescountsAlert.showAlert(title: "Fixed Tip", text: "This restaurant has a fixed tip of \(String(format:"%.1f", tipPct * 100))% for groups of 6 or more.")
			}
			scrollView.addSubview(coverButt)
			tipCover = coverButt
		}
		
		
	}
	
	private func setupDoneButton() {
		doneButton.setTitle(kDoneButtonDetails.text, for: .normal)
		doneButton.addAction(for: .touchUpInside) { [weak self] in
			
			guard let tableID = self?.tableID, tableID.count > 0 else {
				self?.dismiss(orderIsDone: true)
				return
			}
			
			guard let sSelf = self else {
				return
			}
			//UNREVIEWED TAG
			if(sSelf.unreviewed) { //First check if this is for unreviewed scene, we only need to submit the review
				sSelf.onlySubmitReview(pointsEarned: 0, bonusPoints:  0, autoClose: true)
			} // Second check for accidental large tip
			else if (sSelf.tipAmount > CurrencyManager.main.convertIntForMoney(money: sSelf.price * 0.5)) {
				RescountsAlert.showAlert(title: l10n("bigTipWarnPopTitle"), text: l10n("bigTipWarnPopText"), icon: nil, postIconText: nil, options: ["Whoops!", "\(l10n("tip")) \(CurrencyManager.main.getCost(cost: sSelf.tipAmount, currency:"CAD"))"]) { (alert, buttonIndex) in
					if buttonIndex == 1 {
						self?.payBill()
					}
				}
			} else {
				sSelf.payBill()
			}
			
		} // end of button add action
		scrollView.addSubview(doneButton)
	}
	
	private func payBill() {
		
		
		let order = OrderManager.main.orders
		let loyaltyPoints: Int = (order.useLoyaltyBonus && !OrderManager.main.usingRDeals) ? order.loyaltyInfo?.points ?? 0 : 0
		
		//Right now apple pay and credit card should follow the same, like by stripe token to pay the bill
		FullScreenSpinner.show()
		
		PaymentService.payBill(tableID: self.tableID, tip: Int(self.tipAmount), redeemPoints:loyaltyPoints, callback: { [weak self] (message, error, pointsEarned, bonusPoints, defaultTip ,reducedTip, firstOrder, rtyMultiplier) in
			if (error != nil) {
				FullScreenSpinner.hideAll()
				print("Should be able to deal with the paying order again")
				RescountsAlert.showAlert(title: l10n("payBillErrorTitle"), text: "\(l10n("payBillErrorText"))\n\(Constants.Rescounts.supportNumberDisplay)", options: [l10n("callSupport"), l10n("ok").uppercased()]) { (alert, buttonIndex) in
					if (buttonIndex == 0) {
						Helper.callSupport(orShowPopup: false)
					}
				}
				
			} else if (message?.count ?? 0 > 0 && message == "Good") {
				if loyaltyPoints > 0, let trackingDict = GAIDictionaryBuilder.createEvent(withCategory: "action", action: "used_loyalty_points", label: nil, value: nil)?.build() as? [AnyHashable : Any] {
					GAI.sharedInstance()?.defaultTracker.send(trackingDict)
				}
				
				UserService.fetchUserDetails() {(user, error) in
					FullScreenSpinner.hideAll()
					
					NotificationCenter.default.post(name: .finishedPayment, object: nil)
				}
				
				// Sending Review
				self?.onlySubmitReview(pointsEarned: pointsEarned ?? 0, bonusPoints: bonusPoints ?? 0, defaultTip: defaultTip ?? Constants.User.defaultTip, reducedTip: reducedTip ?? 0, firstOrder: firstOrder ?? false, rtyMultiplier: rtyMultiplier ?? 0.0)
				
				
				
				if (PaymentManager.main.applePayOption) {
					AccountManager.main.user?.stripeToken = nil
				}
				
				// Clean up the table after paid the bill
	//			OrderManager.main.clearTable()
				NotificationCenter.default.post(name: .endedTable , object: self)
			} else {
				FullScreenSpinner.hideAll()
			}
		})
	}
	
	private func uploadImageAllImages(reviewId: String?) {
		guard let reviewId:String = reviewId else {
			return
		}
		
		for (i, _) in photoButtonGroup.enumerated() {
			uploadImage(reviewId: reviewId, imageIndex: i)
		}
	}
	
	private func uploadImage(reviewId: String, imageIndex: Int) {
		
		guard let image:UIImage = reviewImageArray[imageIndex] else {
			return
		}
		
		ReviewService.uploadReviewImage(reviewId: reviewId, reviewImage: image) { reviewId, error in
			print(error?.localizedDescription ?? "")
		}
	}
	
	private func setupNavBarTinter() {
		navBarTinter.backgroundColor = .dark
		view.addSubview(navBarTinter)
	}
	
	private func setupPhotoButtons() {
		let imagePickerViewController = UIImagePickerController()
		imagePickerViewController.delegate = self
		
		for (i, _) in photoButtonGroup.enumerated() {
			photoButtonGroup[i].addAction(for: .touchUpInside) {
				if UIImagePickerController.isSourceTypeAvailable(.camera) {
					let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
					alert.addAction(UIAlertAction(title: l10n("takePicture"), style: .default, handler: { _ in
						imagePickerViewController.sourceType = .camera
						self.present(imagePickerViewController, animated: true) {
							self.photoButtonIndex = i
						}
					}))
					alert.addAction(UIAlertAction(title: l10n("cameraRoll"), style: .default, handler: { _ in
						imagePickerViewController.sourceType = .savedPhotosAlbum
						self.present(imagePickerViewController, animated: true) {
							self.photoButtonIndex = i
						}
					}))
					alert.addAction(UIAlertAction(title: l10n("no"), style: .cancel, handler: { _ in
						
					}))
					self.present(alert, animated: true, completion: nil)
				} else {
					imagePickerViewController.sourceType = .photoLibrary
					self.present(imagePickerViewController, animated: true) {
						self.photoButtonIndex = i
					}
				}
			}
			scrollView.addSubview(photoButtonGroup[i])
		}
	}
	
	private func textViewPrefix() {
		let attributedString = NSMutableAttributedString(string: kTipTextViewDetails.prefixText)
		attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.dark, range: NSMakeRange(0, attributedString.length))
		tipTextView.attributedText = attributedString
	}
	
	private func showThankYou(rating: Int, serverRating: Int, pointsEarned: Int, bonusPoints: Int, firstOrder: Bool = false, rtyMultiplier: Float = 0.0 , defaultTip: Float = Constants.User.defaultTip,  reducedTip: Int = 0) {
		let name  = self.restaurantName
		let title = l10n("closeTablePopTitle").uppercased()
		var body  =  String.localizedStringWithFormat(l10n("closeTablePopText"), name)

		if pointsEarned > 0 {
			body +=  "\n\n\(String.localizedStringWithFormat(l10n("closeTablePoints"), pointsEarned))"
		}
		if (rtyMultiplier > 1.0) {
			body += "\n\(String.localizedStringWithFormat(l10n("closeTableRty"), rtyMultiplier))"
		}
		body += " \(l10n("closeTableCheckProfile"))"
		
		if (firstOrder){
			body += "\n\n\(l10n("closeTableFirstOrder"))"
		}
		if (reducedTip > 0) {
			body += "\n\n\(String.localizedStringWithFormat(l10n("closeTableReducedTip"), Int( defaultTip * 100),CurrencyManager.main.getCost(cost: Int(self.tipAmount - reducedTip))))"
		}

		var options = [l10n("done")]
		
		// Add prompt to rate app (just once)
		if (rating >= 4 || serverRating >= 4) {
			if (!UserDefaults.standard.bool(forKey: Constants.Notification.first4Or5Rate)) { //default value is false for the key
				body += "\n\n\(l10n("rateAppMessage"))"
				options.append(l10n("rateApp"))
				UserDefaults.standard.set(true, forKey: Constants.Notification.first4Or5Rate)
				UserDefaults.standard.synchronize()
			}
		}
		
		RescountsAlert.showAlert(title: title, text: body, icon: nil, postIconText: nil, options: options) { [weak self] (alert, buttonIndex) in
			guard let sSelf = self else { return }
			
			sSelf.dismiss(orderIsDone: true)
			
			if (buttonIndex == 1) {
				if let appURL = URL(string: Constants.App.rateURLString) {
					UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
				}
			}
		}
		
		if (bonusPoints > 0) {
			// Delay the 2nd popup by 10 seconds
			DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
				RescountsAlert.showAlert(title: l10n("congrats"), text: String.localizedStringWithFormat(l10n("bonxEarnedMess"), bonusPoints))
			}
		}
	}
	
	private func dismiss(orderIsDone: Bool) {
		// UNREVIEWED TAG
		if (unreviewed) {
			//GODO TO THE BROWSE VIEW
			if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
				appDelegate.switchToMainScreens()
			}
		} else {
//			let presentingVC = self.presentingViewController
			self.dismiss(animated: true) {
				
				//Check if the current view is the receipt view
				if let wc = UIApplication.shared.delegate?.window {
					var vc = wc?.rootViewController
					if(vc is UINavigationController){
						vc = (vc as! UINavigationController).visibleViewController
					}
					if (vc is MenuOrderViewController) {
						//Current view is the correct restaurant view
						var percentage : Float = 0.00
						if (self.tipSelector.selectedIndex == 0){
							percentage = 0.15
						} else if (self.tipSelector.selectedIndex == 1) {
							percentage = 0.18
						} else if (self.tipSelector.selectedIndex == 2) {
							percentage = 0.2
						} else {
							percentage = 1.0
						}
						(vc as? MenuOrderViewController)?.footerView?.updateTipPrice(price: self.tipAmount, percent: percentage)
						//(vc as? MenuOrderViewController)?.footerView?.updateTotalPrice(price: self.totalAmount)
						(vc as? MenuOrderViewController)?.footerView?.hideNotes()
						if orderIsDone {
							(vc as? MenuOrderViewController)?.hideButtons()
							(vc as? MenuOrderViewController)?.footerView?.hideNotes()
						}
						(vc as? MenuOrderViewController)?.view.layoutIfNeeded()
						(vc as? MenuOrderViewController)?.footerView?.layoutIfNeeded()
					}
				}
				
				if orderIsDone {
					OrderManager.main.clearTable()
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                appDelegate.switchToMainScreens()
                            }
					//NotificationCenter.default.post(name: .endedTable , object: self) // if we put this line, all table info will be gone.
				}
				
// Original: Go back to the browse view page.
//				if orderIsDone {
//					(presentingVC?.navigationController ?? presentingVC as? UINavigationController)?.popToRootViewController(animated: true)
//				}
			}
		}
	}
	
	private func totalText() -> NSAttributedString {
		let retVal = NSMutableAttributedString(string: "(\(l10n("totalCharge")): ")
		retVal.append(NSAttributedString(string: CurrencyManager.main.getCost(cost: OrderManager.main.orders.getTotal(withTip: self.tipAmount), currency: "CAD"), attributes: nil))
		totalAmount = OrderManager.main.orders.getTotal(withTip: self.tipAmount)
		retVal.append(NSAttributedString(string: ")"))
		retVal.setAttributes([.foregroundColor: UIColor.highlightRed, .font: UIFont.rescounts(ofSize: 15)], range: NSMakeRange(0, retVal.length))
		return retVal
	}
	
	private func updateTipAndTotal() {
		tipTextView.text = CurrencyManager.main.getCost(cost: tipAmount, currency: "CAD")
		totalLabel.attributedText = totalText()
	}
	
	private func onlySubmitReview(pointsEarned: Int = 0, bonusPoints: Int = 0, defaultTip: Float = Constants.User.defaultTip ,reducedTip: Int = 0, firstOrder: Bool = false, rtyMultiplier : Float = 0.0 , autoClose: Bool = false) {
		guard let user = AccountManager.main.user else {
			return
		}
		let reviewText = (self.reviewTextView.text == self.kReviewTextViewDetails.placeholdText) ? nil : self.reviewTextView.text
		ReviewService.submitReview(review: Review(tableID: self.tableID, images: [], restaurantRating: Int(self.restaurantRating.value), serverRating: Int(self.serverRating.value), reviewText: reviewText, user: user)) { reviewId, error in
			if (error != nil) {
				print(error?.localizedDescription ?? "")
				RescountsAlert.showAlert(title: l10n("submitReviewErrorTitle"), text: "\(l10n("submitReviewErrorText"))\n\(Constants.Rescounts.supportNumberDisplay)", options: [l10n("callSupport"), l10n("ok").uppercased()]) { (alert, buttonIndex) in
					if (buttonIndex == 0) {
						Helper.callSupport(orShowPopup: false)
					}
				}
			} else {
				// Upload images
				self.uploadImageAllImages(reviewId: reviewId)
		
				if let trackingDict = GAIDictionaryBuilder.createEvent(withCategory: "action", action: "completed_rating", label: nil, value: nil)?.build() as? [AnyHashable : Any] {
					GAI.sharedInstance()?.defaultTracker.send(trackingDict)
				}
				if (autoClose) {
					self.showThankYou(rating: Int(self.restaurantRating.value ), serverRating: Int(self.serverRating.value), pointsEarned:  OrderManager.main.unreviewedTable.EarnedPoints ?? 0, bonusPoints:  OrderManager.main.unreviewedTable.BonusPoints ?? 0, firstOrder: firstOrder, rtyMultiplier: rtyMultiplier)
				} else {
					self.showThankYou(rating: Int(self.restaurantRating.value ), serverRating: Int(self.serverRating.value), pointsEarned:  /*OrderManager.main.unreviewedTable.EarnedPoints ?? 0 */ pointsEarned, bonusPoints:  /*OrderManager.main.unreviewedTable.BonusPoints ?? 0*/ bonusPoints, firstOrder: firstOrder, rtyMultiplier: rtyMultiplier, defaultTip: defaultTip, reducedTip: reducedTip )
				}
				//Clean up unreviewed data
				OrderManager.main.unreviewedTable.cleanOut()
			}
		}
	}
	
	
	// MARK: - UIImagePickerControllerDelegate
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		picker.dismiss(animated: true)

		guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
			return
		}


		if let photoButtonIndex = photoButtonIndex {
			photoButtonGroup[photoButtonIndex].photoImage = image
			reviewImageArray[photoButtonIndex] = image
		}
	}

	// MARK: - UIScrollView Methods
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		activeField?.endEditing(true)
	}
	
}

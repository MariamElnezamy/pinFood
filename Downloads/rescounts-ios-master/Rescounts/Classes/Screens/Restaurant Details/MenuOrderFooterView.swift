//
//  MenuOrderFooterView.swift
//  Rescounts
//
//  Created by Monica Luo on 2018-08-21.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation
import UIKit

class MenuOrderFooterView : UIView {
	typealias k = Constants.Order
	typealias kMenu = Constants.Menu
	
	private let subtotalPrice = UILabel()
	private let subtotalPriceDigit = UILabel()
	
	private let rDeals = UILabel()
	private let rDealsDigit = UILabel()
	
	private let taxPrice = UILabel()
	private var taxPriceDigit = UILabel()
	
	private let tipPrice = UILabel()
	private var tipPriceDigit = UILabel()
	
	private let notes = UILabel()
	private let signUp = UILabel()
	private var signUpDigit = UILabel()
	private let loyaltyPoints = UILabel()
	private var loyaltyPointsDigit = UILabel()
	private let discount = UILabel()
	private var discountDigit = UILabel()
	
	public private(set) var loyaltyPointsCheckbox = CheckBox()
	public var useLoyaltyChanged: (()->())?
	
	private let totalPrice = UILabel()
	private var totalPriceDigit = UILabel()
	
	private let rDealsDiscount = UILabel()
	private let rDealsDiscountDigit = UILabel()
	
	private let applePayLabel = UILabel()
	
	private let disclaimerLabel = UILabel()
	
	let separatorLine = UIView()
	let receiptDividerLine1 = UIView()
	let receiptDividerLine2 = UIView()
	let receiptDividerLine3 = UIView()
	
	private var showBonus : Bool = false
	public var showRDeals : Bool = false
	private var showLoyalty : Bool = false
	private var showAlcoholicWarning : Bool = false
	private var showRDealsInfo : Bool = false
	private var showDiscount : Bool = false
	private var showTip : Bool = false
	private var rDealsSavings: Int = 0
	
	let titleFont : CGFloat = 15
	let kCheckboxSpacer: CGFloat = 5
	
	// MARK: - Initialization
	convenience init() {
		self.init(frame: .arbitrary, loyaltyInfo: nil, showBonus: false)
	}
	
	init(frame: CGRect, signup : Int = 0, loyaltyInfo: User.LoyaltyPointInfo? = nil, showBonus: Bool = false, showRDeals: Bool = false, showLoyalty: Bool = false, showTip: Bool = false, showAlcoholicWarning: Bool = false, showRDealsInfo: Bool = false, showDiscount: Bool = false, discount: Int = 0, defaultTip: Float = 0) {
		super.init(frame: frame)
		self.showBonus = showBonus
		self.showRDeals = showRDeals
		self.showLoyalty = showLoyalty
		self.showAlcoholicWarning = showAlcoholicWarning
		self.showRDealsInfo = showRDealsInfo
		self.showDiscount = showDiscount
		self.showTip = showTip
   
		commonInit(signUpValue: signup, loyaltyInfo: loyaltyInfo, discountValue: discount, defaultTip: defaultTip)
		
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	public func commonInit(signUpValue: Int = 0, loyaltyInfo: User.LoyaltyPointInfo? = nil, discountValue: Int = 0, defaultTip: Float = 0) {
		setupSeparators()
		
		setupALine(subtotalPrice, l10n("subtotal"), subtotalPriceDigit, nil)
		setupALine(rDeals, "Processing Fee*", rDealsDigit, nil)
		setupALine(taxPrice, l10n("tax"), taxPriceDigit)
		setupALine(tipPrice, l10n("tip"), tipPriceDigit)
		setupLabel(notes, font: UIFont.lightRescounts(ofSize: 13), text: String.localizedStringWithFormat(l10n("autoTip"), Int(defaultTip*100)), numLines: 0)
	
		setupSignUpBonus()
		
		if (showDiscount) {
			let discountText = "-\(CurrencyManager.main.getCost(cost: Int(discountValue)))"
			setupALine(discount, l10n("resDiscount"), discountDigit, discountText, colour: .highlightRed)
		}
		
		if showLoyalty, let loyaltyInfo = loyaltyInfo {
			let loyaltyText = "-\( CurrencyManager.main.getCost(cost: loyaltyInfo.value, currency: loyaltyInfo.currency) )"
			setupALine(loyaltyPoints, l10n("redeemWinnings"), loyaltyPointsDigit, loyaltyText, colour: .highlightRed)
			loyaltyPointsCheckbox.on = true
			loyaltyPointsCheckbox.addAction(for: .valueChanged) { [weak self] in
				self?.useLoyaltyChanged?()
			}
		} else {
			loyaltyPointsCheckbox.isHidden = true
		}
		
		setupALine(totalPrice, l10n("total").uppercased(), totalPriceDigit)
		
		let discountTitle = RDeals.replaceTitleIn("Your saved", .rDealsDarkR, size: 26,
												  titleAttrs: [.font: UIFont.rescounts(ofSize: 15), .foregroundColor: UIColor.dark],
												  otherAttrs: [.font: UIFont.rescounts(ofSize: 15), .foregroundColor: UIColor.primary])
		setupALine(rDealsDiscount, attrTitle: discountTitle, rDealsDiscountDigit, colour: .primary)
		
		setupApplePay()
		
		setupDisclaimer()
		addSubview(loyaltyPointsCheckbox)
		addSubview(separatorLine)
		addSubview(receiptDividerLine1)
		addSubview(receiptDividerLine2)
		addSubview(receiptDividerLine3)
		
		addSubview(applePayLabel)
		addSubview(disclaimerLabel)
		
		
	}
	
	// MARK: - private funcs
	private func setupLabel(_ label: UILabel, font: UIFont, text: String? = nil, attrText: NSAttributedString? = nil, numLines: Int = 1, alignment: NSTextAlignment = .left, textColour: UIColor = .dark) {
		label.backgroundColor = .clear
		label.textColor = textColour
		label.font = font
		label.textAlignment = alignment
		label.numberOfLines = numLines
		
		if let text = text { label.text = text }
		if let attrText = attrText { label.attributedText = attrText }
		
		addSubview(label)
	}
	
	private func setupALine(_ labelTitle : UILabel, _ title : String? = nil, attrTitle: NSAttributedString? = nil, _ labelDigit: UILabel, _ digit : String? = nil, colour: UIColor = .dark) {
		setupLabel(labelTitle, font: UIFont.rescounts(ofSize: titleFont), text: title, attrText: attrTitle, numLines: 0, textColour: colour)
		setupLabel(labelDigit, font: UIFont.lightRescounts(ofSize: titleFont), text: digit, numLines: 0, textColour: colour)
		labelDigit.textAlignment = .right
	}
	
	private func setupApplePay() {
		applePayLabel.text = l10n("applePayReminder") // TODO: What should this say?
		applePayLabel.font = UIFont.rescounts(ofSize: 16)
		applePayLabel.textAlignment = .center
		applePayLabel.textColor = .highlightRed
		applePayLabel.isHidden = !PaymentManager.main.applePayOption
	}
	
	private func setupDisclaimer () {
		setupDisclaimerText(addAlcohol: showAlcoholicWarning, addRDeals: showRDealsInfo)
		disclaimerLabel.backgroundColor = .clear
		disclaimerLabel.textColor = UIColor.gray
		disclaimerLabel.font = UIFont.lightRescounts(ofSize: 13)
		disclaimerLabel.numberOfLines = 0
	}
	
	private func setupSignUpBonus() {
		if (showBonus) {
			if (OrderManager.main.orders.getRawSubtotal() >= Constants.Order.signUpBonusBoundary) {
				let signUpText = "-\( CurrencyManager.main.getCost(cost: Int(OrderManager.main.orders.getFirstTimeBonus())) )"
				setupALine(signUp, l10n("signUpBnx"), signUpDigit, signUpText, colour: .highlightRed)
			} else {
				let signUpText = "-\( CurrencyManager.main.getCost(cost: Int(0)) )"
				setupALine(signUp, l10n("save$5"), signUpDigit, signUpText, colour: .highlightRed)
			}
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		separatorLine.frame = CGRect(0, 0, self.frame.size.width, kMenu.separatorHeight)
		subtotalPrice.frame = CGRect(k.leftMargin, k.cellPaddingTop, self.frame.width/2, k.textHeight)
		subtotalPriceDigit.frame = CGRect(0, subtotalPrice.frame.minY, self.frame.width - k.leftMargin, k.textHeight)
		
		var curY = subtotalPrice.frame.maxY + k.spacer
		var dealsHeight = showRDeals ? k.textHeight : 0
		rDeals.frame = CGRect(k.leftMargin, curY, self.frame.width/2, dealsHeight)
		rDealsDigit.frame = CGRect(0, curY, self.frame.width - k.leftMargin, dealsHeight)
        if (showRDeals) {
			curY = rDeals.frame.maxY + k.spacer
		}
		
		taxPrice.frame = CGRect(k.leftMargin, curY, self.frame.width/2, k.textHeight)
		taxPriceDigit.frame = CGRect(0, taxPrice.frame.minY, self.frame.width - k.leftMargin, k.textHeight)
		
		curY = taxPrice.frame.maxY + k.spacer
		if showTip {
			tipPrice.frame = CGRect(k.leftMargin, curY, self.frame.width/2, k.textHeight)
			tipPriceDigit.frame = CGRect(0, curY, self.frame.width - k.leftMargin, k.textHeight)
			
			notes.frame = CGRect(k.leftMargin, tipPrice.frame.maxY, self.frame.width - 2*k.leftMargin, notesHeight)
			curY += k.textHeight + notesHeight
		}
		
		if (showBonus) {
			signUp.frame = CGRect(k.leftMargin, curY, self.frame.width/2, k.textHeight)
			signUpDigit.frame = CGRect(0, curY, self.frame.width - k.leftMargin, k.textHeight)
			curY += k.textHeight
		}
		
		if (showDiscount){
			discount.frame = CGRect(k.leftMargin, curY, self.frame.width/2, k.textHeight)
			discountDigit.frame = CGRect(0, curY, self.frame.width - k.leftMargin, k.textHeight)
			curY += k.textHeight
		}
		
		// TODO: put this in some sort of if-block
		if (showLoyalty && AccountManager.main.user?.hasEnoughLoyaltyPoints ?? false) {
			curY += kCheckboxSpacer
			loyaltyPointsCheckbox.frame = CGRect(k.leftMargin, curY, k.textHeight, k.textHeight)
			loyaltyPoints.frame = CGRect(k.leftMargin + k.textHeight + kCheckboxSpacer, curY, floor(self.frame.width*0.6), k.textHeight)
			loyaltyPointsDigit.frame = CGRect(0, curY, self.frame.width - k.leftMargin, k.textHeight)
			curY += k.textHeight
		}
		
		receiptDividerLine1.frame = CGRect(0, curY + k.cellPaddingTop - k.reducedSpace - 3, self.frame.size.width, kMenu.separatorHeight)
		totalPrice.frame = CGRect(k.leftMargin, receiptDividerLine1.frame.minY + 3*k.spacer, self.frame.width/2, k.textHeight)
		totalPriceDigit.frame = CGRect(0, totalPrice.frame.minY, self.frame.width - k.leftMargin, k.textHeight)
		receiptDividerLine2.frame = CGRect(0, totalPrice.frame.maxY + 2*k.spacer, self.frame.size.width, kMenu.separatorHeight)
		
		curY = receiptDividerLine2.frame.maxY + 2*k.spacer
		dealsHeight = showRDealsSavings ? k.textHeight : 0
		rDealsDiscount.frame = CGRect(k.leftMargin, curY, floor(self.frame.width*0.6), dealsHeight)
		rDealsDiscountDigit.frame = CGRect(0, curY, self.frame.width - k.leftMargin, dealsHeight)
		receiptDividerLine3.frame = CGRect(0, rDealsDiscountDigit.frame.maxY + 2*k.spacer, self.frame.size.width, showRDealsSavings ? kMenu.separatorHeight : 0)
		if (showRDealsSavings) {
			curY = receiptDividerLine3.frame.maxY + 2*k.spacer
		}
		
		applePayLabel.frame = CGRect(0, curY, self.frame.width, k.textHeight)
		if (PaymentManager.main.applePayOption) {
			disclaimerLabel.frame = CGRect(k.leftMargin, applePayLabel.frame.maxY + 2 * k.spacer, self.frame.width - 2 * k.leftMargin, k.disclaimerHeight)
		} else {
			disclaimerLabel.frame = CGRect(k.leftMargin, curY, self.frame.width - 2 * k.leftMargin, k.disclaimerHeight)
		}
		disclaimerLabel.sizeToFit()
        
        layoutIfNeeded()
	}
	
	
	private func setupSeparators() {
		separatorLine.backgroundColor = .separators
		receiptDividerLine1.backgroundColor = .separators
		receiptDividerLine2.backgroundColor = .separators
		receiptDividerLine3.backgroundColor = .separators
	}
	
	private func get2Digit( value : Int) -> String {
		return CurrencyManager.main.getCost(cost: value)
	}
	
	private func setupDisclaimerText(addAlcohol: Bool, addRDeals: Bool = false) {
		let txt = NSMutableAttributedString(string: "\u{2022} \(l10n("addMoreBeforeCheckout"))")
		txt.setAttributes([.foregroundColor: UIColor.highlightRed], range: NSMakeRange(0, txt.length))
		txt.append(NSMutableAttributedString(string: "\n\u{2022} \(l10n("lateArrival"))"))
		if (addAlcohol) {
			txt.append(NSMutableAttributedString(string: "\n\u{2022} \(l10n("alcohol"))"))
		}
		if (addRDeals) {
			txt.append(NSMutableAttributedString(string: "\n\u{2022} \(l10n("rDealsDisclaimer1"))"))
//			txt.append(NSMutableAttributedString(string: "\n\u{2022} \(l10n("rDealsDisclaimer2"))"))
		}
		self.disclaimerLabel.attributedText = txt
	}
	
	private var notesHeight: CGFloat {
		return ceil(notes.sizeThatFits(CGSize(UIScreen.main.bounds.width - 2*k.leftMargin, 100)).height)
	}
	
	private var showRDealsSavings: Bool {
		return showRDeals && rDealsSavings > 0
	}
	
	// MARK: - public funcs
	
	public func getHeight() -> CGFloat {
		let bonusHeight = showBonus ? k.textHeight + k.spacer : 0
		let rDealsHeight = showRDeals ? (k.textHeight + k.spacer) : 0
		let rDealsSavingsHeight = showRDealsSavings ? (k.textHeight + kMenu.separatorHeight + 2*k.spacer) : 0
		let tipHeight = showTip ? (k.textHeight + notesHeight) : 0
		let loyaltyHeight = showLoyalty ? k.textHeight + kCheckboxSpacer : 0
		
		return k.cellPaddingTop * 2 + (4 * k.textHeight) + (7 * k.spacer) + tipHeight + bonusHeight + loyaltyHeight + rDealsHeight + rDealsSavingsHeight + k.bottomMargin + k.disclaimerHeight - k.reducedSpace - 3
	}
	
	public func updateTotalPrice( price : Int) {
		self.totalPriceDigit.text = "\(get2Digit(value: price))"
	}
	
	public func updateSubtotalPrice (price: Int) {
		self.subtotalPriceDigit.text =  "\(get2Digit(value: price))"
	}
	
	public func updateRDealsPrice (price: Int, discount: Int) {
		//showRDeals = (price > 0)
		rDealsSavings = discount
		rDealsDigit.text = "\(get2Digit(value: price))"
		rDealsDiscountDigit.text = "\(get2Digit(value: discount))"
	}
	
	public func updateTipPrice(price : Int, percent : Float) {
		if percent >= 1.0 {
			self.tipPriceDigit.text = "\(get2Digit(value: price))"
		} else {
			self.tipPriceDigit.text = "\(get2Digit(value: price)) (\(String(format:"%.1f", percent*100))%*)"
		}
	}
	
	public func updateSignUpValue(value : Int) {
		self.signUpDigit.text = "-\(get2Digit(value: value))"
	}
	
	public func updateLoyaltyPointsValue(use: Bool, value : Int) {
		self.loyaltyPointsCheckbox.on = use
		self.loyaltyPointsDigit.text = "-\(get2Digit(value: value))"
	}
	
	public func updateTaxPrice(price: Int) {
		self.taxPriceDigit.text = "\(get2Digit(value: price))"
	}
	
	public func updateAlcoholicWarningLabel(shouldAdd : Bool, showRDeals: Bool) {
		setupDisclaimerText(addAlcohol: shouldAdd, addRDeals: showRDeals)
		
		if (shouldAdd) {
			disclaimerLabel.frame.size.height = k.disclaimerHeight + 50
		} else {
			disclaimerLabel.frame.size.height = k.disclaimerHeight
		}
		disclaimerLabel.sizeToFit()
	}
	
	public func updateSignUpBonusLabel(showBonus: Bool) {
		self.showBonus = showBonus
		setupSignUpBonus()
	}
	
	public func hideNotes() {
		//notes.isHidden = true
	}
}

//
//  PaymentManager.swift
//  Rescounts
//
//  Created by Monica Luo on 2018-09-10.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//
//  Reference1 : https://www.raywenderlich.com/2113-apple-pay-tutorial-getting-started
//  Reference2 : https://medium.com/@abdul.i.aljebouri/bare-minimum-apple-pay-xcode-9-swift-4-5245bd3dcde4

import Foundation
import UIKit
import PassKit
import Stripe

class PaymentManager : NSObject {
	
	public var applePayOption : Bool = false //if it's true, we use apple pay
	let paymentNetworks: [PKPaymentNetwork] = [.amex, .masterCard, .visa]
	
	public static let main = PaymentManager()
	
	// MARK: - apple pay settings
	
	public func checkIfApplePayDeviceAllowed()-> Bool{
		return  PKPaymentAuthorizationController.canMakePayments()
	}
	
	public func checkIfApplePayCardsConfigured()->Bool {
		return PKPaymentAuthorizationController.canMakePayments(usingNetworks: paymentNetworks) // or Stripe.deviceSupportsApplePay()
	}
	
	
	public func applePayRequest(totalPrice: Int, callback : (Bool, PKPaymentAuthorizationViewController?) -> Void) {
		if checkIfApplePayDeviceAllowed() && checkIfApplePayCardsConfigured() {
			let request : PKPaymentRequest = PKPaymentRequest()
			request.merchantIdentifier = Constants.Stripe.appleMerchantID ?? ""
			request.currencyCode = CurrencyManager.main.currency ?? "CAD"
			request.countryCode = "CA"
			request.supportedNetworks = paymentNetworks
			if #available(iOS 11.0, *) {
				request.requiredShippingContactFields = []
			} else {
				// Fallback on earlier versions
			}
			//This is based on using Stripe
			let finalPrice:NSDecimalNumber = CurrencyManager.main.getCostAsDecimalNumber(cost: totalPrice, currency: request.currencyCode)
			request.merchantCapabilities = .capability3DS
			let taxSummaryItem = PKPaymentSummaryItem(label: "Rescounts", amount: finalPrice)
			request.paymentSummaryItems = [taxSummaryItem]
			
			let authorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: request)
			authorizationViewController?.modalPresentationStyle = .fullScreen
			callback(true, authorizationViewController)
		} else {
			callback(false, nil)
		}
		
	}
	
	public func purchase(menus: [MenuItem], tip:Double, tax: Double, total: Double, callback : (Bool?, PKPaymentAuthorizationViewController?) -> Void){
		
		if checkIfApplePayDeviceAllowed() && checkIfApplePayCardsConfigured(){
			let request : PKPaymentRequest = PKPaymentRequest()
			
			request.merchantIdentifier = Constants.Stripe.appleMerchantID ?? ""
			request.currencyCode = CurrencyManager.main.currency ?? ""
			request.supportedNetworks = paymentNetworks
			if #available(iOS 11.0, *) {
				request.requiredShippingContactFields = [.name, .postalAddress]
			} else {
				// Fallback on earlier versions
			}
			//This is based on using Stripe
			request.merchantCapabilities = .capability3DS
			
			for item in menus {
				let instance_item = PKPaymentSummaryItem(label: item.title, amount: NSDecimalNumber(floatLiteral: Double(item.price)), type: .final)
				request.paymentSummaryItems.append(instance_item)
			}
			let taxSummaryItem = PKPaymentSummaryItem(label: l10n("tax"), amount: NSDecimalNumber(decimal: Decimal(tax)), type: .final)
			let tipSummaryItem = PKPaymentSummaryItem(label: l10n("tip"), amount: NSDecimalNumber(decimal: Decimal(tip)), type:. final)
			let totalSummaryItem = PKPaymentSummaryItem(label: l10n("total"), amount : NSDecimalNumber(decimal: Decimal(total)), type: .final)
			request.paymentSummaryItems.append(taxSummaryItem)
			request.paymentSummaryItems.append(tipSummaryItem)
			request.paymentSummaryItems.append(totalSummaryItem)
			
			let authorizationViewController : PKPaymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: request) ?? PKPaymentAuthorizationViewController()
			
			callback(true, authorizationViewController)
			
		} else {
			callback(false, nil)
		}
	}
}

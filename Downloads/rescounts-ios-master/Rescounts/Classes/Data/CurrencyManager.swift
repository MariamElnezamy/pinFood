//
//  CurrencyManager.swift
//  Rescounts
//
//  Created by Monica Luo on 2018-08-31.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation
// reference: https://stackoverflow.com/questions/24960621/struggling-with-nsnumberformatter-in-swift-for-currency

class CurrencyManager: NSObject {
	
	// TODO: remove this global default data, always pass it in (because we might handle multiple currencies in a single run)
	public var currency: String?
	public var currencySymbol : String?
	private var sharedCurrencyFormatter: NumberFormatter?
	private var sharedCurrencyNoDecimalFormatter: NumberFormatter?
	
	public static let main = CurrencyManager()
	
	
	// MARK: - Public Methods
	
	// TODO: Wherever is is called, pass in a currency instead of relying on a global default
	public func getCost(cost: Int, hideDecimals: Bool = false, currency: String? = nil) -> String {
		var formatter = currencyFormatter(currency)
		
		let tens = pow(Double(10), Double(formatter.maximumFractionDigits) )
		let amount : NSNumber = (Double(cost) / tens) as NSNumber
		
		if (hideDecimals) {
			formatter = currencyNoDecimalFormatter()
		}
		
		let convertedPrice = formatter.string(from: amount)
		return convertedPrice ?? ""
	}
	
	public func getCostAsDecimalNumber(cost: Int, currency: String? = nil) -> NSDecimalNumber {
		let formatter = currencyFormatter(currency)

		return NSDecimalNumber.init(mantissa: UInt64(cost), exponent: Int16(-1*formatter.maximumFractionDigits), isNegative: false)
	}
	
	public func getRawCost(decimalCost: Double, currency: String? = nil) -> Int {
		let formatter = currencyFormatter(currency)
	
		let tens = pow(Double(10), Double(formatter.maximumFractionDigits) )
		return convertIntForMoney(money: (decimalCost * tens))
	}
	
	public func convertIntForMoney(money: Double) -> Int {
		return Int(round(money) + 0.00001)
	}
	
	public func convertIntForMoney(money: Float) -> Int{
		return Int(round(money) + 0.00001)
	}
	
	
	// MARK: - Private Helpers
	
	private func currencyFormatter(_ currency: String? = nil) -> NumberFormatter {
		if nil == sharedCurrencyFormatter {
			sharedCurrencyFormatter = NumberFormatter()
			sharedCurrencyFormatter?.numberStyle = .currency
			sharedCurrencyFormatter?.currencySymbol = self.currencySymbol ?? "$"
		}
	
		guard let sharedCurrencyFormatter = sharedCurrencyFormatter else {
			print("********** ERROR: Could not create currency formatter! **********")
			return NumberFormatter()
		}
		
		sharedCurrencyFormatter.currencyCode = currency ?? self.currency ?? "CAD"
		
		return sharedCurrencyFormatter
	}
	
	private func currencyNoDecimalFormatter(_ currency: String? = nil) -> NumberFormatter {
		if nil == sharedCurrencyNoDecimalFormatter {
			sharedCurrencyNoDecimalFormatter = NumberFormatter()
			sharedCurrencyNoDecimalFormatter?.numberStyle = .currency
			sharedCurrencyNoDecimalFormatter?.currencySymbol = self.currencySymbol ?? "$"
			sharedCurrencyNoDecimalFormatter?.maximumFractionDigits = 0
		}
		
		guard let sharedCurrencyNoDecimalFormatter = sharedCurrencyNoDecimalFormatter else {
			print("********** ERROR: Could not create currency formatter! **********")
			return NumberFormatter()
		}
		
		sharedCurrencyNoDecimalFormatter.currencyCode = currency ?? self.currency ?? "CAD"
		
		return sharedCurrencyNoDecimalFormatter
	}
}

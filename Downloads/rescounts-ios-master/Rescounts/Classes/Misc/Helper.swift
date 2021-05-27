//
//  Helper.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-19.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class Helper: NSObject {
		
	// E.g. Rounding to the nearest 0.5 uses a denom of 2
	public static func roundf(_ val: CGFloat, denom: CGFloat) -> CGFloat {
		return round(denom * val) / denom
	}
	
	private static let production : Bool = {
		#if DEBUG
			print("DEBUG")
			return false
		#elseif ADHOC
			print("ADHOC")
			return false
		#else
			print("PRODUCTION")
			return true
		#endif
	}()
	
	static func isProduction () -> Bool {
		return self.production
	}
	
	static func assertTestBuild() {
		// TODO: Swift 4.2 introduces #error, we should use this here instead. The assert will actually get compiled out to nothing in a production build, making this useless.
		assert(!Helper.isProduction())
	}
	
	static func printTodoImplement(_ file: String, _ function: String) {
		print("**********\n\tTODO: implement: \(URL(string:file)?.lastPathComponent ?? file) : \(function)\n**********")
	}
	
	static func iosAtLeast(_ version: String) -> Bool {
		var retVal = false
		
		switch UIDevice.current.systemVersion.compare(version, options: .numeric) {
		case .orderedSame, .orderedDescending:
			retVal = true
		case .orderedAscending:
			retVal = false
		}
		return retVal
	}
	
	static func callSupport(orShowPopup: Bool = false) {
		if (UIDevice.current.userInterfaceIdiom == .phone) {
			guard let number = URL(string: "tel://" + Constants.Rescounts.supportNumber) else {
				return
			}
			
			UIApplication.shared.open(number)
		} else if orShowPopup {
			RescountsAlert.showAlert(title: l10n("rescountsSupport"), text: "\(l10n("reachRescountsSupport"))\n\n\(Constants.Rescounts.supportNumberDisplay)")
		}
	}
	
	static func floatsEqual(_ f1: Float, _ f2: Float) -> Bool {
		return (abs(f1 - f2) < 0.00000001)
	}
	
}

public func l10n(_ key: String) -> String {
	return NSLocalizedString(key, comment: "")
}

func *(lhs: Int, rhs: Double) -> Double {
	return Double(lhs) * rhs
}

func *(lhs: Int, rhs: Float) -> Float {
	return Float(lhs) * rhs
}

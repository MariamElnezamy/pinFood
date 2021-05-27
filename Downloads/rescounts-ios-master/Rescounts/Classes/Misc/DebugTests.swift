//
//  DebugTests.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-08-18.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class DebugTests: NSObject {

	static func runDebugTests() {
		Helper.assertTestBuild()
		
		checkLocalization()
	}
	
	static private func checkLocalization() {
		let regions = ["Base"]//, "pt"] // "eg", "mx"
		var keys: [String] = []
		
		for region in regions {
			guard let path = Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: region) else {
				printL10nError ("missing strings file!")
				print ("Device localizations: \(Locale.preferredLanguages)")
				return
			}
			let dict = NSDictionary(contentsOfFile: path)
			let currentKeys: [String] = (dict?.allKeys as? [String] ?? [])
			if keys.count == 0 { keys = currentKeys }
			if !(keys == currentKeys) {
				printL10nError ("missing a key for localization: \(region.uppercased())!   Keys: \(keys.difference(from: currentKeys))")
			}
			
			if (currentKeys.count != Set(currentKeys).count) {
				printL10nError ("duplicate key for localization: \(region.uppercased())!")
			}
		}
	}
	
	static func printL10nError(_ text: String) {
		print ("*******\n\tL10N FAIL: \(text)\n*******")
	}
}

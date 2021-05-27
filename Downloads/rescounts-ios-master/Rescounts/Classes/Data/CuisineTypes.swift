//
//  CuisineTypes.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-09-16.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//
//	Provides localizations for the CuisineTypes enum on the backend
//
//  Create a food type by calling CuisineType(rawValue: x) where x is the Int ID pulled from the JSON.
//		- if this initialization returns nil, you should use the default display name provided in the JSON


import UIKit

public enum CuisineType : Int {
	case AsianFusion   = 0
	case HappyHour     = 1
	case Japanese      = 2
	case PubFare       = 3
	case Wine          = 4
	
	var localizedDisplay: String {
		switch self {
		case .AsianFusion:
			return l10n("AsianFusion")
		case .HappyHour:
			return l10n("HappyHour")
		case .Japanese:
			return l10n("Japanese")
		case .PubFare:
			return l10n("PubFare")
		case .Wine:
			return l10n("Wine")
		}
	}
}

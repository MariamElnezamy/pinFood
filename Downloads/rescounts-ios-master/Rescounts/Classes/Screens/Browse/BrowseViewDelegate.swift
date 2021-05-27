//
//  BrowseViewDelegate.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-23.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import MapKit

protocol BrowseViewDelegate : NSObjectProtocol {
	
//	optional public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
	func selectedRestaurant(_ restaurant: Restaurant)
	
	func performSearch(location: CLLocationCoordinate2D?, loadingMore: Bool)
	
	func callForPerformSearch()
	
	func getSearchState() -> Bool
}

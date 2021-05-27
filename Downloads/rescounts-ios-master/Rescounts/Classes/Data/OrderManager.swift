//
//  OrderManager.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-08-22.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class OrderManager: NSObject {
	static let pollingFrequencySeconds: Int = 3
	public var pollCount = 0
//	public let pollCountMax = 100 // Practically speaking, we'll never hit this limit, but just in case there's some weird network thing, let's not poll forever
	public static let main = OrderManager()
	
	public private(set) var currentTable: RestaurantTable?
	public private(set) var currentRestaurant: Restaurant?
	public var lastKnownRDealsFee: Int = 0
	
	public var orders = UserOrder()
	
	//UNREVIEWED TAG
	public var unreviewedTable = Unreviewed()
	
	private var isPollingTable = false
	private var isPollingOrder = false
	private var isSubmittingOrder = false
	
    typealias OrderPollingCallback = (_ approved: Bool, _ declinedItems: [[String: Any]]?) -> Void
	
	
	// MARK: - Public Methods
	
	public func getMenuItem(itemID: String) -> MenuItem? {
		for menuItem in self.orders.pendingItems {
			if menuItem.itemID == itemID {
				print("Got item: \(menuItem.title) for id \(itemID)")
				return menuItem
			}
		}
		return nil
	}
	
	public func startNewTable(_ table: RestaurantTable, restaurant: Restaurant, isJoining: Bool, isPickup: Bool) {
		
		if (self.currentTable == nil) {
			// Insert notification here when the table has been rescheduled for the first time
		} else {
			// Insert Notification here for polling the rescheduled table
		}
		
		// No matter what, once the table request has been sent, we will need to keep polling
		self.currentTable = table
		self.currentRestaurant = restaurant
		if let approved = self.currentTable?.approved, !approved {
			startPollingTableIfNecessary()
		}
		postOrderNotification(.startedNewTable) // currently both cases share the same notification
		
		if isJoining || isPickup {
			showOrderAccepted(table: table, isJoining: isJoining, isPickup: isPickup)
		}
	}

	// This should never be called directly, use 'startPollingTableIfNecessary' instead
	private func pollForApprovedTable() {
		if currentTable?.tableID == nil {
			if HoursManager.isAutoCancelTimerRunning {
				HoursManager.resetAutoCancelTimer()
				HoursManager.showEndAutoCancelTimerPopUp()
			}
		}
		if let tableID = currentTable?.tableID {
			isPollingTable = true
			
			TableService.getTableStatus(tableID: tableID) { [weak self] (approved, error, response) in
				guard let sSelf = self else {
					return
				}
				
				sSelf.isPollingTable = false
				
				if let currentTable = self?.currentTable, let approved = approved, approved {
					currentTable.approved = true
					currentTable.approvedAt = Date()
					sSelf.postOrderNotification(.approvedTable)
					SoundsMaker.main.alert()
					
					self?.showOrderAccepted(table: currentTable, isJoining: false, isPickup: false)
					
					HoursManager.resetAutoCancelTimer()
					HoursManager.startAutoCancelTimer()
					DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(7)) {
						HoursManager.showStartAutoCancelTimerPopUp()
					}
				} else {
					
					if let approved = approved, !approved {
						//This is the case such that the restaurant has given a response but the table hasn't been approved
						print("The table has been declined or reschduled")
						if response?.count ?? 0 > 0 && response == "Declined" {
							guard let _ = self?.currentRestaurant else {
								return // Prevent double pop-up, we might have auto-declined frmo the app and shown this popup already
							}
							
							SoundsMaker.main.alert()
							var reason = OrderManager.main.orders.declinedReason
							reason = (reason == l10n("tableNoDeclinedDefault")) ? "" : "\(l10n("reason")): \(OrderManager.main.orders.declinedReason) \n\n"
							RescountsAlert.showAlert(title: String.localizedStringWithFormat(l10n("noTable"), "\(self?.currentTable?.restaurantName ?? l10n("theRes"))"),
													 text: "\(reason)\(l10n("findElse"))",
													 options: [l10n("ok")],
													 callback:
							{ (alert, buttonIndex) in
								if let wd = UIApplication.shared.delegate?.window {
									var vc = wd!.rootViewController
									if (vc is UINavigationController) {
										vc = (vc as! UINavigationController).visibleViewController
									}
									if(vc is BrowseViewController) {
										// I am on BrowseViewController
									} else {
										//I'm not on browseviewController, go back to root view which is browseViewController
										vc?.navigationController?.popToRootViewController(animated: true)
									}
								}
							})
							//let reservation view stop spinning
							sSelf.clearTable()
							sSelf.postOrderNotification(.endedTable)
							return
						} else if response?.count ?? 0 > 0 && response == "Canceled" { //The table has been auto canceled
							HoursManager.showEndAutoCancelTimerPopUp()
							HoursManager.resetAutoCancelTimer()
							sSelf.clearTable()
							sSelf.postOrderNotification(.endedTable)
						} else {
							//show utc time in local time
							let newDate : String =  HoursManager.UTCToLocal(UTCDateString: response ?? "", dateFormat: "yyyy-MM-dd\'T\'HH:mm:ss.SSSZ")
							let reservedTime : Date = HoursManager.dateFromString(newDate) ?? Date()
							
							// TODO: localize
							var restaurantName = self?.currentTable?.restaurantName ?? l10n("theRes")
							if restaurantName.count == 0 { restaurantName = l10n("theRes") }
							SoundsMaker.main.alert()
							RescountsAlert.showAlert(title: l10n("tableNoOKRescheduledTitle"), text:String.localizedStringWithFormat(l10n("tableNoOkRescheduledText"), restaurantName, HoursManager.userFriendlyDate(reservedTime)) , icon: nil, postIconText: nil, options: [l10n("noThx"), l10n("ok").uppercased()], callback: { (alert, option) in
								if(option == 1) {
									//Get the new available time
									print("Reschedule the time")
									OrderManager.main.currentTable?.seatingAt = HoursManager.dateFromString(response) ?? Date() // TODO: check that this response is indeed the date
									HoursManager.resetTimer()
									HoursManager.startTimer()
									//Send another calls for reschedule the table.
									//========= Start the new reservation =======================
									if let restaurant = OrderManager.main.currentRestaurant {
										ReservationService.rescheduleTable(tableID: OrderManager.main.currentTable?.tableID ?? "", restaurant: restaurant, numPeople: OrderManager.main.currentTable?.numberOfSeats ?? 0, reservationTime: reservedTime, special: "", callback: { (table: RestaurantTable?, error: ReservationService.ReservationError) in
											FullScreenSpinner.hideAll()
											
											if table != nil {
												
											} else {
												RescountsAlert.showAlert(title: l10n("error"), text: l10n("resLost"), callback: nil)
											}
										})
									} else {
										RescountsAlert.showAlert(title: l10n("unexpectedError"), text: l10n("reqLost"))
									}
									//========= End of the reservation =======================
								} else {
									//Cancel the table reservation due to the user doesn't want to continue the rescheduled time.
									ReservationService.cancelTable(tableID: tableID, callback: { (result) in
										if (result) {
											SoundsMaker.main.alert()
											RescountsAlert.showAlert(title: l10n("tableNoCanceled"), text: l10n("tableThx"))
										}
									})
									sSelf.clearTable()
									sSelf.postOrderNotification(.endedTable)
								}
								if let trackingDict = GAIDictionaryBuilder.createEvent(withCategory: "action", action: "rescheduled_reservation", label: (option == 1) ? "accepted" : "declined", value: nil)?.build() as? [AnyHashable : Any] {
									GAI.sharedInstance()?.defaultTracker.send(trackingDict)
								}
							})
							sSelf.pollCount = 0
							return
						}
						
					}
					
//					if (sSelf.pollCount >= sSelf.pollCountMax) {
//						sSelf.pollCount = 0
//						return
//					}
					
					sSelf.isPollingTable = true
					DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(OrderManager.pollingFrequencySeconds)) { [weak self] in
						self?.pollForApprovedTable()
						self?.pollCount += 1
					}
				}
			}
		} else {
			isPollingTable = false
		}
	}
	
	private func showOrderAccepted(table: RestaurantTable, isJoining: Bool, isPickup: Bool) {
		let postIconT = NSMutableAttributedString()
		let titleFont = UIFont.rescounts(ofSize: 15)
		let bodyFont = UIFont.lightRescounts(ofSize: 14)
		
		let centerAlignStyle = NSMutableParagraphStyle()
		centerAlignStyle.alignment = .center
		let leftAlignStyle = NSMutableParagraphStyle()
		leftAlignStyle.alignment = .left
		
		let titleAttr: [NSAttributedString.Key : Any] = [.font: titleFont, .paragraphStyle: centerAlignStyle]
		let titlePink: [NSAttributedString.Key : Any] = [.font: titleFont, .paragraphStyle: centerAlignStyle, .foregroundColor: UIColor.primary]
		let bodyAttr:  [NSAttributedString.Key : Any] = [.font: bodyFont,  .paragraphStyle: leftAlignStyle]
		let bodyPink:  [NSAttributedString.Key : Any] = [.font: bodyFont,  .paragraphStyle: leftAlignStyle, .foregroundColor: UIColor.primary]
		let nowStyle:  [NSAttributedString.Key : Any] = [.font: titleFont, .paragraphStyle: leftAlignStyle, .foregroundColor: UIColor.primary]
		
		// Title
		if !isJoining {
			let nameInTitle = isPickup ? table.restaurantName : String.localizedStringWithFormat(l10n("tableOKAccepted1"), table.restaurantName)
			let time = HoursManager.userFriendlyDate(table.seatingAt)
			postIconT.append(NSAttributedString(string: "\(nameInTitle)\n",            attributes: titleAttr))
			if !table.pickup {
				postIconT.append(NSAttributedString(string: "\(table.numberOfSeats)",      attributes: titlePink))
				postIconT.append(NSAttributedString(string: "\(l10n("tableOKAccepted2"))", attributes: titleAttr))
			} else {
				postIconT.append(NSAttributedString(string: "\(l10n("tableOKAccepted3"))", attributes: titleAttr))
			}
			postIconT.append(NSAttributedString(string: "\(time)\n",                   attributes: titlePink))
		}
		if !isPickup {
			postIconT.append(NSAttributedString(string: "\(l10n("tableOKJoined"))", attributes: titleAttr))
			postIconT.append(NSAttributedString(string: "\(table.joinCode)\n\n",    attributes: titlePink))
		}
		
		// Body
		postIconT.append(NSAttributedString(string: "\(l10n("tableOKNow")):\n", attributes: nowStyle))
		
		let numInstructions = 6
		for i in 1...numInstructions {
			postIconT.append(NSAttributedString(string: "\(i). ",                   attributes: bodyPink))
			postIconT.append(NSAttributedString(string: "\(l10n("tableOK\(i)"))\n", attributes: bodyAttr))
		}
		
		RescountsAlert.showAlert(
			title: "",
			text: "",
			icon: RescountsAlert.IconType.checkmark,
			postIconText: postIconT,
			options: [l10n("goMenu").uppercased()]) { (alert, buttonIndex) in
				
				if let w = UIApplication.shared.delegate?.window, let nc = w?.rootViewController as? UINavigationController {
					var alreadyShowingRestaurant = false
					for vc in nc.viewControllers {
						if let vc = vc as? RestaurantViewController, vc.restaurant.restaurantID == OrderManager.main.currentRestaurant?.restaurantID {
							alreadyShowingRestaurant = true
							break
						}
					}
					
					if alreadyShowingRestaurant {
						// We're already on this restaurant (or a sub-screen of it)
						
					} else {
						//Otherwise, we will go to the right restaruant view
						if let restaurant = OrderManager.main.currentRestaurant, let table = OrderManager.main.currentTable, let rootNC = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
							let vc = RestaurantViewController(restaurant, isRDeals: table.isRDeals)
							rootNC.pushViewController(vc, animated: true)
						}
					}
				} else {
					//Something wrong happened here.
				}
		}
	}
	
	public func finishTable(_ table: RestaurantTable) {
		if (self.currentTable != nil) {
			self.clearTable()
			postOrderNotification(.endedTable)
		}
	}
	
    public func autoDeclineTable(completion: (()->())? = nil) {
        if let tableID = self.currentTable?.tableID {
            ReservationService.autoDeclineTable(tableID: tableID) { [weak self] (success) in
                if success {
                    self?.postOrderNotification(.cancelledTable)
                }
                completion?()
            }
        }
    }
    
	public func cancelTable(completion: (()->())? = nil) {
		if let tableID = self.currentTable?.tableID {
			ReservationService.cancelTable(tableID: tableID) { [weak self] (success) in
				if success {
					self?.postOrderNotification(.cancelledTable)
				}
				completion?()
			}
		}
	}
	
	//it's pickup and there is no confirmed order
	public func cancelPickUp(completion: (()->())? = nil) {
		if let tableID =  self.currentTable?.tableID {
			ReservationService.cancelPickUp(tableID: tableID) { [weak self](success) in
				if success {
					self?.postOrderNotification(.cancelledTable)
				}
				completion?()
			}
		}
	}
	
	public func clearTable() {
		self.currentTable = nil
		self.currentRestaurant = nil
		self.orders.clearItems()
		self.orders.declinedReason = l10n("tableNoDeclinedDefault")
		self.isPollingTable = false
		self.isPollingOrder = false
		HoursManager.resetAutoCancelTimer()
	}
	
	public var canCancelTable: Bool {
		return (currentTable != nil && !orders.hasConfirmedItems && !isSubmittingOrder && !isPollingOrder)
	}
	
	public var canCancelPickUp: Bool {
		return (currentTable != nil && (currentTable?.pickup ?? false) && !orders.hasConfirmedItems)
	}
	
	// Checks if we have unsubmitted items, or if we're waiting on a request to the restaurant
	public var hasPendingData: Bool {
		return (currentTable != nil && (isSubmittingOrder || isPollingOrder || orders.hasPendingItems))
	}
	
	public var usingRDeals: Bool {
		return currentTable?.isRDeals ?? false
	}
	
	public func submitAndStartNewOrder(callback: OrderPollingCallback?) {
		isSubmittingOrder = true
		HoursManager.resetAutoCancelTimer()
		FullScreenSpinner.show()
		OrderService.submitOrder(tableID: OrderManager.main.currentTable?.tableID ?? "") { [weak self] (orderID, error) in
			FullScreenSpinner.hideAll()
			self?.isSubmittingOrder = false
			if let error = error {
				print(error.localizedDescription)
				RescountsAlert.showAlert(title: l10n("unexpectedError"), text: error.localizedDescription)
			} else if (orderID?.count ?? 0 > 0){
				self?.orders.orderID = orderID ?? ""
				self?.pollCount = 0
				self?.pollForApprovedOrder(callback)
				RescountsAlert.showAlert(title: "", text: l10n("orderSentText"))
			}
			self?.postOrderNotification(.startedNewOrder)
		}
	}
	
	public func pollForApprovedOrder(_ callback: OrderPollingCallback?) {
		isPollingOrder = true
		OrderService.getOrder(orderID: self.orders.orderID, callback: { [weak self] (orderID, costs, approved, error, items) in

			guard let sSelf = self else { return }
			
			sSelf.isPollingOrder = false
			if (error != nil) {
				print(error?.localizedDescription ?? "")
				
//				if (sSelf.pollCount >= sSelf.pollCountMax) {
//					sSelf.pollCount = 0
//					return
//				}
				
				sSelf.isPollingOrder = true
				DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(OrderManager.pollingFrequencySeconds)) {
					sSelf.pollForApprovedOrder(callback)
					sSelf.pollCount += 1
				}
				
			} else {
				// TODO deal with strings for localization
				if (approved ?? false) {
					sSelf.orders.confirmItems()
					if let orderID = orderID, let costs = costs {
						sSelf.orders.add(cost: costs.cost, tax: costs.tax, discount: costs.rDealsDiscount, orderID: orderID)
					}
					self?.postOrderNotification(.approvedOrder)
					SoundsMaker.main.alert()
					RescountsAlert.showAlert(title: String.localizedStringWithFormat(l10n("orderOKTitle"), self?.currentRestaurant?.name ?? ""),
						text: l10n("orderOKText"),
						icon: RescountsAlert.IconType.checkmark,
						postIconText: NSAttributedString(string: l10n("orderOKsubText")),
						options: [l10n("confirm").uppercased()],
						callback: nil)
					callback?(true, nil)
				} else {
					if self?.currentTable != nil { // Check if it's from the normal return order or from the pickup cancel table request, if it's from the pickup, we don't want to show the popup.
						self?.postOrderNotification(.declinedOrder)
						SoundsMaker.main.alert()
						RescountsAlert.showAlert(title: String.localizedStringWithFormat(l10n("orderNoOK"), self?.currentRestaurant?.name ?? ""),
							text: self?.generateDeclinedOrderText(json: items) ?? "",
							icon: nil,
							postIconText: nil,
							options: [l10n("returnMenu").uppercased()],
							callback: nil)
					}
					print("The order id format is wrong.")
					callback?(false, items)
				}
			}
		})
	}
	//UNREVIEWED TAG
	public func restoreTable(callback:@escaping()->Void) {
		// 'getOpenTableForUser' mutates our current order
		TableService.getOpenTableForUser(callback:{ [weak self] (table, piOrderCode) in
			self?.currentTable = table
			self?.currentTable?.piOrderNum = piOrderCode ?? ""
			
			if let table = table {
				SearchService.fetchRestaurant(restaurantID: table.restaurantID, callback: { (restaurant) in
					table.restaurantName = restaurant?.name ?? table.restaurantName
					self?.currentRestaurant = restaurant
					self?.refreshOrderToolBar()
				})
				self?.startPollingTableIfNecessary()
				self?.startPollingOrderIfNecessary()
			}
			callback()
		})
	}
	
	public func refreshOrderToolBar() {
		NotificationCenter.default.post(name: .orderChanged, object: nil)
	}
	
	public func orderTotalAsString() -> String {
           var isRDeals =  false
         if orders.pendingItems.count > 0 {
             for order in orders.pendingItems {
                 if order.rDealsPrice != nil {
                     isRDeals = true
                     break
                 }
             }
         } else {
             for order in orders.confirmedItems {
                 if order.rDealsPrice != nil {
                     isRDeals = true
                     break
                 }
             }
         }
        return "\(CurrencyManager.main.getCost(cost: orders.getTotal(isRdeal: isRDeals)))"
	}
	
	public var hasPendingTable: Bool {
		return isPollingTable
	}
	
	public var hasPendingOrder: Bool {
		return isPollingOrder
	}
	
	public var isPolling: Bool {
		return isPollingOrder || isPollingTable
	}
	
	public func canAddTo(_ restaurant: Restaurant?) -> Bool {
		return (restaurant != nil &&
				self.currentRestaurant?.restaurantID == restaurant?.restaurantID &&
				(self.currentTable?.approved ?? false) &&
				!isPollingTable)
	}
	
	public func canShowReserveRestaurantInfo(_ restaurantID: String) -> Bool {
		return (currentRestaurant == nil || currentRestaurant?.restaurantID == restaurantID)
	}
	
	public var rDealsFee: Int {
        
        var isRDeals =  false
        if orders.pendingItems.count > 0 {
            for order in orders.pendingItems {
                if order.rDealsPrice != nil {
                    isRDeals = true
                    break
                }
            }
        } else {
            for order in orders.confirmedItems {
                if order.rDealsPrice != nil {
                    isRDeals = true
                    break
                }
            }
        }
        
        
		return isRDeals ? currentRestaurant?.rDealsInfo?.fee ?? 0 : 0
	}
	
	public var multipleOrder: Bool {  // This is used to tell us if it's users' first-time order.
		return orders.confirmedItems.count > 0
	}
	
	// MARK: - Private Helpers
	
	func generateDeclinedOrderText(json: [[String : Any]]?) -> String? {
        var retVal: String = ""
        var declinedItems: [String: [String: Int]] = [:]
		json?.forEach({ (declinedItem) in
			if let declinedReasonText: String = declinedItem["declineReasonEn"] as? String {
                if let declinedItemID = declinedItem["itemID"] as? String, let declinedItemTitle = self.getMenuItem(itemID: declinedItemID) {
                    var items: [String: Int] = declinedItems[declinedReasonText] ?? [:]
                        items[declinedItemTitle.title] = (items[declinedItemTitle.title] ?? 0) + 1
                        declinedItems[declinedReasonText] = items
                    orders.removeItem(declinedItemTitle)

                }
			}
		})
		
        let declinedReasons: [String] = Array(declinedItems.keys)
        for reasons in declinedReasons {
            if let reasons = declinedItems[reasons] {
                for itemName in Array(reasons.keys) {
                    if let itemCount = reasons[itemName] {
                        retVal += "\(itemCount)x \(itemName)\n"
                    }
                }
            }
            
            retVal += "\(l10n("reason")): \(reasons)"
            if declinedReasons.last != reasons {
                retVal += "\n\n"
            }
        }
		
		return retVal
	}
	
	func startPollingTableIfNecessary() {
		if !isPollingTable, let approved = self.currentTable?.approved, !approved {
			pollCount = 0;
			self.pollForApprovedTable()
			return;
		}

	}
	
	func startPollingTableForAutoCancelCheck() {
		if !isPollingTable {
			pollCount = 0;
			self.pollForApprovedTable()
			return;
		}
		
	}
	
	func startPollingOrderIfNecessary() {
		if !isPollingOrder, self.currentTable?.approved ?? false, orders.pendingItems.count > 0 {
			pollCount = 0
			self.pollForApprovedOrder(nil)
			return;
		}
		
	}
	
	public func postOrderNotification(_ name: Notification.Name) {
		print("Order state changed: \(name)")
		NotificationCenter.default.post(name: name, object: self)
		NotificationCenter.default.post(name: .orderChanged, object: self)
	}
}

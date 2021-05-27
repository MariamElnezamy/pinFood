//
//  MenuOrderViewController.swift
//  Rescounts
//
//  Created by Monica Luo on 2018-08-16.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation
import UIKit
import PassKit
import Stripe

protocol MenuOrderTableViewCellDelegate: NSObjectProtocol {
	func MenuOrderDidTapTrash(_ sender: MenuOrderTableViewCell )
	func MenuOrderRemoveOrderItem(_ sender: MenuOrderTableViewCell, _ item: OrderItem)
    func MenuOrderDidTapEdit(_ sender: MenuOrderTableViewCell )
    func MenuOrdeEditOrderItem(_ sender: MenuOrderTableViewCell, _ item: OrderItem)
}


class MenuOrderViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, MenuOrderTableViewCellDelegate {

	
	private let kCellId = "cellId"
	private let tableView = UITableView(frame: .arbitrary)
	private var pageTitle: String = (OrderManager.main.currentTable?.piOrderNum == "" ? l10n("orderTitle1").uppercased() : "\(l10n("orderTitle2")) - #\(OrderManager.main.currentTable?.piOrderNum ?? "XXXX")")
	
	private let restaurant : Restaurant
	
	private let userOrder: UserOrder
	
	private var pendingList : OrderItemList
	private var confirmedList:  OrderItemList
	
	private let background = UIView()
	private let tableSeparator = UIView()
	private let addMore = RescountsButton(frame: .arbitrary)
	private let submit = RescountsButton()
	
	private let kButtonLabelLeftMargin : CGFloat = 24
	private let kButtonWidth : CGFloat = 167
	private let kButtonHeight :  CGFloat = 50
	private let kButtonRightMargin : CGFloat = 26
	private let kButtonBottonMargin : CGFloat = 20
	private let kButtonFontSize : CGFloat = 15
	private var receiptLength : CGFloat = 0
	private var showLoyalty : Bool = AccountManager.main.user?.hasEnoughLoyaltyPoints ?? false
	
	public var footerView: MenuOrderFooterView? = nil
	
	
	//MARK: - Initialization
	
	init( restaurant: Restaurant,  userOrder: UserOrder) {
		self.userOrder = userOrder
		self.restaurant = restaurant
		
		pendingList = OrderItemList(menuList: userOrder.pendingItems )
		confirmedList = OrderItemList(menuList: userOrder.confirmedItems)
		
		super.init(nibName: nil, bundle:nil)
        
        var isRDeals =  false
        
        let allOrdersArray:[MenuItem] = self.userOrder.pendingItems + self.userOrder.confirmedItems

        if allOrdersArray.count > 0  {
                     for order in allOrdersArray {
                         if order.rDealsPrice != nil {
                             isRDeals = true
                             break
                         }
                         
                     }
                 }
        
        
        
  
//		let isRDeals = OrderManager.main.currentTable?.isRDeals ?? false
		showLoyalty = showLoyalty && !isRDeals
		
		footerView = MenuOrderFooterView(frame: .arbitrary,
										 signup: userOrder.getFirstTimeBonus(),
										 loyaltyInfo: userOrder.loyaltyInfo,
										 showBonus: userOrder.hasFirstTimeBonus() && !isRDeals,
										 showRDeals: isRDeals,
										 showLoyalty: showLoyalty,
										 showTip: (OrderManager.main.currentTable?.shouldApplyTip == true) && (restaurant.defaultTip > 0),
										 showAlcoholicWarning: userOrder.containsAlcohol(),
										 showDiscount: (userOrder.discountInfo > 0) ? true : false,
										 discount: userOrder.discountInfo,
										 defaultTip: restaurant.defaultTip)
		
		updateFooterValues()
		
		footerView?.useLoyaltyChanged = { [weak self] in
			self?.userOrder.useLoyaltyBonus = self?.footerView?.loyaltyPointsCheckbox.on ?? false
			self?.updateFooterValues()
		}
	}
	
	required init?(coder aDecoder: NSCoder){
		assert(false)
		
		self.userOrder = UserOrder()
		
		self.pendingList = OrderItemList(menuList: userOrder.pendingItems )
		self.confirmedList = OrderItemList(menuList: userOrder.confirmedItems)
		
		self.restaurant = Restaurant(id: "-1", name: l10n("invalidRes"), location: Constants.Location.toronto)
		super.init(coder:aDecoder)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	private func refreshLists() {
		self.pendingList.refresh(menuOrder: self.userOrder.pendingItems)
		self.confirmedList.refresh(menuOrder: self.userOrder.confirmedItems)
		tableView.reloadData()
	}
	
	
	//MARK: - UIViewController Methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupNavigationBar()
		setUpBackground()
		setupSubmitButton()
		setupAddMoreButton()
		setupTableView()
		
		refreshLists()
		
		NotificationCenter.default.addMainObserver(forName: .approvedOrder, owner: self, action: MenuOrderViewController.tableStateChanged)
		NotificationCenter.default.addMainObserver(forName: .endedTable,    owner: self, action: MenuOrderViewController.tableStateChanged)
	}
	
    func reRenderFooterView() {
//

        var shouldShowLoyalty = false
        var isRDeals =  false
        if self.userOrder.pendingItems.count > 0 {
         for order in self.userOrder.pendingItems {
             if order.rDealsPrice != nil {
                 isRDeals = true
                break
             }
         }
        } else {
            for order in self.userOrder.confirmedItems {
                   if order.rDealsPrice != nil {
                       isRDeals = true
                      break
                   }
               }
        }
        shouldShowLoyalty = AccountManager.main.user?.hasEnoughLoyaltyPoints ?? false && !isRDeals
        
        footerView = MenuOrderFooterView(frame: .arbitrary,
                                         signup: userOrder.getFirstTimeBonus(),
                                         loyaltyInfo: userOrder.loyaltyInfo,
                                         showBonus: userOrder.hasFirstTimeBonus() && !isRDeals,
                                         showRDeals: isRDeals,
                                         showLoyalty: shouldShowLoyalty,
                                         showTip: (OrderManager.main.currentTable?.shouldApplyTip == true) && (restaurant.defaultTip > 0),
                                         showAlcoholicWarning: userOrder.containsAlcohol(),
                                         showDiscount: (userOrder.discountInfo > 0) ? true : false,
                                         discount: userOrder.discountInfo,
                                         defaultTip: restaurant.defaultTip)
        updateFooterValues()
        footerView?.useLoyaltyChanged = { [weak self] in
            self?.userOrder.useLoyaltyBonus = self?.footerView?.loyaltyPointsCheckbox.on ?? false
            self?.updateFooterValues()
        }
         setupTableView()
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		refreshLists()
        updateSubmitButton()
        updateFooterValues()
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		
		background.frame = view.bounds
		
		let hasItems = (OrderManager.main.orders.pendingItems.count != 0 || OrderManager.main.orders.confirmedItems.count != 0)
		var buttonWidth = (view.frame.width - kButtonRightMargin * 3 )/2
		if (!hasItems){
			buttonWidth = (view.frame.width - kButtonRightMargin * 2 )
		}
		addMore.frame = CGRect(kButtonRightMargin, view.frame.height - kButtonHeight - kButtonBottonMargin, buttonWidth, kButtonHeight)
		
		tableView.frame = CGRect(0, 0, view.frame.width, view.frame.height - kButtonBottonMargin*2 - kButtonHeight)
		if (!Helper.iosAtLeast("11.0.0")) {
			//self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0); //Has same issue as browsListView, not working for the first time
			self.tableView.frame.origin.y = 64 // status bar + navigation bar
			self.tableView.frame.size.height = view.frame.height - kButtonBottonMargin*2 - kButtonHeight - 64
			
			if self.background.isHidden {
				self.tableView.frame.size.height = view.frame.height
			}
		}
		
		tableSeparator.frame = CGRect(0, tableView.frame.maxY, view.frame.width, Constants.Menu.separatorHeight)
		
		submit.frame = CGRect(view.frame.width - kButtonRightMargin - buttonWidth, view.frame.height - kButtonBottonMargin - kButtonHeight, buttonWidth, kButtonHeight)
		
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	override internal func orderToolbarItems() -> [UIBarButtonItem]? {
		// We don't want to show the order toolbar if we're already on the order screen
		return nil
	}
	
	
	//MARK: - public funcs

	public func hideButtons() {
		self.background.isHidden = true
		tableView.frame = CGRect(0, 0, view.frame.width, view.frame.height)
		self.view.backgroundColor = .white
		tableSeparator.isHidden = true
	}
	
	//MARK: - UI Helpers
	
	private func tableStateChanged(_ notification: Notification?) {
		self.tableView.reloadData()
		updateSubmitButton()
		updateFooterValues()
		self.view.setNeedsLayout()
	}
	
	private func sendingOrder () {
		
		if HoursManager.isAutoCancelTimerRunning { // if my local timer is longer than the backend timer, before sending the order, we should first check if the table has been auto canceld.
			TableService.getTableStatus(tableID: OrderManager.main.currentTable?.tableID ?? "") { [weak self] (approved, error, response) in
				if(approved ?? false) { //if the table is approved
                    self?.updateRdealsStatus()

				} else if (response == "Canceled") {
					HoursManager.showEndAutoCancelTimerPopUp()
					HoursManager.resetAutoCancelTimer()
					//Clear all table
					OrderManager.main.clearTable()
					OrderManager.main.postOrderNotification(.endedTable)
				}
			}
		} else {
            updateRdealsStatus()

		}
		
	}
	
	private func sendingOrderHelper() {
		//Send api call to the server with all menuitems
		OrderManager.main.submitAndStartNewOrder() { [weak self] (approved, declinedItems) in
			if approved {
				self?.gotApproved()
			} else {
				self?.gotDeclined(theList: declinedItems ?? [])
//				HoursManager.showStartAutoCancelTimerPopUp()
				HoursManager.startAutoCancelTimer()
			}
		}
		updateSubmitButton()
	}

    private func setUpBackground(){
        background.backgroundColor = UIColor.white
        self.view.addSubview(background)
    }
	
	private func setupAddMoreButton(){
		addMore.displayType = .secondary
		addMore.setTitle(l10n("addMenu").uppercased(), for: .normal)
		addMore.setTitleColor(.dark, for: .normal)
		addMore.titleLabel?.font = UIFont.rescounts(ofSize: kButtonFontSize)
		addMore.addAction(for: .touchUpInside, { [weak self] in
			self?.goBackToMenu()
		})
		self.background.addSubview(addMore)
	}
	
	
	private func setupTableView() {
		tableView.dataSource = self
		tableView.delegate = self
		tableView.register(MenuOrderTableViewCell.self, forCellReuseIdentifier: kCellId)
		tableView.separatorStyle = .none
		tableView.allowsSelection = false
		tableView.backgroundColor = .white
		
		let header = MenuOrderHeaderView(name: self.restaurant.name, address: self.restaurant.address, table: OrderManager.main.currentTable)
		header.frame = CGRect(0,0, view.frame.width, header.idealHeight(forWidth: UIScreen.main.bounds.width))
		tableView.tableHeaderView = header
		
		footerView?.frame = CGRect(0, 0, view.frame.width, footerView?.getHeight() ?? 0)

		tableView.tableFooterView = footerView
		
		view.addSubview(tableView)
		
		tableSeparator.backgroundColor = .separators
		view.addSubview(tableSeparator)
	}
	
	private func setupSubmitButton() {
		
		submit.setTitleColor(.dark, for: .normal)
		submit.titleLabel?.font = UIFont.rescounts(ofSize: kButtonFontSize)
		submit.addAction(for: .touchUpInside, { [weak self] in
			let digit : String = AccountManager.main.user?.card?.last4 ?? ""
			self?.setupSubmitAlert(digit: digit)
		})
		self.background.addSubview(submit)
		updateSubmitButton()
	}
	
	private func setupSubmitAlert(digit: String){
		
		if OrderManager.main.isPolling {
			RescountsAlert.showAlert(title: l10n("pollingMessTitle"), text: l10n("pollingMessText"))
			
		} else if (self.userOrder.pendingItems.count == 0){
			//if the pending item size is 0, pay the bill, go to the pay bill page
			
			// But if the checkout time is early than the book time, show reminder pop up
			if (NSInteger (OrderManager.main.currentTable?.seatingAt.timeIntervalSinceNow ?? 0.00) > 0){
				print("Checkout earlier than seating at")//Show the pop up
				RescountsAlert.showAlert(title: l10n("checkoutEarlyTitle"), text: String.localizedStringWithFormat(l10n("checkoutEarlyText"), HoursManager.hoursStringFromDate(OrderManager.main.currentTable?.seatingAt ?? Date())) , icon: nil, postIconText: nil, options: [l10n("no"), l10n("checkout")]) { (alert, buttonIndex) in
					if (buttonIndex == 0) {
						return;
					} else {
						self.goPayBill()
					}
				}
			} else {
				goPayBill()
			}

		} else {
            var isRDeals =  false
                 if self.userOrder.pendingItems.count > 0 {
                  for order in self.userOrder.pendingItems {
                      if order.rDealsPrice != nil {
                          isRDeals = true
                         break
                      }
                  }
                 } else {
                     for order in self.userOrder.confirmedItems {
                            if order.rDealsPrice != nil {
                                isRDeals = true
                               break
                            }
                        }
                 }
            
			//This is showing entire pre-authorized pop up
	    	var text: String = ""
			var price: String = ""
			if OrderManager.main.multipleOrder {
				price = CurrencyManager.main.getCost(cost: OrderManager.main.orders.getPreAuthorizedSubtotal())
			} else {
				price = CurrencyManager.main.getCost(cost: OrderManager.main.orders.getTotal(isRdeal: isRDeals))
			}
			if (!PaymentManager.main.applePayOption ) {
				text = String.localizedStringWithFormat( l10n("submitOrderTextCredit"), price , "\("XX"+digit.suffix(2))")
			} else {
				text = String.localizedStringWithFormat(l10n("submitOrderTextApple"), price)
			}
	
			RescountsAlert.showAlert(title: l10n("submitOrderTitle"), text: text, icon: nil, postIconText: nil, options: [l10n("back"), l10n("submit")]) { ( alert , buttonIndex) in
				
				if (buttonIndex == 1) {
					// create a token for apple pay user for the first time
					if(PaymentManager.main.applePayOption){
						//AccountManager.main.user?.stripeToken? is expected to be nil for the first time
						//TODO: Change this to the correct price
						let totalPrice: Int = OrderManager.main.orders.getTotal(isRdeal: isRDeals)
						PaymentManager.main.applePayRequest(totalPrice: totalPrice) { [weak self] (passed: Bool, paymentVC: PKPaymentAuthorizationViewController?) in
							guard let sSelf = self else { return }
							
							if passed, let paymentVC = paymentVC {
								paymentVC.delegate = sSelf
								sSelf.present(paymentVC, animated: true, completion: nil) //Gonna be sending oder in paymentauthorizationcontroller
							} else {
								RescountsAlert.showAlert(title: l10n("applePayErrorTitle"), text: l10n("submitOrderApplePayError")) //<- deal to the token missing, or token wasn't created cannot be sent.
							}
						}
					
					} else { // This is for credit card payment
						self.sendingOrder()
					}
					
				}
                self.tableView.reloadData()
			}
		}
	}
   
    
	
	// Set up Navigation Bar
	
	private func setupNavigationBar() {
		self.navigationController?.navigationBar.backgroundColor = .dark
		self.navigationController?.navigationBar.barTintColor = .white
		self.navigationController?.navigationBar.tintColor = .white
		self.navigationItem.title = pageTitle
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
	}
	
	private func updateFooterValues() {
//		let isRDeals = OrderManager.main.currentTable?.isRDeals ?? false
        
        var isRDeals =  false
        if self.userOrder.pendingItems.count > 0 {
         for order in self.userOrder.pendingItems {
             if order.rDealsPrice != nil {
                 isRDeals = true
                break
             }
         }
        } else {
            for order in self.userOrder.confirmedItems {
                   if order.rDealsPrice != nil {
                       isRDeals = true
                      break
                   }
               }
        }
        
		let rDealsFee = OrderManager.main.rDealsFee
        footerView?.showRDeals = isRDeals
		footerView?.updateTotalPrice(price: OrderManager.main.orders.getTotal(isRdeal: isRDeals))
		footerView?.updateSubtotalPrice(price: OrderManager.main.orders.getRawSubtotal())
		footerView?.updateRDealsPrice(price: rDealsFee, discount: OrderManager.main.orders.getRDealsDiscount())
		footerView?.updateTaxPrice(price:  OrderManager.main.orders.getTax(isRdeal: isRDeals))
		footerView?.updateTipPrice(price: OrderManager.main.orders.getTip(), percent: OrderManager.main.currentRestaurant?.defaultTip ?? Constants.User.defaultTip)
		footerView?.updateLoyaltyPointsValue(use: userOrder.useLoyaltyBonus, value: userOrder.getLoyaltyBonus())
		footerView?.updateAlcoholicWarningLabel(shouldAdd: userOrder.containsAlcohol(), showRDeals: isRDeals)
		footerView?.updateSignUpBonusLabel(showBonus: userOrder.hasFirstTimeBonus() && !isRDeals)
	}
    private func updateRdealsStatus() {
        var isRDeals =  false
           if self.userOrder.pendingItems.count > 0 {
            for order in self.userOrder.pendingItems {
                if order.rDealsPrice != nil {
                    isRDeals = true
                   break
                }
            }
           } else {
               for order in self.userOrder.confirmedItems {
                      if order.rDealsPrice != nil {
                          isRDeals = true
                         break
                      }
                  }
           }
        ReservationService.updateRdeals( isRDeals: isRDeals, callback: { (success: Bool?, error: NSError?,msg: String?)  in
            if success ?? false  {
                print(success ?? "***")
                self.sendingOrderHelper()
            } else {
               // print(error?.code)
            }

            })
    }
	private func updateSubmitButton() {
		let buttTitle = OrderManager.main.orders.pendingItems.count == 0 ? "Rate & Review".uppercased() : "Place your order"
		submit.setTitle(buttTitle, for: .normal)
		
		let hasItems = (OrderManager.main.orders.pendingItems.count != 0 || OrderManager.main.orders.confirmedItems.count != 0)
		submit.isHidden = !hasItems
		
		if (submit.isHidden) {
			//Strech the add menu item button
			let buttonWidth = (view.frame.width - kButtonRightMargin * 2  )
			addMore.frame = CGRect(kButtonRightMargin, view.frame.height - kButtonHeight - kButtonBottonMargin, buttonWidth, kButtonHeight)
		} else {
			//Otherwise, squeeze it
			let buttonWidth = (view.frame.width - kButtonRightMargin * 3 )/2
			addMore.frame = CGRect(kButtonRightMargin, view.frame.height - kButtonHeight - kButtonBottonMargin, buttonWidth, kButtonHeight)
		}
	}
	
	
	// MARK: - private helpers
	
	@objc private func shareTapped() {
		let vc = SharingManager.getSharingVC()
		self.present(vc, animated: true, completion: nil)
	}
	
	private func goPayBill() {
		let vc = FeedbackViewController(tableID: OrderManager.main.currentTable?.tableID ?? "", restaurantName : self.restaurant.name, serverName : OrderManager.main.currentTable?.waiter?.firstName ?? "",  price : OrderManager.main.orders.getRawSubtotal(), fixedTip: OrderManager.main.currentTable?.shouldApplyTip ?? false)
		let nc = BaseNavigationController(rootViewController: vc)
		present(nc, animated: true, completion: nil)
	}
	
	private func goBackToMenu() {
		if let nc = navigationController {
			var VCs = nc.viewControllers
			if VCs.count >= 2, let restaurant = OrderManager.main.currentRestaurant {
				// Make sure our previous screen was the Restaurant Menu. If not, insert it.
				let prevVC = VCs[VCs.count - 2]
				if (prevVC as? RestaurantViewController == nil || (prevVC as? RestaurantViewController)?.restaurant.restaurantID != restaurant.restaurantID) {
                    var isRDeals =  false

                    if self.userOrder.confirmedItems.count > 0 {
                     for order in self.userOrder.confirmedItems {
                         if order.rDealsPrice != nil {
                             isRDeals = true
                            break
                         }
                     }
                    }
                    
					let vc = RestaurantViewController(restaurant, isRDeals:isRDeals)
					vc.needToScrollMenu = true
					VCs.insert(vc, at: VCs.count - 1)
					nc.setViewControllers(VCs, animated: false)
				} else {
					(prevVC as? RestaurantViewController)?.needToScrollMenu = true
				}
			}
			nc.popViewController(animated: true)
		}
	}
	
	
	// MARK: - delegate funcs
	
	func MenuOrderDidTapTrash(_ sender: MenuOrderTableViewCell ) {
		guard let tappedIndexPath = tableView.indexPath(for: sender) else {return}
		self.tableView.deleteRows(at: [tappedIndexPath], with: .automatic)
	}
	
	func MenuOrderRemoveItem(_ sender: MenuOrderTableViewCell, _ item: MenuItem){
		self.userOrder.removeItem(item)
        reRenderFooterView()
		updateSubmitButton()
		
		//TODO: Updating the total price based on the item + tax + signup Bonus
		print("TODO: Grab tax from actual restaurant")
		updateFooterValues()
		if let trackingDict = GAIDictionaryBuilder.createEvent(withCategory: "action", action: "removed_order_item", label: nil, value: nil)?.build() as? [AnyHashable : Any] {
			GAI.sharedInstance()?.defaultTracker.send(trackingDict)
		}
	}
    
    func MenuOrderDidTapEdit(_ sender: MenuOrderTableViewCell) {
        
    }
    
    func MenuOrdeEditOrderItem(_ sender: MenuOrderTableViewCell, _ item: OrderItem) {
        
        
        let vc = MenuOptionsViewController(item: item.getItem(), restaurant: restaurant, rDeals: item.getItem().rDealsPrice != nil)
        vc.editMode = true
        vc.numberOfItemsForEditMode = item.counter

        
        navigationController?.pushViewController(vc, animated: true)
    }
    
	
	func MenuOrderRemoveItem(_ sender: MenuOrderTableViewCell, _ itemUmID: String){

        self.userOrder.removeItem(itemUmID)
        reRenderFooterView()
		updateSubmitButton()
		
		//TODO: Updating the total price based on the item + tax + signup Bonus
		print("TODO: Grab tax from actual restaurant")
		updateFooterValues()
		if let trackingDict = GAIDictionaryBuilder.createEvent(withCategory: "action", action: "removed_order_item", label: nil, value: nil)?.build() as? [AnyHashable : Any] {
			GAI.sharedInstance()?.defaultTracker.send(trackingDict)
		}
	}
	
	func MenuOrderRemoveOrderItem(_ sender: MenuOrderTableViewCell, _ item: OrderItem) {
        for id in item.umIDList {
			MenuOrderRemoveItem(sender, id)
		}
        reRenderFooterView()

		self.refreshLists()
        updateFooterValues()

	}
	
	func gotApproved() {
		//Right now turn everything into confirmed
		let cells = self.tableView.visibleCells as? Array<MenuOrderTableViewCell>
		cells?.forEach { cell in
			cell.removeTrashButton()
			if (cell.getType() == MenuItemType.pending){
				cell.turnToConfirmed()
			}
		}
		
		updateSubmitButton()
	}
	
    func gotDeclined(theList: [[String: Any]]){
		if theList.count > 0 {
			for item in theList {
                
                // TODO: Very quick and dirty fix for bug related to removing menu item with same itemID and different sides.
                //       Replace once we find a better way to match declined items from the backend with our pending order items.
                //       For now comparing ItemID + MenuOptionItems (beverages, sides, etc) for matches.
				//		 We should set-up/use optionmenuids isntead of itemids removing menu items in the future.
                
                // Get all menu option items (sides, beverages, etc)
                var menuOptionItems: [String] = []
                if let options = item["options"] as? [String: Any] {
                    options.values.forEach { (optionSubSection) in
                        if let optionSubSection = optionSubSection as? [String] {
                            optionSubSection.forEach({ (optionItem) in
                               menuOptionItems.append(optionItem)
                            })
                        }
                    }
                }
                
                if let itemID = item["itemID"] as? String {
                    OrderManager.main.orders.removeItemByID(itemID, menuOptionItems:menuOptionItems)
                }
			}
			self.refreshLists()
			self.tableView.reloadData()
		}
		
		updateSubmitButton()
		
		print("TODO: Grab tax from actual restaurant")
		updateFooterValues()
		
		OrderManager.main.refreshOrderToolBar()
	}
	
	// MARK: - table view setup
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return   self.confirmedList.count() + self.pendingList.count()
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: kCellId, for: indexPath as IndexPath)
		guard let typedCell = cell as? MenuOrderTableViewCell else {
			return cell
		}
		
		typedCell.setSeparatorShowing(true)
		
		typedCell.delegate = self
		typedCell.clipsToBounds = true
		
		return typedCell
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		guard let cell = cell as? MenuOrderTableViewCell else { return }
		
		if (indexPath.row < self.confirmedList.count() + self.pendingList.count()) {
			if (indexPath.row < self.confirmedList.count()) {
				cell.prepareForOrderItem(self.confirmedList.getAtIndex(indexPath.row), true)
			} else {
				cell.prepareForOrderItem(self.pendingList.getAtIndex(indexPath.row - self.confirmedList.count()), false)
			}
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		if (indexPath.row < self.confirmedList.count()) {
			return MenuOrderTableViewCell.heightForItem(self.confirmedList.getAtIndex(indexPath.row).getItem(), confirmed: true, width: self.view.frame.width)
		} else {
			return MenuOrderTableViewCell.heightForItem(self.pendingList.getAtIndex(indexPath.row - self.confirmedList.count()).getItem(), confirmed: false, width: self.view.frame.width)
		}
	}
	
	
}

extension MenuOrderViewController: PKPaymentAuthorizationViewControllerDelegate {
	@available(iOS 11.0, *)
	func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
		// Just create a token without paying anything
		print("Apple Pay - did authorize")
		if AccountManager.main.user?.stripeToken == nil {
			STPAPIClient.shared().createToken(with: payment) { (stripeToken, error) in
				if error != nil {
					print("PAYMENTMETHODSVIEWCONTROLLER: having trouble of making token ")
				}
				print("Updating the token id: \(String(describing: stripeToken?.tokenId))")
				//	completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.success, errors: nil))
				UserService.updateUser(stripeToken: stripeToken) { (user, error) in
					if (error != nil) {
						RescountsAlert.showAlert(title: l10n("addPaymentErrorTitle"), text: l10n("addPaymentErrorText"), callback: nil)
					} else {
						self.showSuccessfulOnApplePay()
						AccountManager.main.user?.stripeToken = stripeToken
						
						self.sendingOrder()
						
						self.dismiss(animated: true, completion: nil)
						
					}
				}
				
			}
		} else { // No stripe token need to be created, just skip creating and updating the token process
			showSuccessfulOnApplePay()
			self.sendingOrder()
			self.dismiss(animated: true, completion: nil)
		}
	}
	
	func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
		// Dismiss the Apple Pay UI
		dismiss(animated: true, completion: nil)
	}
	
	public func showSuccessfulOnApplePay() {
		RescountsAlert.showAlert(title: "", text: l10n("submitOrderOkApplePayText"), callback: nil)
	}
}

//
//  MenuOptionsViewController.swift
//  Rescounts
//
//  Created by Monica Luo on 2018-08-15.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import Foundation

protocol MenuOptionsDelegate : NSObjectProtocol {
	func clickedAddToOrderButton( _ sender: MenuOptionsFooterView, _ info: String)
    func addMenuItemToOrder (_ info: String, popVC: Bool)
	func addOptionItemToList(key: String, cost: Int, optionID: Int)
	func removeOptionItemToList(key: String, cost: Int, optionID: Int)
	func setupAddToOrderButton(_ buttonView: UIView)
	func getMainRestaurantName() -> String
}

class MenuOptionsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, MenuOptionsDelegate {
	private var primaryMenuItem : MenuItem?
	private var restaurant: Restaurant!
	
	private var pageTitle = String()
	private var descrip = String()
	private var nutrition = String()
	private var calories : Int = 0
	private var totalPrice: Int = 0
	private var optionPrice: Int = 0
	private var thumbnail: URL?
	private var isRDeals: Bool = false
	
	private var mainView = UIView() //<--------------------------------------------------------------- probably a scroll view\
	
	let cellId = "cellId"
	private var tableView = UITableView()
	private let tapCatchingView = UIView()
	
	private var optionList : [MenuItemOption] = []
	
	let kStartingY : CGFloat = 60.0   //<--------the height of navigation bar + status bar
	public var editMode = false
    public var numberOfItemsForEditMode = 1

	public var numItems: Int {
		return (tableView.tableFooterView as? MenuOptionsFooterView)?.numItems ?? 1
	}
	
	
	// MARK: - Initialization
	
	init( item : MenuItem, restaurant: Restaurant, rDeals: Bool) {
		super.init(nibName: nil, bundle: nil )
		self.restaurant = restaurant
		let itemPrice = rDeals ? item.rDealsPriceOrPrice : item.price
		secondaryInit(item.title, item.details, item.nutrition, item.calories , itemPrice, item.options ?? [], item.thumbnail)
		self.primaryMenuItem = item
		isRDeals = rDeals
	}
	
	private func secondaryInit(_ title: String, _ descrip: String, _ nutrition: String, _ calories: Int , _ totalPrice : Int, _ list :[MenuItemOption]? = [], _ thumbnail : URL? ){
		
		list?.forEach{(item : MenuItemOption) in
			optionList.append(item)
		}
		
		self.pageTitle = title
		
		self.descrip = descrip
		
		self.nutrition = nutrition
		
		self.calories = calories
		
		self.totalPrice = totalPrice
		
		self.thumbnail = thumbnail
		
		self.mainView.backgroundColor = UIColor.lightGray
		self.mainView.setPosition(0, kStartingY )  //<--------------------------------- 60 should be replaced to be height of navication bar  + status bar
		
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	//MARK: - UIViewController Methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		mainView.frame = view.bounds
		self.view.addSubview(mainView)
		
		commonInit()
		
		
		tableView = UITableView(frame: mainView.bounds)
		tableView.dataSource = self
		tableView.delegate = self
		tableView.register(MenuOptionsTableViewCell.self, forCellReuseIdentifier: cellId)
		tableView.separatorStyle = .none
		tableView.allowsSelection = false
		tableView.keyboardDismissMode = .interactive
		tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		let header = MenuOptionsHeaderView(restaurant: self.restaurant, descript: self.descrip, nutrition: self.nutrition, calories : self.calories, imageURL: self.thumbnail)
		header.frame = CGRect(0,0, self.view.frame.width, header.getIdealHeight(width: UIScreen.main.bounds.width))
		tableView.tableHeaderView = header
		
		let footer = MenuOptionsFooterView(frame: .arbitrary, price: self.totalPrice, restaurant: restaurant)
		footer.frame = CGRect(0,0, self.view.frame.width, footer.getIdealHeight(restaurant: restaurant))
		footer.delegate = self
		tableView.tableFooterView = footer
		
		NotificationCenter.default.addMainObserver(forName: .UITextFieldTextDidChange, object: footer.numberTextView, owner: self, action: MenuOptionsViewController.numberOfItemsChanged)
		
		self.mainView.addSubview(tableView)
		
		setupKeyboardDismissView()
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	override func viewWillLayoutSubviews() { //<------------------------------ This function make the radio button work
		super.viewWillLayoutSubviews()
		
		self.mainView.setSize(view.frame.width, view.frame.height)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
        (tableView.tableFooterView as? MenuOptionsFooterView)?.refresh(restaurant: restaurant,numberofItems: self.numberOfItemsForEditMode)
		(tableView.tableHeaderView as? MenuOptionsHeaderView)?.refresh()
		let cells = self.tableView.visibleCells
		for cell in cells {
			(cell as? MenuOptionsTableViewCell)?.refresh()
		}
	}
	
	override internal func orderToolbarItems() -> [UIBarButtonItem]? {
		// We don't want to show the order toolbar when on the menuOptions view, let the add to Order button stick to the bottom
		return nil
	}
	
	//MARK: - Public Methods
	
	func getMainRestaurantName() -> String{
		return restaurant.name
	}
	
	//MARK: - delegate funcs
	
	
	func setupAddToOrderButton(_ buttonView : UIView){
		let height : CGFloat = 70.0
		buttonView.frame = CGRect(0, self.view.frame.height - height, self.view.frame.width, height)
		self.view.addSubview(buttonView)
	}
	
    func addMenuItemToOrder( _ info : String, popVC: Bool = true) {
		// Check minimums/limits of all items
		var optionListCount = 0
		for opt in optionList {
			if let minToSelect = opt.minimum, opt.selectedIndices.count < minToSelect {
				let theText: String = String.localizedStringWithFormat(minToSelect == 1 ? l10n("minToSelect.one") : l10n("minToSelect.other"), minToSelect, opt.title)
				RescountsAlert.showAlert(title: "", text: theText)
				return
			} else if let limitToSelect = opt.limit, opt.selectedIndices.count > limitToSelect, limitToSelect != 0 {
				let theText: String = String.localizedStringWithFormat(limitToSelect == 1 ? l10n("limitToSelect.one") : l10n("limitToSelect.other"), limitToSelect, opt.title)
				RescountsAlert.showAlert(title: "", text: theText)
				return
			}
			optionListCount += opt.selectedIndices.count
		}
		
		//Added menu item to current Order
		for _ in 0..<self.numItems {
			guard let newItem = self.primaryMenuItem else {return}
			newItem.assignRequests(info)
			OrderManager.main.orders.addItem(newItem)
		}
		
		if let trackingDict = GAIDictionaryBuilder.createEvent(withCategory: "action", action: "added_order_item", label: nil, value: optionListCount as NSNumber)?.build() as? [AnyHashable : Any] {
			GAI.sharedInstance()?.defaultTracker.send(trackingDict)
		}
		
		// Close the MenuOptons view and go back to previous restaurant all menu view
        if popVC {
		self.navigationController?.popViewController(animated: true)
        }
	}
	
	func addOptionItemToList(key: String, cost: Int, optionID: Int) {
		optionList[optionID].selected(key: key)
		optionPrice = optionPrice + cost
		updateTotalPrice()
	}
	
	func removeOptionItemToList(key: String, cost: Int, optionID: Int) {
		optionList[optionID].removeOption(key: key)
		optionPrice = optionPrice - cost
		updateTotalPrice()
	}
	
	func clickedAddToOrderButton( _ sender: MenuOptionsFooterView, _ info : String = ""){
		
		if AccountManager.main.user == nil {
			AccountManager.main.showLoginUI(from: self)
		} else if OrderManager.main.hasPendingOrder { //If there is a pending order, we don't add menu to the list
			RescountsAlert.showAlert(title: l10n("noMoreItemDueToPendingOrderTitle"), text: l10n("noMoreItemDueToPendingOrderText"))
		} else if OrderManager.main.canAddTo(self.restaurant) { // if the table has been approved -> allow user to add menu
            
            if editMode {
                guard let newItem = self.primaryMenuItem else {return}

                for item in OrderManager.main.orders.pendingItems {
                    if item.itemID == newItem.itemID {
                        OrderManager.main.orders.removeItem(item)
                    }
                }
                addMenuItemToOrder(info)

            } else {
                addMenuItemToOrder(info)

            }
		} else if (OrderManager.main.currentTable == nil) {
			// if the table is not assigned yet
        for opt in optionList {
                    if let minToSelect = opt.minimum, opt.selectedIndices.count < minToSelect {
                        let theText: String = String.localizedStringWithFormat(minToSelect == 1 ? l10n("minToSelect.one") : l10n("minToSelect.other"), minToSelect, opt.title)
                        RescountsAlert.showAlert(title: "", text: theText)
                        return
                    } else if let limitToSelect = opt.limit, opt.selectedIndices.count > limitToSelect, limitToSelect != 0 {
                        let theText: String = String.localizedStringWithFormat(limitToSelect == 1 ? l10n("limitToSelect.one") : l10n("limitToSelect.other"), limitToSelect, opt.title)
                        RescountsAlert.showAlert(title: "", text: theText)
                        return
                    }
                }
        RescountsAlert.showAlert(title: "", text: l10n("noTableForOrderText"), icon: nil, postIconText: nil, options: [l10n("dineIn") , l10n("pickup")], callback: { [weak self] (alert, buttonIndex) in
                    self?.addMenuItemToOrder(info, popVC: false)
                    self?.showReserveConfirmationScreen(isPickup: (buttonIndex==1))
                })
			
		} else if (self.restaurant != OrderManager.main.currentRestaurant) {
			// if the menu is from other restaurants
			RescountsAlert.showAlert(title: l10n("tableIsOpenWarnTitle"), text: l10n("menuFromOtherResWarnText"), callback: nil)
		} else {
			RescountsAlert.showAlert(title: "", text: l10n("tableNotConfirmed"), callback: nil)
		}
		
	}
	
	private func tappedReserve() {
		if let VCs = navigationController?.viewControllers, VCs.count >= 2, let vc = VCs[VCs.count - 2] as? RestaurantViewController {
			vc.needToScrollMenu = true
		}
		navigationController?.popViewController(animated: true)
	}

	private func showReserveConfirmationScreen(isPickup: Bool) {
		let fakeButt = ReservationDetailsButton()
		fakeButt.updateData(numPeople: isPickup ? 0 : 2)
		let vc = ConfirmReservationViewController(restaurant: restaurant, numPeople: fakeButt.numPeople, desiredTime: fakeButt.desiredTime, rDeals: isRDeals)
		self.navigationController?.pushViewController(vc, animated: true)
	}

	
	// MARK: - UI Helpers
	
	private func commonInit() {
		self.view.backgroundColor = UIColor.dark; //<--------------------------------- very important to set the background is darkGray , aligh with navigation
		
		self.navigationItem.title = pageTitle
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
	}
	
	@objc private func shareTapped() {
		if AccountManager.main.user != nil {
			let vc = SharingManager.getSharingVC()
			self.present(vc, animated: true, completion: nil)
		} else {
			AccountManager.main.showLoginUI(from: self)
		}
	}
	
	private func setupKeyboardDismissView() {
		tapCatchingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
		tapCatchingView.addGestureRecognizer(tap)
	}
	
	@objc func dismissKeyboard() {
		updateTotalPrice()
		self.view.endEditing(true)
	}
	
	@objc func keyboardWillShow(notification: NSNotification) {
		if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
			if let textView = view.getFirstResponder(), let textSuper = textView.superview {
				
				let textFrame = textSuper.convert(textView.frame, to: self.view)
				let screenHeight = UIScreen.main.bounds.height
				let keyboardY = screenHeight - keyboardSize.height
				let toolbarHeight = screenHeight - view.frame.maxY
				
				if (textFrame.maxY > keyboardY) {
					tableView.frame.origin.y = -keyboardSize.height + toolbarHeight
					let bottomOffset = CGPoint(x: 0, y: tableView.contentSize.height - tableView.bounds.size.height)
					tableView.setContentOffset(bottomOffset, animated: true)
				}
			}
		}
		tapCatchingView.frame = view.bounds
		view.addSubview(tapCatchingView)
	}
	
	@objc func keyboardWillHide(notification: NSNotification){
		self.tableView.frame.origin.y = 0
		tapCatchingView.removeFromSuperview()
	}
	
	private func updateTotalPrice() {
		if let abstractView = tableView.tableFooterView as? MenuOptionsFooterView {
			abstractView.updateTotalPrice(price: self.numItems * (self.totalPrice + self.optionPrice))
		}
	}
	
	private func numberOfItemsChanged(_ notification: Notification) {
		updateTotalPrice()
	}
	
	
	//MARK: - UITableView Methods
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return optionList.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath as IndexPath)
		guard let typedCell = cell as? MenuOptionsTableViewCell else {return cell}
		typedCell.clipsToBounds = true
		typedCell.delegate = self
		return typedCell
	
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
		if let cell = cell as? MenuOptionsTableViewCell {
			let optionItem = optionList[indexPath.row]
			cell.prepareForMenuOption(optionItem, optionIndex : indexPath.row)
		} else {
			cell.textLabel?.text = "ERROR - ROW \(indexPath.row)"
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return MenuOptionsTableViewCell.getIdealHeight(item: optionList[indexPath.row], cellWidth: tableView.frame.width)
	}
}

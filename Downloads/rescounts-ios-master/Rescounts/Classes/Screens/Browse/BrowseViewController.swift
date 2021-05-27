//
//  BrowseViewController.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-15.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import MapKit

class BrowseViewController: BaseViewController, BrowseViewDelegate, SearchPanelDelegate, BrowseHeaderDelegate {
 
    

	var restaurants: [Restaurant] = []
	var filteredRestaurants: [Restaurant] = [] // If any local filtering done, we need to keep the original list separate to handle paging with the server
	let header = BrowseHeader()
	let contentContainer = UIView()
	let map = BrowseMapView()
	let list = BrowseListView()
	let pointsLabel = UILabel()
	
	var searchPanel: SearchPanel?
	var searchState: Bool = true // true: call nearby; false: search by text
    var offsetCount = 1

	var viewMode: BrowseViewMode = .List
	var currentView: UIView!
	
	enum BrowseViewMode: Int {
		case Map = 0
		case List = 1
	}
	
	
	// MARK: - UIViewController Methods
	
	deinit {
		removeObserver(self, forKeyPath: #keyPath(view.layer.sublayers))
		NotificationCenter.default.removeObserver(self)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		currentView = list

		let pointsView = setupPointsView()
		let rewardView = setupRewardView()
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rewardView)
		self.navigationItem.leftBarButtonItems = [
			UIBarButtonItem(customView: createProfileButton()), // Create custom view for profile button so we can control the size
			UIBarButtonItem(customView: pointsView)]
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		
		view.backgroundColor = .black
		
		setupHeader()
		
		contentContainer.backgroundColor = .dark
		view.addSubview(contentContainer)
		
		map.frame = view.bounds
		map.setRegion(MKCoordinateRegion(center: LocationManager.currentLocation(), span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)), animated: false)
		
		map.browseDelegate = self
		list.browseDelegate = self

		
		contentContainer.addSubview(currentView)
		setupNavBar()
		
		addObserver(self, forKeyPath: #keyPath(view.layer.sublayers), options: [.old, .new], context: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
		NotificationCenter.default.addMainObserver(forName: .updatedUser, owner: self, action: BrowseViewController.updatePointsLabel)
    }
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.transitionCoordinator?.animate(alongsideTransition: { [weak self](context) in
			self?.setupNavBar()
		}, completion: nil)
		//Added for re searching restaurant after 10 minutes
		if let theTimer = HoursManager.getTenMinutesTimer() {
			if Date() > theTimer {
				performSearch()
			}
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if (map.lastSearchCentre == nil) {
			performSearch()
		}
		
		showTargettedMessageOnce()
    }
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		let topBarHeight = UIApplication.shared.statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.height ?? 0.0)
		header.frame = CGRect(0, topBarHeight, view.frame.width, header.idealHeight)
		
		contentContainer.frame = CGRect(0, header.frame.maxY, view.frame.width, view.frame.height - header.frame.maxY)
		map.frame = contentContainer.bounds
		list.frame = contentContainer.bounds
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		// Keep navBarTinter at front when new views are added
		view.bringSubview(toFront: navBarTinter)
	}
	
	
	// MARK: - Private Helpers
	
	@objc func didBecomeActive() {
		//When the app is actived from background. Might need to perform searching again.
		if let theTimer = HoursManager.getTenMinutesTimer() {
			if Date() > theTimer {
				performSearch()
			}
		}
	}
	
	private func setViewMode(_ mode: BrowseViewMode) {
		var toView: UIView = list
		switch(mode) {
		case .Map:
			toView = map
		case .List:
			toView = list
		}
		
		guard (viewMode != mode) else {
			return
		}
		
		UIView.transition(from: currentView, to: toView, duration: 0.5, options: .transitionFlipFromRight, completion: nil)
		//view.bringSubview(toFront: navBarTinter)
		
		// Switch to/from List, so do fresh search
		let needsRefresh = (mode == .List || viewMode == .List)
		
		viewMode = mode
		currentView = toView
        view.setNeedsLayout()
		
		if needsRefresh {
			if let text = header.textField.text, text.count > 0 {
				performSearch(text)
			} else {
				performSearch()
			}
		}
	}
	
	private func setupNavBar() {
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
		self.navigationController?.navigationBar.shadowImage = UIImage()
		self.navigationController?.navigationBar.backgroundColor = .clear
		self.navigationController?.navigationBar.barTintColor = .gold
		self.navigationController?.navigationBar.tintColor = .gold
	}
	
	private func setupPointsView() -> UIView {
		let dividerH: CGFloat = 22
		let labelContainer = UIView(frame: CGRect(0, 0, 160, 44))
		let divider = UIView(frame: CGRect(0, floor(0.5 * (labelContainer.frame.height - dividerH)), 2, dividerH))
		divider.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
		divider.backgroundColor = .white
		labelContainer.addSubview(divider)
		
		let labelMargin: CGFloat = 15
		pointsLabel.frame = CGRect(labelMargin, 0, labelContainer.frame.width - labelMargin, 44)
		pointsLabel.textColor = .white
		pointsLabel.autoresizingMask = [.flexibleLeftMargin, .flexibleHeight]
		updatePointsLabel()
		labelContainer.addSubview(pointsLabel)
		
		return labelContainer
	}
	
	private func updatePointsLabel(_ notification: Notification? = nil) {
		let pointsText = String.localizedStringWithFormat("%d", AccountManager.main.user?.loyaltyPoints ?? 0)
		
		pointsLabel.attributedText = RDeals.addIcon(.rDealsLightR, size: 28, toText: " Points: \(pointsText)", attrs: [.font: UIFont.lightRescounts(ofSize: 15)])
	}
	
	private func setupRewardView() -> UIView {
		let rewardLabel = UILabel(frame: CGRect(0, 0, 150, 44))
		if let user = AccountManager.main.user, let earnedInfo = user.topEligibleLoyaltyTier {
			let earned = UIScreen.main.bounds.width > 350 ? " Earned" : "" // Don't show 'earned' on narrow devices
			rewardLabel.text = "\(CurrencyManager.main.getCost(cost: earnedInfo.value, currency: earnedInfo.currency))\(earned)"
		}
		rewardLabel.textColor = .gold
		rewardLabel.textAlignment = .right
		rewardLabel.font = .lightRescounts(ofSize: 15)
		return rewardLabel
	}
	
	private func setupHeader() {
		header.leftMargin = 8 + (self.navigationController?.navigationBar.layoutMargins.left ?? 8)
		header.delegate = self
		view.addSubview(header)
	}
	
	private func createProfileButton() -> UIControl {
		let kButtonSize: CGFloat = 38
		let profileButt = UIControl(frame: CGRect(0, 0, kButtonSize, kButtonSize)) // UIControl instead of UIButton so nav bar doesn't override sizing
		
		let img = UIImageView(image: UIImage(named: "IconProfile")?.withRenderingMode(.alwaysOriginal))
		img.frame = profileButt.bounds.insetBy(4)
		img.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		profileButt.addSubview(img)
		
		profileButt.addAction(for: .touchUpInside, profileTapped)
		
		// Now prevent nav bar from shrinking our entire button
		let widthConstraint = NSLayoutConstraint(item: profileButt, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: kButtonSize)
		let heightConstraint = NSLayoutConstraint(item: profileButt, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: kButtonSize)
		profileButt.addConstraints([widthConstraint, heightConstraint])
		
		return profileButt
	}
	
	private func profileTapped() {
		if (AccountManager.main.user != nil) {
			let vc = ProfileViewController()
			self.navigationController?.pushViewController(vc, animated: true)
		} else {
			AccountManager.main.showLoginUI(from: self)
		}
	}
	
	private func hideSearchPanel() {
		if let panel = self.searchPanel {
			panel.hide()
			self.searchPanel = nil
		}
	}
    func tapInfo() {
                RescountsAlert.showAlert(title: l10n("promoInfo"), text: "", icon: nil, postIconText: nil, options: nil) { (alert, buttonIndex) in
              
            }
     }
	private func showTargettedMessageOnce() {
		DispatchQueue.once(token: "ShowTargettedMessage") {
			MessageService.fetchMessages(location: LocationManager.currentLocation()) { (messages) in
				if let messages = messages {
					NotificationManager.showMessageFrom(messages)
				}
			}
		}
	}
	
	private func handleSearchResults(_ restaurantList: [Restaurant]?, loadingMore: Bool = false, includeUserLocation: Bool = true, isRDeals: Bool) {
		if var resList = restaurantList {
			
			if (loadingMore) {
                let oldRestaurants =  restaurants
				resList = resList.filter { (restaurant) -> Bool in
					return !oldRestaurants.contains(restaurant)
				}

					self.restaurants.append(contentsOf: resList)
					self.filteredRestaurants.append(contentsOf: filterRestaurants(from:resList))
			} else {
					self.restaurants = resList
					self.filteredRestaurants = resList
			}
			

				map.showRestaurants(self.filteredRestaurants, includeUserLocation: includeUserLocation)
				list.showRestaurants(resList, loadingMore: loadingMore)

			
		}
	}
	
	private func performSearch() {
		performSearch(location: map.centerCoordinate)
	}
	
	private var isRDeals: Bool {
		return (viewMode == .List)
	}
	
	private func filterRestaurants(from list: [Restaurant]) -> [Restaurant] {
		// Apply any local filtering. For now, that's just hiding restaurants with 0-item RDeals (which HAny is using for festivals to charge users $0.99)
		return list.filter({ (restaurant) -> Bool in
			return (restaurant.rDealsInfo?.numItems ?? 999) > 0
		})
	}
	
	
	// MARK: - BrowseViewDelegate
	
	func getSearchState() -> Bool {
		return searchState
	}
	
	func callForPerformSearch() {
		searchState = true
		performSearch()
	}
	
	public func selectedRestaurant(_ restaurant: Restaurant) {
		showRestaurant(restaurant)
	}
	
	public func showRestaurant(_ restaurant: Restaurant, forceRDeals: Bool? = nil) {
		
		// First check if we're going to our active restaurant, but in the wrong RDeals mode
		if forceRDeals==nil, let openTable = OrderManager.main.currentTable, openTable.restaurantID == restaurant.restaurantID, openTable.isRDeals != isRDeals {
			if isRDeals {
				// A normal reservation exists, so warn that we won't show RDeals prices
				RescountsAlert.showAlert(title: "Pricing", text: "To add any item from RDeals to your order, you should choose RDeals mode first before choosing your restaurant") { [weak self] (alert, buttonIndex) in
					self?.showRestaurant(restaurant, forceRDeals: false)
				}
			} else {
				// An RDeals reservation exists, so show RDeals prices
				showRestaurant(restaurant, forceRDeals: true)
			}
			return
		}
		
		let vc = RestaurantViewController(restaurant, isRDeals: forceRDeals ?? isRDeals)
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	func performSearch(location: CLLocationCoordinate2D?, loadingMore: Bool = false) {
		if SearchService.isSearchCallActive() /*|| !searchState*/ {
			print("Cancelled search: one already active.")
			return
		}
		map.updateSearchCentre()
		let searchLocation =
			location ??
			(loadingMore ? map.lastSearchCentre : nil) ??
			map.centerCoordinate
		let searchOffset = loadingMore ? (25 * offsetCount) : 0
        
		//add a onlyshowavailable flag
		let onlyShowAvailable  = AccountManager.main.onlyShowAvailable
		SearchService.fetchRestaurants(location: searchLocation, offset: searchOffset, includeClosed: (!onlyShowAvailable), rDeals: isRDeals) { [weak self] (restaurantList: [Restaurant]?, isRDeals: Bool) in
			self?.handleSearchResults(restaurantList, loadingMore: loadingMore, isRDeals: isRDeals)
		}
        if loadingMore {
            offsetCount += 1
        }
		
		//Added for set up an initial value for fetching restaurant after 10 minutes
		HoursManager.setTenMinutesTimer()
	}
	
	
	// MARK: - SearchPanel Delegate
	
	func performSearch(_ text: String?) {
		//Add the spinner
		if let text = text, text.count > 0 {
			FullScreenSpinner.show()
			SearchService.fetchRestaurants(location: map.centerCoordinate, searchString: text, rDeals: isRDeals) { [weak self] (restaurantList: [Restaurant]?, isRDeals: Bool) in
				if (restaurantList?.count ?? 0) == 0 {
					RescountsAlert.showAlert(title: l10n("noResultsTitle"), text: l10n("noResultsText"))
				} else {
					self?.searchState = false //Change it to search state 2 that we are using search by query
					self?.handleSearchResults(restaurantList, includeUserLocation: false, isRDeals: isRDeals)
				}
				//remove the spinner
				FullScreenSpinner.hideAll()
			}
			if let trackingDict = GAIDictionaryBuilder.createEvent(withCategory: "action", action: "performed_search", label: nil, value: nil)?.build() as? [AnyHashable : Any] {
				GAI.sharedInstance()?.defaultTracker.send(trackingDict)
			}
		}
		
		hideSearchPanel()
	}
	
	func cancelSearch() {
		performSearch()
	}
	
	func changedToView(index: Int) {
		guard index <= 2 else { return }
		setViewMode(BrowseViewMode(rawValue: index) ?? .List)
	}
}

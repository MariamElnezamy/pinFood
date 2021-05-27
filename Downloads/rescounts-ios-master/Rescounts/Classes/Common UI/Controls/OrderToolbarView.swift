//
//  OrderToolbarView.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-09-17.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class OrderToolbarView: UIControl {

	public let totalLabel = UILabel()
	public let mainLabel  = UILabel()
	public let statusView = CircularLoadingSpinner()
	public let checkView  = UIImageView(image: UIImage(named: "iconCheckmarkLarge"))
	private let checkContainer = UIView(frame: .arbitrary)
	
	private let kMargin: CGFloat = 10.0
	private let kStatusPctSize: CGFloat = 0.5
	
	private var inProcessOfShowingOrder: Bool = false
	private var inProcessOfFetchingDiscount: Bool = false
	
    private var isRdeal: Bool = false

	// MARK: - Initialization
	
	convenience init() {
		self.init(frame: .arbitrary)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		self.backgroundColor = .clear
		
		setupTotal()
		setupTitle()
		setupStatus()
		setupBehaviour()
		updateContent(nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(updateContent(_:)), name: Notification.Name.orderChanged, object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	
	// MARK: - Overrides
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let statusSize = floor(frame.height * kStatusPctSize)
		let totalWidth: CGFloat = 70
		
		totalLabel.frame = CGRect(kMargin, 0, totalWidth, frame.height)
		checkContainer.frame = CGRect(frame.width - totalWidth - kMargin, floor((frame.height - statusSize) / 2), totalWidth, statusSize)
		statusView.frame = CGRect(checkContainer.frame.width - statusSize, 0, statusSize, statusSize)
		checkView.frame  = statusView.frame
		mainLabel.frame  = CGRect(totalLabel.frame.maxX, 0, checkContainer.frame.minX - totalLabel.frame.maxX, frame.height)
	}
	
	override var isHighlighted: Bool {
		didSet {
			let color = isHighlighted ? UIColor.primary : UIColor.dark
			totalLabel.textColor = color
			mainLabel.textColor = color
		}
	}
	
	
	// MARK: - UI Helpers
	
	private func setupTotal() {
		setupLabel(totalLabel, text: "$0.00", alignment: .left)
	}
	
	private func setupTitle() {
		if(OrderManager.main.hasPendingOrder) {
			setupLabel(mainLabel, text: l10n("waitForRes"))
		} else {
			setupLabel(mainLabel, text: l10n("ViewOrder").uppercased())
		}
	}
	
	private func setupLabel(_ label: UILabel, text: String = "", alignment: NSTextAlignment = .center) {
		label.text = text
		label.font = UIFont.rescounts(ofSize: 15)
		label.textColor = .dark
		label.textAlignment = alignment
		
		addSubview(label)
	}
	
	private func setupStatus() {
		statusView.backgroundColor = .clear
		statusView.lineWidth = 1.5
		statusView.isHidden = true
		
		checkView.backgroundColor = .clear
		checkView.contentMode = .scaleAspectFit
		checkView.isHidden = true
		checkView.frame = statusView.frame
		
		checkContainer.addSubview(statusView)
		checkContainer.addSubview(checkView)
		addSubview(checkContainer)
	}
	
	private func setupBehaviour() {
		addAction(for: .touchUpInside) { [weak self] in
			//Call table/{tableID} to retrieve discount
			guard self?.inProcessOfFetchingDiscount == false, self?.inProcessOfShowingOrder == false else {
				return // User tapped button twice and we're already processing the first one
			}
			
			guard let baseNav = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController, type(of: baseNav.topViewController) != MenuOrderViewController.self else {
				return // We're already starting to show the receipt (top VC is the receipt)
			}
			
			self?.inProcessOfFetchingDiscount = true
			TableService.getDiscount(tableID: OrderManager.main.currentTable?.tableID ?? "", callback: { (error, discountNum) in
				if discountNum != nil {
					OrderManager.main.orders.discountInfo = discountNum ?? 0
				}
				NotificationCenter.default.post(name: .orderChanged, object: nil)
				
				if (!OrderManager.main.orders.hasPendingItems && !OrderManager.main.orders.hasConfirmedItems) {
					if let wc = UIApplication.shared.delegate?.window {
						var vc = wc?.rootViewController
						if(vc is UINavigationController){
							vc = (vc as! UINavigationController).visibleViewController
						}
						if (vc is RestaurantViewController) && (vc as? RestaurantViewController)?.restaurant.restaurantID == OrderManager.main.currentRestaurant?.restaurantID {
							//Current view is the correct restaurant view
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
				} else {
					if let restaurant = OrderManager.main.currentRestaurant, let rootNC = UIApplication.shared.keyWindow?.rootViewController as? BaseNavigationController, self?.inProcessOfShowingOrder == false {
						self?.inProcessOfShowingOrder = true
						let vc = MenuOrderViewController( restaurant : restaurant, userOrder: OrderManager.main.orders)
						rootNC.pushViewController(vc, animated: true) {
							self?.inProcessOfShowingOrder = false
						}
					}
				}
				self?.inProcessOfFetchingDiscount = false
			})

		}
	}
	
	@objc private func updateContent(_ notification: Any?) {
		
             var isRDeals =  false
                for order in OrderManager.main.orders.pendingItems {
                    if order.rDealsPrice != nil {
                        isRDeals = true
                       break
                    }
                }
        
        totalLabel.isHidden = (OrderManager.main.orders.getTotal(isRdeal: isRDeals) == 0 ? true : false)
		totalLabel.text = OrderManager.main.orderTotalAsString()
		
		statusView.isHidden = /*!OrderManager.main.isPolling*/ true
		checkView.isHidden = !statusView.isHidden || (OrderManager.main.currentTable == nil)
		
		mainLabel.text = OrderManager.main.hasPendingOrder ? l10n("waitForRes") :
						 OrderManager.main.orders.hasPendingItems ? l10n("submitOrder").uppercased() :
						 l10n("ViewOrder").uppercased()
	}
	
	
	// MARK: - Private Helpers
	
	private func toolbarParent() -> UIToolbar? {
		return toolbarParent(self)
	}
	
	private func toolbarParent(_ curView: UIView) -> UIToolbar? {
		if let curView = curView as? UIToolbar {
			return curView
		} else if let parent = curView.superview {
			return toolbarParent(parent)
		} else {
			return nil
		}
	}
}

//
//  BaseViewController.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-08-20.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

	internal let navBarTinter = UIView()
	internal let toolbarView = OrderToolbarView(frame: CGRect(x: 0.0, y: 0.0, width: 343.0, height: 44.0))
	
	public private(set) var isPopping: Bool = false // If you use this in a VC, you must set it to false at the end of viewWillAppear
	
	
	// MARK: - Initialization
	
	deinit {
		removeObserver(self, forKeyPath: #keyPath(view.layer.sublayers))
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
	}
	
	
	// MARK: - UIViewController Methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navBarTinter.backgroundColor = .dark
		view.addSubview(navBarTinter)
		
		self.edgesForExtendedLayout = [.top]
		
		addObserver(self, forKeyPath: #keyPath(view.layer.sublayers), options: [.old, .new], context: nil)
		
		//This is notification for restaurant reservation view from BrowseViewController. However, users can minimize from any other views so we want to be able to catch this events from other view too.
		NotificationCenter.default.addObserver(self, selector: #selector(pauseTimer(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(resumeTimer(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
		
		self.toolbarItems = orderToolbarItems()
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		navBarTinter.frame = CGRect(0, 0, view.frame.width, topLayoutGuide.length)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		isPopping = false
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		isPopping = self.navigationController?.viewControllers.contains(self) ?? false
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	@objc public func pauseTimer(_ notification: NSNotification) {
		HoursManager.pauseTimer()
	}
	
	@objc public func resumeTimer(_ notification: NSNotification){
		//If the table has been accepted already, there is no need to resume the timer
		//else resume the timer
		//Due to the re polling starts later than this call, so we first need to check the table status then check whether resume timer or not.
		
		if (!(OrderManager.main.currentTable?.approved ?? true)) { // we only need to check when the table hasn't been approved. if the table has been approved, no need to send another api call and resume timer
			TableService.getTableStatus(tableID: OrderManager.main.currentTable?.tableID ?? "") { (approved, error, response) in //If it's not approved, better check it now if it's approved already, otherwise we can find that out later on, but it's gonna be too late
				if(!(approved ?? false)) { //if the table still hasn't been approved
					HoursManager.resumeTimer()
				}
			}
		}
	}
	
	
	// MARK: Protected Methods
	
	internal func orderToolbarItems() -> [UIBarButtonItem]? {
		return [UIBarButtonItem(customView: toolbarView)]
	}
	

	// MARK: - Private Helpers
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		// Keep navBarTinter at front when new views are added
		view.bringSubview(toFront: navBarTinter)
	}
}

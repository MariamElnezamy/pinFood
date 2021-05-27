//
//  BaseNavigationController.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-06.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController, UINavigationControllerDelegate {

	// MARK: - Overrides
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupToolbar()
		
		self.delegate = self
		
        NotificationCenter.default.addObserver(self, selector: #selector(handleTableChange), name: Notification.Name.startedNewTable, object: nil)
		//NotificationCenter.default.addObserver(self, selector: #selector(handleTableChange), name: Notification.Name.approvedTable, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(handleTableChange), name: Notification.Name.endedTable, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(handleTableChange), name: Notification.Name.cancelledTable, object: nil)
    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return self.topViewController?.preferredStatusBarStyle ?? .default
	}
	
	
	// MARK: - Private Helpers
	
	private func setupToolbar() {
		self.toolbar.tintColor = .dark
		self.toolbar.barTintColor = .gold
		let tableExists = (OrderManager.main.currentTable != nil)
		self.isToolbarHidden = !tableExists
	}
	
	@objc private func handleTableChange() {
		if let vc = self.topViewController {
			refreshToolbarVisibility(vc: vc)
		}
	}
	
	
	// MARK: - UINavigationControllerDelegate
	
	public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		refreshToolbarVisibility(vc: viewController)
	}
	
	
	// MARK: - Public Methods
	
	public static func orderToolbarItems(_ toolbarView: OrderToolbarView) -> [UIBarButtonItem] {
		return [UIBarButtonItem(customView: toolbarView)]
	}
	
	public func refreshToolbarVisibility(vc: UIViewController) {
		let tableExists = (OrderManager.main.currentTable != nil)
		let isRestaurantScreen = vc.isKind(of: RestaurantViewController.self) || vc.isKind(of: RestaurantDetailsViewController.self)
        self.setToolbarHidden(!tableExists || (vc.toolbarItems?.count ?? 0) == 0 || ((OrderManager.main.hasPendingTable || !OrderManager.main.orders.hasAnyItems) && isRestaurantScreen) , animated: true)
	}
	
	// Adapted from https://stackoverflow.com/questions/9906966/completion-handler-for-uinavigationcontroller-pushviewcontrolleranimated/33767837#33767837
	public func pushViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
		pushViewController(viewController, animated: animated)
		
		guard animated, let coordinator = transitionCoordinator else {
			DispatchQueue.main.async { completion() }
			return
		}
		
		coordinator.animate(alongsideTransition: nil) { _ in completion() }
	}
	
	func popViewController(animated: Bool, completion: @escaping () -> Void) {
		popViewController(animated: animated)
		
		guard animated, let coordinator = transitionCoordinator else {
			DispatchQueue.main.async { completion() }
			return
		}
		
		coordinator.animate(alongsideTransition: nil) { _ in completion() }
	}
}

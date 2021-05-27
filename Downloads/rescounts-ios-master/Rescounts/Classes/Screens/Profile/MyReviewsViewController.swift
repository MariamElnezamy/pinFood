//
//  MyReviewsViewController.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-09-30.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class MyReviewsViewController: BaseViewController {
	
	private let tableView = ReviewTableView()
	//var reviews: [RestaurantReview] = []
	
	
	// MARK: - Initialization
	
	init() {
		super.init(nibName: nil, bundle: nil)
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	// MARK: - UIViewController Methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .white
		
		self.title = l10n("myReviews").uppercased()
		
		setupTableView()
		
		fetchReviews()
		
		self.navigationItem.rightBarButtonItem = editButtonItem
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		tableView.frame = view.bounds
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
	}

	
	// MARK: - UI Helpers
	
	private func setupTableView() {
		tableView.reviewType = .mine
		tableView.backgroundColor = .clear
		tableView.canDelete = true
		
		view.addSubview(tableView)
	}
	
	
	// MARK: Private Helpers
	
	private func fetchReviews() {
		// I had thought we would need to make an API call here, but they come down with the user at login. We might need to revisit this if we want pagination.  --- we are gonna refetch all user info. Said by Monica
		//DELETE REVIEWS FLAG
		UserService.fetchUserDetails { [weak self](user, error) in
			if error == nil {
				self?.tableView.reviews = AccountManager.main.user?.reviews ?? []
				self?.tableView.reloadData()
			} else {
				RescountsAlert.showAlert(title: l10n("oops"), text: l10n("cannotLoadReviews"))
			}
		}
		
	}
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		self.tableView.setEditing(editing, animated: animated)
	}
	
}

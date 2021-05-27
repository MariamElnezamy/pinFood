//
//  ReviewTableView.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-10-02.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class ReviewTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
	
	weak public var fetchDelegate : RestaurantReviewDelegate?
	
	public var reviewType: RestaurantReviewCell.ReviewType = .general
	
	public var reviews: [RestaurantReview] = []
	
	public var canDelete: Bool = false
	
	private var showTitle: Bool = false
	
	var isFetching = false
	var hasMore = true
	
	
	// MARK: - Initialization
	
	convenience init(showTitle shouldShowTitle: Bool = false) {
		self.init(frame: .arbitrary, style: .plain)
		self.showTitle = shouldShowTitle
	}
	
	override init(frame: CGRect, style: UITableViewStyle) {
		super.init(frame: frame, style: style)
		
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		commonInit()
	}
	
	private func commonInit() {
		self.dataSource = self
		self.delegate = self
		self.register(RestaurantReviewCell.self, forCellReuseIdentifier: "cell")
		self.register(BrowseListLoadMoreCell.self, forCellReuseIdentifier: "loadMore")
		self.separatorStyle = .none
		self.backgroundColor = .clear
		self.tableFooterView = UIView()
		//Fix for the buggy behaviour on ios 11 for inserting more table view cell
		//Reference: https://stackoverflow.com/questions/46303649/ios-11-uitableview-delete-rows-animation-bug
		self.estimatedRowHeight = 0
		self.estimatedSectionFooterHeight = 0
		self.estimatedSectionHeaderHeight = 0
		//Reference: Stop the uitable view scroll over https://stackoverflow.com/questions/34588837/uitableview-load-more-when-scrolling-to-bottom
		self.bounces = false
	}
	
	
	// MARK: - UITableViewDelegate
	
	public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return showTitle ? 44 : 0
	}
	
	public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		var retVal: UIView? = nil
		if (showTitle) {
			let container = UIView(frame: .arbitrary)
			container.backgroundColor = .white
			
			let label = UILabel(frame: CGRect(Constants.Review.paddingSide, 0, container.frame.width - 2 * Constants.Review.paddingSide, container.frame.height))
			label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			label.text = l10n("reviews").uppercased()
			label.font = UIFont.lightRescounts(ofSize:15)
			label.textColor = .dark
			
			container.addSubview(label)
			retVal = container
		}
		return retVal
	}
	
	public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row >= reviews.count {
			return 100
		} else {
			return RestaurantReviewCell.heightForReview(reviews[indexPath.row], width: frame.width, type: reviewType)
		}
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if canDelete { //This is in myreview page
			return reviews.count
		} else { //This is in general restaurant page
			return reviews.count + (hasMore ? 1 : 0)
		}
		
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let identifier = indexPath.row == reviews.count ? "loadMore" : "cell"
		let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
		
		if let cell = cell as? RestaurantReviewCell {
			cell.reviewType = reviewType
		}
		
		return cell
	}
	
	public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let cell = cell as? RestaurantReviewCell {
			cell.review = reviews[indexPath.row]
		} else {
			//cell.textLabel?.text = "Missing Review"
			//Loading more cell
			if indexPath.row == self.reviews.count {
				loadMore()
			}
			
		}
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print ("Selected row \(indexPath.row)")
	}

	
	public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return canDelete
	}

	public func tableView(_ tableView: UITableView, commit editingStyle:   UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if (editingStyle == .delete) {
			RescountsAlert.showAlert(title: l10n("removeItem"), text: l10n("removeItemMessage"), options: [l10n("no").uppercased(), l10n("yes").uppercased()]) { [weak self](alert, buttonIndex) in
				guard buttonIndex == 1 else {
					return
				}
				
				ReviewService.deleteReview(review: (self?.reviews[indexPath.row])! ) { [weak self](error) in
					if (error == nil) {
						self?.reviews.remove(at: indexPath.row)
						tableView.reloadData()
						//tableView.deleteRows(at: [indexPath], with: .automatic) //<-- it gives me exception
					} else {
						RescountsAlert.showAlert(title: l10n("deleteReviewErrorTitle"), text: "\(l10n("deleteReviewErrorText")) \(l10n("tryAgain"))")
					}
				}

			}
		}
	}
	
	public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return UITableViewCellEditingStyle.delete
	}
	
	// MARK: - Private Methods
	
	//TODO: REVIEWS
	private func loadMore() {
		if !ReviewService.shouldIMakeCall() {
			print("Cancelled search: one already active.")
			return
		}
		DispatchQueue.global(qos: .background).async {
			let searchOffset = self.reviews.count
			var theList : [RestaurantReview] = []
			ReviewService.fetchReviews(restaurant: self.fetchDelegate?.getRestaurant() , offset:searchOffset) { (restaurantReviews : [RestaurantReview]?) in
				theList = restaurantReviews ?? []
				self.fetchDelegate?.appendReviews(theList: theList)
				DispatchQueue.main.async {
					self.hasMore = (theList.count > 0)
					
					if theList.count > 0 {
						var indexPaths: [IndexPath] = []
						let startingIndex = self.reviews.count
						for i in 0..<theList.count {
							indexPaths.append(IndexPath(row: startingIndex + i, section: 0))
						}
						self.beginUpdates()
						self.reviews.append(contentsOf: theList)
						self.insertRows(at: indexPaths, with: .bottom ) // <-------- This is buggy in ios 11 BUT there is a fix on line 55
						self.endUpdates()
						//self.reloadData()
						
					} else {
						self.deleteRows(at: [IndexPath(row: self.reviews.count, section: 0)], with: .automatic)
					}
				}
			}
		}
	}
	
	// MARK: - Public Methods
	
	public func showMoreReviews(_ theList : [RestaurantReview], loadingMore: Bool = false) {
		
		hasMore = (theList.count > 0)
		
		if loadingMore {
			if theList.count > 0 {
				var indexPaths: [IndexPath] = []
				let startingIndex = self.reviews.count
				for i in 0..<theList.count {
					indexPaths.append(IndexPath(row: startingIndex + i, section: 0))
				}
				self.reviews.append(contentsOf: theList)
				self.insertRows(at: indexPaths, with: .automatic)
				
			} else {
				self.deleteRows(at: [IndexPath(row: self.reviews.count, section: 0)], with: .automatic)
			}
		} else {
			self.reviews = theList
			self.reloadData()
		}
		ReviewService.shouldICall = true
	}

}

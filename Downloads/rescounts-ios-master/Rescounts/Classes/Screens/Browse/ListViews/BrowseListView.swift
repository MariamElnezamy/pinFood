//
//  BrowseListView.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-20.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class BrowseListView: UIView, UITableViewDelegate, UITableViewDataSource {
	typealias k = Constants
	
	weak public var browseDelegate: BrowseViewDelegate?
	public var isRDeals: Bool = false {
		didSet { setupTableHeader() }
	}
	
	let noResultsLabel = UILabel()
	let rDealsInfoLabel = UILabel()
	
	let tableView = UITableView()
	var restaurants : [Restaurant] = []
	let topBarHeight : CGFloat = 64.0  //UIApplication.shared.statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.height ?? 0.0)
	var sideMargin: CGFloat = 0  // Set from parent VC since it has to match some weird navBar logic.
	let rDealsHeaderSpacer: CGFloat = 10
	
	var isFetching = false
	var hasMore = true
	
	
	// MARK: - Initialization
	
	convenience init() {
		self.init(frame: CGRect(0.0, 0.0, 100.0, 100.0))
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
		self.backgroundColor = UIColor.white
		
		tableView.register(BrowseListTableViewCell.self, forCellReuseIdentifier: "cell")
		tableView.register(BrowseListLoadMoreCell.self,  forCellReuseIdentifier: "loadMore")
		tableView.delegate = self
		tableView.dataSource = self
		tableView.separatorStyle = .none
		
		setupTableHeader()
		
		noResultsLabel.text = l10n("noResultsTitle")
		noResultsLabel.font = UIFont.rescounts(ofSize: 20)
		noResultsLabel.textColor = UIColor.gray
		noResultsLabel.textAlignment = .center
		
		//Fixed the waterfall buggy animation for inserting new loaded table view cell
		tableView.estimatedRowHeight = 0
		tableView.estimatedSectionFooterHeight = 0
		tableView.estimatedSectionHeaderHeight = 0
		//lock the scrolling view so it will stop at the last table view cell
		tableView.bounces = false

		addSubview(tableView)
		addSubview(noResultsLabel)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		tableView.frame = bounds
		noResultsLabel.frame = bounds
		
		if let header = tableView.tableHeaderView {
			let textWidth = bounds.width - 2*sideMargin
			let textHeight = ceil(rDealsInfoLabel.sizeThatFits(CGSize(textWidth, 400)).height)
			let headerRect = CGRect(0, 0, frame.width, 2*rDealsHeaderSpacer + textHeight)
			
			rDealsInfoLabel.frame = CGRect(sideMargin, rDealsHeaderSpacer, textWidth, textHeight)
			
			if !headerRect.equalTo(header.frame) {
				tableView.beginUpdates()
				header.frame = headerRect
				tableView.endUpdates()
			}
		}
	}
	
	// MARK: - Public Methods
	
	public func showRestaurants(_ newRestaurants: [Restaurant], loadingMore: Bool = false) {
		isFetching = false
		var wasShowingLoadMore = shouldShowLoadMore()
		hasMore = (newRestaurants.count > 5)
		updateRDealsText()
		
		if loadingMore {
			if (!shouldShowLoadMore() && wasShowingLoadMore && self.restaurants.count > 0) {
				// We're dropping the "load more" row
				self.tableView.beginUpdates()
				self.tableView.deleteRows(at: [IndexPath(row: self.restaurants.count, section: 0)], with: .fade)
				self.tableView.endUpdates()
				wasShowingLoadMore = false
			}
			
			if newRestaurants.count > 0 {
				var indexPaths: [IndexPath] = []
				let startingIndex = self.restaurants.count
				for i in 0..<newRestaurants.count {
					indexPaths.append(IndexPath(row: startingIndex + i, section: 0))
				}
				self.tableView.beginUpdates()
				self.restaurants.append(contentsOf: newRestaurants)
				self.tableView.insertRows(at: indexPaths, with: .bottom)  //<- This performed badly, like waterfall, but there is a fix starting from line 47
				self.tableView.endUpdates()
			} else if (!shouldShowLoadMore() && wasShowingLoadMore) {
				self.tableView.beginUpdates()
				self.tableView.deleteRows(at: [IndexPath(row:self.restaurants.count, section: 0)], with: .automatic)
				self.tableView.endUpdates()
			}
		} else {
			self.restaurants = newRestaurants
			self.tableView.reloadData()
			if newRestaurants.count > 0 {
				// scroll to the first table cell (include the header)
				tableView.contentOffset = .zero
			}
		}
	}
	
	
	// MARK: - UITableViewDelegate
	
	public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100.0
	}
	
	private func shouldShowLoadMore() -> Bool {
		return (hasMore && browseDelegate?.getSearchState() ?? true)
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if restaurants.count == 0 {
			noResultsLabel.isHidden = false
		} else {
			noResultsLabel.isHidden = true
		}
		let retVal: Int = restaurants.count + (shouldShowLoadMore() ? 1 : 0)
		return retVal
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let identifier = indexPath.row == restaurants.count ? "loadMore" : "cell"
		let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
		
		return cell
	}
	
	public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let cell = cell as? BrowseListTableViewCell {
			cell.summaryView.setRestaurant(restaurants[indexPath.row], rDealsMode: isRDeals)
		} else {
			// Load more
			if tableView.contentOffset.y > 50 { // Make sure we've actually scrolled
				loadMore()
			}
		}
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row < restaurants.count {
			let restaurant = self.restaurants[indexPath.row]
			self.browseDelegate?.selectedRestaurant(restaurant)
		}
	}
	
	
	// MARK: - Private Methods
	
	private func loadMore() {
		if (!isFetching) {
			isFetching = true

			browseDelegate?.performSearch(location: nil, loadingMore: true)
		}
	}
	
	private func setupTableHeader() {
		guard isRDeals else {
			tableView.tableHeaderView = nil
			return
		}
		
		guard nil == tableView.tableHeaderView else {
			return
		}
		
		let header = UIView(frame: .arbitrary)
		
		rDealsInfoLabel.font = .lightRescounts(ofSize: 13)
		rDealsInfoLabel.textColor = .dark
		rDealsInfoLabel.numberOfLines = 0
		updateRDealsText()
		header.addSubview(rDealsInfoLabel)
		
		let sep = UIView(frame: CGRect(0, header.frame.height - k.Profile.separatorHeight, header.frame.width, k.Profile.separatorHeight))
		sep.backgroundColor = .separators
		sep.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
		header.addSubview(sep)
		
		//tableView.tableHeaderView = header
	}
	
	private func updateRDealsText() {
        _ = CurrencyManager.main.getCost(cost: OrderManager.main.lastKnownRDealsFee, currency: "CAD")
		rDealsInfoLabel.text = ""
        rDealsInfoLabel.isHidden = true
	}
}

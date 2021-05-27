//
//  BrowseHeader.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2019-05-30.
//  Copyright © 2019 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

protocol BrowseHeaderDelegate: class {
	func performSearch(_ text: String?) // called when 'search' key pressed
	func cancelSearch()                 // called when cancel button pressed in search field
	func changedToView(index: Int)    // called when user taps on the tab bar for map/list/R-Deals
    
    func tapInfo()
}


class BrowseHeader: UIView {
	public var leftMargin: CGFloat = 0.0 {
		didSet { setNeedsLayout() }
	}
	public var hidePromo: Bool = false {
		didSet { setNeedsLayout() }
	}
	
	weak public var delegate: BrowseHeaderDelegate?
	
	private let progressBar = ProgressBar()
	private let pointsLabel = UILabel()
	public private(set) var textField = RescountsTextField()
	private let checkGroup = CheckBoxGroup()
	private let promoLabel = UILabel()
    
    private let promoInfoButton = UIButton()

	private let tabBar = TabBar()
	
	private let kBarPadding: CGFloat = 10
	private let kBottomMargin: CGFloat = 10
	
	private let kBarHeight: CGFloat = 26
	private let kTextHeight: CGFloat = 32
	private let kPromoHeight: CGFloat = 38
	private let kLabelHeight: CGFloat = 22
//	private let kTabBarHeight: CGFloat = 40
    private let kTabBarHeight: CGFloat = 0

	
	// MARK: - Initialization
	
	convenience init(leftMargin: CGFloat = 8.0) {
		self.init(frame: CGRect(0, 0, 200, 100), leftMargin: leftMargin) // Arbitrary rect for autoresizing
	}
	
	init(frame: CGRect, leftMargin lMargin: CGFloat) {
		leftMargin = lMargin
		
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		setupProgressBar()
		setupTextField()
		setupCheckBox()
		setupPromoLabel()
        
        setupPromoInfoButton()
		setupTabBar()
		
		self.backgroundColor = .dark
		
		update()
		NotificationCenter.default.addMainObserver(forName: .finishedPayment, owner: self, action: BrowseHeader.update)
		NotificationCenter.default.addMainObserver(forName: .updatedUser,     owner: self, action: BrowseHeader.update)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	
	// MARK: - UIView Methods
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		progressBar.frame = CGRect(leftMargin, 0, frame.width - 2*leftMargin, kBarHeight)
		pointsLabel.frame = progressBar.bounds
		
		let checkGroupWidth: CGFloat = 100
		let checkGroupHeight = checkGroup.idealHeight()
		checkGroup.frame = CGRect(frame.width - leftMargin - checkGroupWidth, kBarPadding + progressBar.frame.maxY + checkGroupHeight.center(in: kTextHeight), checkGroupWidth, checkGroupHeight)
		
		textField.frame = CGRect(leftMargin, kBarPadding + progressBar.frame.maxY, frame.width - 3 * leftMargin - checkGroupWidth, kTextHeight)
		
		var (promoY, promoHeight): (CGFloat, CGFloat) = (textField.frame.maxY + kBottomMargin, 0)
		if (!hidePromo && (AccountManager.main.user?.firstOrderBonus ?? true)) { // if there's no user, still show it
			promoY = textField.frame.maxY
			promoHeight = kPromoHeight
		}
		promoLabel.frame = CGRect(0, promoY, frame.width, promoHeight)
        
        promoInfoButton.frame = CGRect(150, promoY, frame.width, promoHeight)
		
		tabBar.frame = CGRect(0, promoLabel.frame.maxY, frame.width, kTabBarHeight)
	}
	
	
	// MARK: - Public Methods
	
	public var idealHeight: CGFloat {
		let eligibleForBonus = !hidePromo && (AccountManager.main.user?.firstOrderBonus ?? true)
		return kBarHeight + kBarPadding + kTextHeight + kTabBarHeight + (eligibleForBonus ? kPromoHeight : kBottomMargin)
	}
	
	
	// MARK: - UI Setup
	
	private func setupProgressBar() {
		progressBar.isUserInteractionEnabled = true
		progressBar.constantCornerRadius = 8
		
		pointsLabel.backgroundColor = .clear
		pointsLabel.textColor = .dark
		pointsLabel.font = UIFont.lightRescounts(ofSize: 15)
		pointsLabel.textAlignment = .center
		pointsLabel.isUserInteractionEnabled = false
		
		progressBar.addSubview(pointsLabel)
		addSubview(progressBar)
		
		if (AccountManager.main.user == nil) {
			update()
		}
		
		progressBar.addAction(for: .touchUpInside, showPointsInfo)
	}
	
	private func setupTextField() {
		textField.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
		textField.placeholder = l10n("search").titlecased()
		textField.textInset = 10.0
		textField.returnKeyType = .search
		textField.clearButtonMode = .whileEditing
		textField.delegate = self
		textField.showSearchIcon = true
		textField.layer.cornerRadius = 8
		textField.autocorrectionType = .no
		
		NotificationCenter.default.addMainObserver(forName: .UITextFieldTextDidChange, owner: self, action: BrowseHeader.searchFieldChanged)
		
		addSubview(textField)
	}
	
	private func setupCheckBox() {
		checkGroup.backgroundColor = UIColor.dark
		checkGroup.setOptionStrings([l10n("showAvailable")])
		checkGroup.setOn( AccountManager.main.onlyShowAvailable, index: 0)
		checkGroup.setTextColor(color: .white)
		
		checkGroup.radioButtons[0].addAction(for: .valueChanged) { [weak self] in
			var onlyShowAvailable = false
			if self?.checkGroup.radioButtons[0].on == true {
				print("I turned on the only show available")
				onlyShowAvailable = true
			} else {
				print("I turned off the only show available")
				onlyShowAvailable = false
			}
			
			AccountManager.main.onlyShowAvailable = onlyShowAvailable
			if let searchText = self?.textField.text, searchText.count > 0 {
				self?.delegate?.performSearch(searchText)
			} else {
				self?.delegate?.cancelSearch()
			}
		}
		
		addSubview(checkGroup)
	}
	
	private func setupPromoLabel() {
		promoLabel.text = l10n("winningExtra")
		promoLabel.textColor = .white
		promoLabel.font = .semiBoldRescounts(ofSize: 15)
		promoLabel.textAlignment = .center
		addSubview(promoLabel)
	}
    
    private func setupPromoInfoButton() {
        promoInfoButton.setImage(#imageLiteral(resourceName: "IconInfo"), for: .normal)
        promoInfoButton.frame.size.width = 40.0
        promoInfoButton.frame.size.height = 40.0
        promoInfoButton.addTarget(self, action:#selector(handleInfo), for: .touchUpInside)
        addSubview(promoInfoButton)
    }
    @objc func handleInfo(sender: UIButton){
        //...
        self.delegate?.tapInfo()
        
    }
	private func setupTabBar() {
		let attrs: [NSAttributedString.Key : Any] = [.font: UIFont.rescounts(ofSize: 15)]
//		tabBar.setTitles([(NSAttributedString(string: "MAP", attributes: attrs), nil),
//						  (NSAttributedString(string: "LIST", attributes: attrs), nil),
//						  (RDeals.addIcon(.rDealsDarkR, size: 28, toText: " DEALS", attrs: attrs), RDeals.addIcon(.rDealsLightR, size: 28, toText: " DEALS", attrs: attrs))])
        
                tabBar.setTitles([(NSAttributedString(string: "MAP", attributes: attrs), nil),
                                
                                  (NSAttributedString(string: "LIST", attributes: attrs), nil)])
		
		tabBar.addAction(for: .valueChanged) { [weak self] in
			if let newIndex = self?.tabBar.selectedIndex {
				self?.delegate?.changedToView(index: newIndex)
			}
		}
		
//		addSubview(tabBar)
	}
	
	
	// MARK: - Private Helpers
	
	private func update(_ notification: Notification? = nil) {
		if (AccountManager.main.user == nil) {
			pointsLabel.text = "Sign In To Start Earning Points"
		} else {
			pointsLabel.text = pointsTilNextTierText()
			progressBar.percent = currentPointsProgress()
		}
	}
	
	private func pointsTilNextTierText() -> String {
		if let user = AccountManager.main.user, let nextTier = user.nextEligibleLoyaltyTier {
			let difference =  max(nextTier.points - user.loyaltyPoints, 0)
			
			return String.localizedStringWithFormat(l10n("pointsToGoInfo"), difference, CurrencyManager.main.getCost(cost: nextTier.value, hideDecimals: true, currency: nextTier.currency))
			
		} else {
			return ""
		}
	}
	
	private func currentPointsProgress() -> CGFloat {
		let user = AccountManager.main.user
		return user?.loyaltyPointsProgress ?? 0
	}
	
	private func searchFieldChanged(_ notification: Notification? = nil) {
		textField.updateSearchIcon()
	}
	
	private func showPointsInfo() {
		if let user = AccountManager.main.user, user.loyaltyPointInfo.count > 0 {
			var infoString = ""
			for info in user.loyaltyPointInfo {
				if (infoString.count > 0) { infoString += "\n\n" }
				infoString += "\(info.points) \(l10n("winnings").uppercased()) = \(CurrencyManager.main.getCost(cost: info.value, currency: info.currency))"
			}
			
			RescountsAlert.showAlert(title: "\(l10n("yourWinnings").uppercased()) – \(l10n("howItWorks"))",
				text: "\(l10n("winningPopupText"))\n\n\(l10n("winningPopupText2") )",
				icon: nil,
				postIconText: NSAttributedString(string: infoString, attributes: [.font: UIFont.rescounts(ofSize: 15)]),
				options: [l10n("gotIt").uppercased()],
				callback: nil)
		}
	}
}


// MARK: - UITextField Delegate
extension BrowseHeader : UITextFieldDelegate {
	
	public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		delegate?.performSearch(textField.text)
		textField.resignFirstResponder()
		if let textField = textField as? RescountsTextField {
			textField.updateSearchIcon()
			textField.showCancelButton { [weak self] in
				self?.delegate?.cancelSearch()
			}
			
		}
		return true
	}
}

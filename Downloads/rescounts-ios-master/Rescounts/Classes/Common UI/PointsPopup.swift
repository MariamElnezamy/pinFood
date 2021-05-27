//
//  PointsPopup.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-08-06.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//
//	NOTE: At one point this was an overlay that slid in, now it's being used in the profile screen as an inline part of that screen's content.
//

import UIKit

class PointsPopup: UIControl {
	
	private let icon = UIImageView(image: UIImage(named: "WinningsCoinLarge"))
	private let infoLabel = UILabel()
	private let extraInfoLabel = UILabel()
	private let pointsLabel = UILabel()
	private let progressBar = ProgressBar()
	
	private let kSpacer:      CGFloat = 8
	private let kPaddingSide: CGFloat = 20
	private let kPaddingBot:  CGFloat = 13
	private let kLineHeight:  CGFloat = 20
	
	private static let kDuration: TimeInterval = 500 // TODO: reset to 5
	
	
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
		self.backgroundColor = .dark
		
		setupIcon()
		setupLabels()
		setupBar()
		setupAction()
		
		update()
		NotificationCenter.default.addObserver(self, selector: #selector(update), name: .finishedPayment, object: nil)
	}
	
	
	// MARK: - UIView Methods
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		icon.frame = CGRect(kPaddingSide, 0, kLineHeight, kLineHeight)
		infoLabel.frame = CGRect(icon.frame.maxX + kSpacer, 0, frame.width - icon.frame.maxX - kSpacer - kPaddingSide, kLineHeight)
		progressBar.frame = CGRect(kPaddingSide, icon.frame.maxY + kSpacer, frame.width - 2*kPaddingSide, kLineHeight)
		pointsLabel.frame = progressBar.bounds
		extraInfoLabel.frame = CGRect(kPaddingSide, progressBar.frame.maxY + kSpacer, frame.width - 2*kPaddingSide, kLineHeight)
	}
	
	
	// MARK: - Public Methods
	
	public func idealHeight() -> CGFloat {
		return 2*kLineHeight + kSpacer + kPaddingBot + (AccountManager.main.user?.firstOrderBonus ?? false ? kLineHeight : 0.0)
	}
	
	public func getPaddingSide() -> CGFloat {
		return kPaddingSide
	}
	
	public func hideExtraLable() {
		extraInfoLabel.isHidden = true
	}
	
	
	// MARK: - Private Helpers
	
	private func setupIcon() {
		icon.backgroundColor = .clear
		icon.contentMode = .scaleAspectFit
		addSubview(icon)
	}
	
	private func setupLabels() {
		infoLabel.backgroundColor = .clear
		infoLabel.textColor = .white
		infoLabel.font = UIFont.lightRescounts(ofSize: 16)
		addSubview(infoLabel)
		
		extraInfoLabel.backgroundColor = .clear
		extraInfoLabel.textColor = .primary
		extraInfoLabel.font = UIFont.rescounts(ofSize: 16)
		extraInfoLabel.textAlignment = .left
		if (AccountManager.main.user?.firstOrderBonus ?? false) {
			addSubview(extraInfoLabel)
		}
		
		pointsLabel.backgroundColor = .clear
		pointsLabel.textColor = .dark
		pointsLabel.font = UIFont.lightRescounts(ofSize: 13)
		pointsLabel.textAlignment = .center
		progressBar.addSubview(pointsLabel)
	}
	
	private func setupBar() {
		progressBar.isUserInteractionEnabled = false
		addSubview(progressBar)
	}
	
	@objc private func update() {
		infoLabel.attributedText = currentInfoText()
		extraInfoLabel.attributedText = currentExtraInfoText()
		pointsLabel.text = currentPointsText()
		progressBar.percent = currentPointsProgress()
	}
	
	private func setupAction() {
		// When tapped, we should a popup with the basic loyalty point tiers and their value
		
		self.addAction(for: .touchUpInside) {
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
	
	private func currentInfoText() -> NSAttributedString {
		if let user = AccountManager.main.user {
			var earnedString = ""
			if let earnedInfo = user.topEligibleLoyaltyTier {
				earnedString = CurrencyManager.main.getCost(cost: earnedInfo.value, currency: earnedInfo.currency)
			}
			let separator = (earnedString.count > 0) ? " | " : ""
			let str = "\(l10n("yourWinnings").uppercased())\(separator)\(earnedString)"
			let goldStart = str.count - earnedString.count
			let goldRange = NSMakeRange(goldStart, earnedString.count)
			
			let retVal = NSMutableAttributedString(string: str)
			retVal.setAttributes([.foregroundColor: UIColor.gold], range: goldRange)
			return retVal
			
		} else {
			return NSAttributedString()
		}
	}
	
	private func currentExtraInfoText() -> NSAttributedString {
		let str = l10n("winningExtra") //We can use this line to assign the txt as well, but I didn't. The txt looks smaller than the white txt and i guess it's because of colour. Shouldn't use dark colour here.
		let retVal = NSMutableAttributedString(string: str)
		retVal.setAttributes([.foregroundColor: UIColor.white, .font: UIFont.boldRescounts(ofSize: 16)], range: NSMakeRange(0, retVal.length))
		return retVal
	}
	
	private func currentPointsText() -> String {
		if let user = AccountManager.main.user {
			let pointsString = user.loyaltyPoints
			//let maxString = "/\(user.nextEligibleLoyaltyTier?.points.description ?? "-")"
			let difference =  max((user.nextEligibleLoyaltyTier?.points ?? 0) - user.loyaltyPoints, 0)

			return String.localizedStringWithFormat(l10n("pointsInfo"), pointsString, difference) /*"\(pointsString)\(maxString)"*/
			
		} else {
			return ""
		}
	}
	
	private func currentPointsProgress() -> CGFloat {
		let user = AccountManager.main.user
		return user?.loyaltyPointsProgress ?? 0
	}
}

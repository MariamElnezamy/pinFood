//
//  RestaurantReservationView.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-07-11.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class RestaurantReservationView: UIView {
	typealias k = Constants
	
	let separatorTop = UIView()
	let separatorBot = UIView()
	
	let detailsButton   = ReservationDetailsButton()
	let detailsCoverView = UIButton() // This button is to disable detailsButton on reservation view but still showing # of people and time
	let statusLabel 	= UILabel()
	let timerLabel      = UILabel()
	
	let cancelButton  = UIButton()
	let dineInButton  = UIButton()
	let pickupButton  = UIButton()
	
	typealias ReserveCallback = (Int) -> Void
	public var reserveCallback: ReserveCallback?
	public var cancelCallback: ReserveCallback?
	public var restaurant: Restaurant?
	
	public var numPeople: Int {
		return detailsButton.numPeople
	}
	
	public var desiredTime: Date {
		return detailsButton.desiredTime
	}
	
	let kTopMargin: CGFloat = 10
	let kDetailHeight: CGFloat = 22
	let kButtonHeight: CGFloat = 50
	let kCancelButtonSize = CGSize(200, 32)
	
	
	// MARK: - Initialization
	
	convenience init() {
		self.init(frame: .arbitrary) // Arbitrary frame
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
		self.backgroundColor = .white
		
		addSubview(detailsButton)
		addSubview(detailsCoverView)
		
		setupSeparators()
		setupButtons()
		setupStatus()
		
		setupTimerLabel()
	}
	
	
	// MARK: - UIView Overrides
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		separatorTop.frame = CGRect(0, 0, frame.width, k.Menu.separatorHeight)
		separatorBot.frame = CGRect(0, frame.height - k.Menu.separatorHeight, frame.width, k.Menu.separatorHeight)
		
		let detailsWidth = detailsButton.idealWidth(forHeight: kDetailHeight)
		let detailsX = floor((frame.width - detailsWidth) / 2)
		var lastY = separatorTop.frame.maxY
		
		// Details
		if !detailsButton.isHidden {
			detailsButton.frame = CGRect(detailsX, lastY + kTopMargin, detailsWidth, kDetailHeight)
			detailsCoverView.frame = detailsButton.frame
			lastY = detailsButton.frame.maxY
		}
		
		// Reserve buttons
		if !dineInButton.isHidden {
			let buttWidth = floor(detailsWidth / 2) - 10
			dineInButton.frame = CGRect(detailsX, lastY + 2*kTopMargin, buttWidth, kButtonHeight)
			pickupButton.frame = CGRect(dineInButton.frame.maxX + 20, dineInButton.frame.minY, buttWidth, kButtonHeight)
			lastY = dineInButton.frame.maxY
		}
		
		// Status label
		if !statusLabel.isHidden {
			statusLabel.frame = CGRect(detailsX, lastY + kTopMargin , detailsWidth, statusLabel.sizeThatFits(CGSize(detailsWidth, 100)).height)
			lastY = statusLabel.frame.maxY
		}
		
		// Timer
		if !timerLabel.isHidden {
			timerLabel.frame = CGRect(detailsX, lastY + kTopMargin, frame.width - 2*detailsX, kDetailHeight)
			lastY = timerLabel.frame.maxY
		}
		
		// Cancel button
		if !cancelButton.isHidden {
			let cancelX = floor((frame.width - kCancelButtonSize.width) / 2)
			cancelButton.frame = CGRect(cancelX, lastY + kTopMargin, kCancelButtonSize.width, kCancelButtonSize.height)
		}
	}
	
	
	// MARK: Observers
	
	override func didMoveToWindow() {
		
		if self.window != nil {
			NotificationCenter.default.addObserver(self, selector: #selector(updateTimerText(_:)), name: .updateTimer , object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(updateCancelTimerText(_:)), name: .updateCancelTimer , object: nil)
		}
	}
	
	override func willMove(toWindow newWindow: UIWindow?) {
		
		if newWindow == nil {
			NotificationCenter.default.removeObserver(self, name: .updateTimer, object: nil)
			NotificationCenter.default.removeObserver(self, name: .updateCancelTimer, object: nil)
		}
	}
	
	// MARK: - Public Methods
	
	
	@objc public func updateTimerText(_ notification: NSNotification) {
		//Reference :https://stackoverflow.com/questions/26993584/timer-label-not-updated-after-switching-views-swift?rq=1
		//Other timer related funcs has been moved to BaseViewController
		timerLabel.text = HoursManager.getTimerString()
	}
	
	@objc public func updateCancelTimerText(_ notification: NSNotification) {
		timerLabel.text = HoursManager.getAutoCancelTimerString()
	}
	
	public func idealHeight() -> CGFloat {
		let detailsWidth = detailsButton.idealWidth(forHeight: kDetailHeight)
		
		var retVal = 2*k.Menu.separatorHeight + kTopMargin // Top and bottom separators, plus bottom margin
		if !detailsButton.isHidden { retVal += kDetailHeight + kTopMargin }
		if !dineInButton.isHidden  { retVal += kButtonHeight + 3*kTopMargin } // the dineInButton has an extra margin on top and bottom
		if !timerLabel.isHidden    { retVal += kDetailHeight + kTopMargin }
		if !cancelButton.isHidden  { retVal += kCancelButtonSize.height + kTopMargin }
		if !statusLabel.isHidden {
			let statusHeight = statusLabel.sizeThatFits(CGSize(detailsWidth, 100)).height
			retVal += statusHeight + kTopMargin
		}
		
		return retVal
	}
	
	public func desiredTimeString() -> String {
		return detailsButton.desiredTimeString()
	}
	
	
	public func showCheckmark() {
		HoursManager.timer.invalidate()
		updateUI()
	}
	
	
	public func showSpinner() {
		if (HoursManager.shouldShowTimer) {
			HoursManager.startTimer()
		}
		updateUI()
	}
	
	public func showButton() {
		hideTimer()
		if ((OrderManager.main.currentRestaurant == nil) || (OrderManager.main.currentRestaurant?.name == self.restaurant?.name )) {
			HoursManager.resetTimer()
		}
		updateUI()
	}
	
	public func updateUI() {
		// There are 4 states here:
		//	1) No reservation -- just show "Dine In" and "Pick Up"
		//	2) Waiting on reservation request -- just reservation details, status line ("waiting"), 5 minute timer, and cancel
		//	3) Reservation confirmed but no order -- show details, 15 minute timer, and cancel button
		//	4) Reservation confirmed and order submitted -- show details
		
		let table = OrderManager.main.currentTable
		let isCurrent = table?.restaurantID == restaurant?.restaurantID
		let isApproved = isCurrent && (table?.approved ?? false)
		let canReserve = (table == nil)
		
		detailsButton.isHidden = canReserve || !isCurrent
		statusLabel.text = (isApproved ? l10n("tableIsReady") : l10n("tableOnRequest")).uppercased()
		statusLabel.isHidden = !isCurrent || (table?.pickup ?? false)
		dineInButton.isHidden = !canReserve
		pickupButton.isHidden = !canReserve
		timerLabel.isHidden = /*!isCurrent || isApproved ||*/ !HoursManager.shouldShowTimer
		cancelButton.isHidden = !(OrderManager.main.canCancelTable) && (!(OrderManager.main.canCancelPickUp))
		
		setNeedsLayout()
	}
	
	public func updateData(numPeople: Int, desiredTime: Date) {
		detailsButton.updateData(numPeople: numPeople, desiredTime: desiredTime)
	}
	
	public func showTimer() {
		HoursManager.shouldShowTimer = true
		updateUI()
	}
	
	public func hideTimer() {
		HoursManager.shouldShowTimer = false
		updateUI()
	}
	
	
	// MARK: - Private Methods
	
	private func setupSeparators() {
		self.separatorTop.backgroundColor = .separators
		self.separatorBot.backgroundColor = .separators
		
		addSubview(self.separatorTop)
		addSubview(self.separatorBot)
	}
	
	private func setupButtons() {
		detailsButton.hideArrow()
		
		dineInButton.setTitle(l10n("dineIn").uppercased(), for: .normal)
		dineInButton.setTitleColor(.dark, for: .normal)
		dineInButton.setBackgroundImage(UIImage(color: .gold), for: .normal)
		dineInButton.layer.cornerRadius = floor (kDetailHeight / 2)
		dineInButton.layer.masksToBounds = true
		dineInButton.titleLabel?.font = UIFont.rescounts(ofSize: 15)
		dineInButton.addAction(for: .touchUpInside) { [weak self] in
			self?.tappedReserve(2)
		}
		
		pickupButton.setTitle(l10n("pickup").uppercased(), for: .normal)
		pickupButton.setTitleColor(.dark, for: .normal)
		pickupButton.setBackgroundImage(UIImage(color: .gold), for: .normal)
		pickupButton.layer.cornerRadius = floor (kDetailHeight / 2)
		pickupButton.layer.masksToBounds = true
		pickupButton.titleLabel?.font = UIFont.rescounts(ofSize: 15)
		pickupButton.addAction(for: .touchUpInside) { [weak self] in
			self?.tappedReserve(0)
		}
		
		detailsCoverView.addAction(for: .touchUpInside) { [weak self] in
			if (!(self?.dineInButton.isHidden ?? false)) {
				self?.tappedReserve(2)
				HoursManager.shouldShowTimer = true
				self?.updateUI()
			}
		}
		
		cancelButton.setTitle(l10n("cancelRes").titlecased(), for: .normal)
		cancelButton.setTitleColor(.primary, for: .normal)
		cancelButton.titleLabel?.font = UIFont.rescounts(ofSize: 15)
		cancelButton.layer.borderColor = UIColor.primary.cgColor
		cancelButton.layer.borderWidth = 2
		cancelButton.layer.cornerRadius = kCancelButtonSize.height / 2
		cancelButton.isHidden = true
		cancelButton.addAction(for: .touchUpInside) { [weak self] in
			self?.tappedCancel()
		}
		
		addSubview(dineInButton)
		addSubview(pickupButton)
		addSubview(cancelButton)
	}
	
	private func setupStatus() {
		setupLabel(statusLabel, fontSize: 13)
		statusLabel.numberOfLines = 2
		statusLabel.isHidden = true
		statusLabel.textAlignment = .center
	}
	
	private func setupLabel(_ label: UILabel, fontSize: CGFloat = 15) {
		label.font = UIFont.lightRescounts(ofSize: 15)
		label.textColor = .dark
		label.backgroundColor = .clear
		label.adjustsFontSizeToFitWidth = true
		addSubview(label)
	}
	
	private func setupTimerLabel(){
		timerLabel.font = UIFont.lightRescounts(ofSize: 15)
		timerLabel.textColor = .primary
		timerLabel.backgroundColor = .clear
		timerLabel.textAlignment = .center
		addSubview(timerLabel)
	}
	
	
	// MARK: - Actions
	
	private func tappedReserve(_ numPeople: Int) {
		reserveCallback?(numPeople)
	}
	
	private func tappedCancel() {
		cancelCallback?(0)
	}
}

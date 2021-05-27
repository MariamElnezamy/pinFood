//
//  ConfirmReservationViewController.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-08-20.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import MapKit


class ConfirmReservationViewController: BaseViewController {
	
	private let containerView = UIView() // A container for all other views so it can slide up with the keyboard
	
	private let mapView = BrowseMapView()
	private let detailsBG = UIView()
	public  let detailsButton = ReservationDetailsButton()
	private let reserveButt = RescountsButton()
	private let joinButt = RescountsButton()
	
	private let headerView : ConfirmReservationHeaderView
	
	private let middleView  : ConfirmReservationAddressView
	
	private let specialRequest : ConfirmReservationSpecialRequestView
	
	private let restaurant: Restaurant
	
	private var initialHeight = CGFloat()
	
	private let mapViewHeight : CGFloat = 200
	
	private let buttonHeight : CGFloat = 50
	private let buttonSpacer : CGFloat = 30
	private let buttonBottomMargin : CGFloat = 70
	private let kDetailHeight: CGFloat = 22
	private let kDetailSpacer: CGFloat = 10
	
	private var isRDeals: Bool = false
	private var pickupMode: Bool = false
	
	
	// MARK: - Initialization
	
	init(restaurant: Restaurant, numPeople: Int, desiredTime: Date, rDeals: Bool) {
		self.restaurant = restaurant
		headerView = ConfirmReservationHeaderView(frame: .arbitrary, restaurant: self.restaurant, numPeople : numPeople, desiredTime : desiredTime )
		middleView = ConfirmReservationAddressView(frame: .arbitrary, restaurant : restaurant)
		specialRequest = ConfirmReservationSpecialRequestView(frame: .arbitrary)
		isRDeals = rDeals
		super.init(nibName: nil, bundle: nil)
		
		commonInit(numPeople: numPeople, desiredTime: desiredTime)
	}
	
	required init?(coder aDecoder: NSCoder) {
		return nil
	}
	
	private func commonInit(numPeople: Int? = nil, desiredTime: Date? = nil) {
		
		self.title = l10n("claimTable").uppercased()
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "iconCancel"), style: .plain, target: self, action: #selector(tappedCancel(_:)))
		if let num=numPeople {
			pickupMode = (numPeople == 0)
			detailsButton.usePinkArrow()
			detailsButton.updateData(numPeople: num)
			
			detailsBG.backgroundColor = .gold
			let fakeButton = UIView()
			fakeButton.backgroundColor = .white
			fakeButton.layer.cornerRadius = 8
			detailsBG.addSubview(fakeButton)
		}
	}
	
	
	// MARK: - UIViewController Methods
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = .white
		
		containerView.frame = view.bounds
		containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		view.addSubview(containerView)
		
		mapView.backgroundColor = .lightGray
		mapView.isUserInteractionEnabled = false
		containerView.addSubview(mapView)
		
		containerView.addSubview(headerView)
		containerView.addSubview(middleView)
		containerView.addSubview(detailsBG)
		containerView.addSubview(detailsButton)
		containerView.addSubview(specialRequest)
		
		let reserveText = pickupMode ? "Confirm time " : l10n("reserveTable")
		setupButton(reserveButt, title: reserveText, displayType: .primary,   action: makeReservation)
		setupButton(joinButt,    title: l10n("joinGroup"),    displayType: .secondary, action: joinTableTapped)
    }
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		initialHeight = self.navigationController?.navigationBar.frame.maxY ?? 0
		
		headerView.frame = CGRect(0, initialHeight, view.frame.width, headerView.getIdealHeight())
		
		mapView.frame = CGRect(0,headerView.frame.maxY, view.frame.width, floor(view.frame.height * 0.35))
		
		middleView.frame = CGRect(0, mapView.frame.maxY, view.frame.width, middleView.getIdealHeight())
		
		let detailsWidth = detailsButton.idealWidth(forHeight: kDetailHeight)
		let detailsFakeBGWidth = detailsWidth + 20
		detailsBG.frame = CGRect(0, middleView.frame.maxY, view.frame.width, 2*kDetailSpacer + kDetailHeight)
		detailsBG.subviews.first?.frame = CGRect(floor((view.frame.width - detailsFakeBGWidth)/2), 2, detailsFakeBGWidth, detailsBG.frame.height - 2*2)
		detailsButton.frame = CGRect(floor((view.frame.width - detailsWidth)/2), middleView.frame.maxY + kDetailSpacer, detailsWidth, kDetailHeight)
		
		specialRequest.frame = CGRect(0, detailsButton.frame.maxY + kDetailSpacer, view.frame.width, specialRequest.getIdealHeight())
		
		if pickupMode {
			let buttWidth = view.frame.width - 2*buttonSpacer
			reserveButt.frame = CGRect(buttonSpacer, view.frame.height - buttonBottomMargin, buttWidth, buttonHeight)
			joinButt.frame = .zero
		} else {
			let buttWidth = max(125, floor((view.frame.width - 3*buttonSpacer) / 2)) // Making it at least 125 px for the iPhone 5 where text was cut off
			reserveButt.frame = CGRect(buttonSpacer, view.frame.height - buttonBottomMargin, buttWidth, buttonHeight)
			joinButt.frame = reserveButt.frame.offsetBy(dx: buttWidth + buttonSpacer)
		}
		
		mapView.showRestaurants([self.restaurant], viewMode: .restaurantAndUser)
	}
	
	
	// MARK: - Public Methods
	
	
	// MARK: - Private Helpers
	
	private func setupButton(_ butt: RescountsButton, title: String, displayType: RescountsButton.DisplayType, action: @escaping ()->()) {
		butt.setTitle(title.uppercased(), for: .normal)
		butt.titleLabel?.font = .rescounts(ofSize: 13)
		butt.titleLabel?.adjustsFontSizeToFitWidth = true
		butt.titleLabel?.minimumScaleFactor = 0.9
		butt.displayType = displayType
		butt.addAction(for: .touchUpInside, action)
		
		containerView.addSubview(butt)
	}
	
	private func doReservationAction() {
		NotificationCenter.default.post(name: .makingReservation, object: self)
		
		FullScreenSpinner.show()
		let numPeople = detailsButton.numPeople
		ReservationService.claimTable(restaurant: restaurant, numPeople: numPeople, isRDeals: isRDeals, reservationTime: detailsButton.desiredTime, special:specialRequest.getText(), callback: { [weak self] (table: RestaurantTable?, error: ReservationService.ReservationError) in
			FullScreenSpinner.hideAll()
			
			if table != nil {
				
				if numPeople == 0 {
					// Pickup, just go back where we came from (restaurant or menu options page)                    
                    self?.navigationController?.popToViewController(ofClass: RestaurantViewController.self)
					
				} else {
					// For dine in, we definitely want to go back to the Restaurant page to see the timer
					var restaurantVC: RestaurantViewController? = nil
					self?.navigationController?.viewControllers.forEach({ (vc) in
						if let vc = vc as? RestaurantViewController, vc.restaurant.restaurantID == OrderManager.main.currentRestaurant?.restaurantID {
							restaurantVC = vc
							return
						}
					})
					
					if let restaurantVC = restaurantVC {
						restaurantVC.needToScrollMenu = true
						self?.navigationController?.popToViewController(restaurantVC, animated: true)
					} else {
						self?.navigationController?.popViewController(animated: true)
					}
				}
				
			} else {
				if error == .noToken {
					RescountsAlert.showAlert(title: l10n("reservationErrorNoPayTitle"), text: l10n("reservationErrorNoPayText"), callback: nil)
				} else if error == .notActivated {
					self?.showNotActivatedError()
				} else {
					RescountsAlert.showAlert(title: l10n("error"), text: l10n("resLost"), callback: nil)
				}
			}
		})

		if let trackingDict = GAIDictionaryBuilder.createEvent(withCategory: "action", action: "reserved_table", label: nil, value: nil)?.build() as? [AnyHashable : Any] {
			GAI.sharedInstance()?.defaultTracker.send(trackingDict)
		}
	}
	
	private func makeReservation() {
		let peopleTxt = String.localizedStringWithFormat(self.detailsButton.numPeople == 1 ? l10n("numPeople.one") : l10n("numPeople.other"), self.detailsButton.numPeople)
		RescountsAlert.showAlert(title: "\(l10n("confirmPop")) \(self.restaurant.name)", text: "\(self.detailsButton.numPeople == 0 ? l10n("pickup") : peopleTxt ) - \(HoursManager.hoursStringFromDate(self.detailsButton.desiredTime))", icon: nil, postIconText: nil, options: [l10n("no").uppercased(), l10n("yes").uppercased()]) { [weak self] (alert, buttonIndex) in
			if buttonIndex == 1 {
				self?.doReservationAction()
			}
		}
	}
	
	private func joinTableTapped() {
		RescountsAlert.showAlert(title: "Join A Table", text: "To join another table, please enter its code found on the top right of the receipt of the main reservation.", options: ["CANCEL", "JOIN"], numTextFields: 4) { [weak self] (alert, buttonIndex) in
			print ("Tapped: \(buttonIndex). Code: \(alert.textValue)")
			
			if (buttonIndex == 1) {
				self?.joinTable(alert.textValue)
			}
		}
	}
	
	private func joinTable(_ code: String) {
		ReservationService.joinTable(restaurant: restaurant, code: code, isRDeals: isRDeals) { [weak self] (table, error) in
			FullScreenSpinner.hideAll()
			
			if table != nil {
				self?.navigationController?.popViewController(animated: true)
			} else {
				if error == ReservationService.ReservationError.noToken {
					RescountsAlert.showAlert(title: l10n("reservationErrorNoPayTitle"), text: l10n("reservationErrorNoPayText"), callback: nil)
				} else if error == ReservationService.ReservationError.noTable {
						RescountsAlert.showAlert(title: l10n("reservationErrorWrongCodeTitle"), text: l10n("reservationErrorWrongCodeText"), callback: nil)
				} else if error == .notActivated {
					self?.showNotActivatedError()
				} else {
					RescountsAlert.showAlert(title: l10n("error"), text: l10n("resLost"), callback: nil)
				}
			}
		}
	}
	
	@objc private func tappedCancel(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	
	private func showNotActivatedError() {
		RescountsAlert.showAlert(title: l10n("accountNotActivatedTitle"), text: l10n("accountNotActivated"), options: ["Resend", l10n("ok")]) { (alert, buttonIndex) in
			if buttonIndex == 0 {
				UserService.resendWelcomeEmail(callback: { (error) in
					if let error = error {
						RescountsAlert.showAlert(title: "Error", text: error.localizedDescription)
					}
				})
			}
		}
	}
}

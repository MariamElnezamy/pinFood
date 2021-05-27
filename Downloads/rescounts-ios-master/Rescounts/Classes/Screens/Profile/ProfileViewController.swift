//
//  ProfileViewController.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-07-05.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import Stripe
import MessageUI
import StoreKit
import Crashlytics

enum ProfileCellIdentifier: String {
	case ProfileCell = "profileCell"
	case RewardCell = "rewardCell"
}

protocol ProfileViewControllerDelegate: NSObjectProtocol {
	func removeEnterReferralCode()
    func profileRewardFirstItemTapped()
    func profileRewardSecondItemTapped()
}


class ProfileViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, STPPaymentContextDelegate, MFMailComposeViewControllerDelegate, ProfileViewControllerDelegate {
	typealias k = Constants.Profile
	
	let stripePublishableKey = Constants.Stripe.stripePublishableKey
	let backendBaseURL: String? = Constants.Stripe.backendBaseURL
	let appleMerchantID: String? = Constants.Stripe.appleMerchantID
	let paymentContext: STPPaymentContext

	private let isServer = AccountManager.main.user?.isServer ?? false
	
	private let headerView = UIView()
	
	private let profileContainer = UIControl()
	private let profilePhoto = RemoteImageView()
	private let profileName  = UILabel()
	private let profileEmail = UILabel()
	private let profileCode  = UILabel()
	private let profileRTY   = UILabel()
	
	private let loyaltyContainer = UIView()
	private let loyaltyPoints = PointsPopup()
	
	private let tableView = UITableView()
	private let dataAttendant: [ProfileRewardItem] = [
		ProfileRewardItem(id: l10n("customerWinnings"), iconName: "WinningsCoinLarge", amount: AccountManager.main.user?.allTimeLoyaltyPointsCustomer ?? 0),
		ProfileRewardItem(id: l10n("serverWinnings"),   iconName: "IconServiceLarge",  amount: AccountManager.main.user?.allTimeLoyaltyPointsWaiter   ?? 0)]
	
	private let referralCodeRow = ProfileItem(title: l10n("enterReferralCode"), iconName: "IconReferralCode", action: "tappedEnterCode:")
	
	private var data: [Any] = [
		ProfileItem(title: l10n("payment"),             iconName: "IconPayment",       action: "tappedPayment:"),
		ProfileItem(title: l10n("myReview"),            iconName: "IconReviews",       action: "tappedMyReviews:"),
		ProfileItem(title: l10n("referFriend"),         iconName: "IconRefer",         action: "tappedRefer:"),
		//ProfileItem(title: l10n("enableNotifications"), iconName: "IconNotifications", action: "tappedNotifications:", identifier: k.notificationRowID),
		ProfileItem(title: l10n("perks"),               iconName: "IconNotifications", action: "tappedEarnPoints:"),
		ProfileItem(title: l10n("faq"),                 iconName: "IconFaq",           action: "tappedFAQ:"),
		ProfileItem(title: l10n("sendFeedback"),        iconName: "IconFeedback",      action: "tappedFeedback:"),
		ProfileItem(title: l10n("callSupport"),         iconName: "IconCall",          action: "tappedCallSupport:"),
		ProfileItem(title: l10n("rateApp"),             iconName: "IconRate",          action: "tappedRate:"),
//		ProfileItem(title: l10n("viewVideo"),			iconName: "IconVideo",		   action: "tappedVideo:"),
		ProfileItem(title: l10n("logout"),              iconName: "IconSignout",       action: "tappedLogout:")]
	
	private let kHeaderProfileHeight: CGFloat = 120
	private let kHeaderPointsHeight:  CGFloat = 65
	private let kProfileEmailHeight:  CGFloat = 20.0
	private let kProfileNameHeight:   CGFloat = 20.0
	private let kLoyaltyTopPadding:   CGFloat = 10.0
	
	
	// MARK: - Initialization
	
	init() {
		let customerContext = STPCustomerContext(keyProvider: StripeAPIClient.sharedClient)
		let paymentContext = STPPaymentContext(customerContext: customerContext,
											   configuration: STPPaymentConfiguration.shared(),
											   theme: STPTheme.default())
		self.paymentContext = paymentContext

		super.init(nibName: nil, bundle: nil)
		self.paymentContext.delegate = self
		paymentContext.hostViewController = self
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	// MARK: - UIViewController Methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = l10n("profile").uppercased()

		setupHeader()
		setupProfileContainer()
		setupLoyaltyContainer()
		setupProfile()
		setupTableView()
		
		if let trackingDict = GAIDictionaryBuilder.createEvent(withCategory: "page_view", action: "my_profile", label: nil, value: nil)?.build() as? [AnyHashable : Any] {
			GAI.sharedInstance()?.defaultTracker.send(trackingDict)
		}

        NotificationCenter.default.addObserver(self, selector: #selector(setupProfile), name: .updatedUser, object: nil)
    }
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		let kLeftMargin = loyaltyPoints.getPaddingSide()
		
		headerView.frame = CGRect(0, topLayoutGuide.length, view.frame.width, kHeaderProfileHeight + kHeaderPointsHeight)
		
		profileContainer.frame = CGRect(0, k.separatorHeight, view.frame.width, kHeaderProfileHeight - k.separatorHeight)
		profilePhoto.frame = CGRect(kLeftMargin, k.profilePhotoPaddingTop, k.imageHeight, k.imageHeight)
		var wordsHeight = kProfileNameHeight + kProfileEmailHeight * 2
		if (AccountManager.main.user?.rtyRes?.count ?? 0 > 0) {
			wordsHeight += kProfileEmailHeight
		}
		let kMarginOnTop = ( profilePhoto.frame.height - wordsHeight ) / 2.0
		profileName.frame = CGRect(kLeftMargin + profilePhoto.frame.maxX, profilePhoto.frame.minY + kMarginOnTop, profileContainer.frame.width, kProfileNameHeight)
		profileEmail.frame = CGRect(kLeftMargin + profilePhoto.frame.maxX, profileName.frame.maxY, profileContainer.frame.width, kProfileEmailHeight)
		profileCode.frame = CGRect(kLeftMargin + profilePhoto.frame.maxX, profileEmail.frame.maxY, profileContainer.frame.width, kProfileEmailHeight)
		profileRTY.frame = CGRect(kLeftMargin + profilePhoto.frame.maxX, profileCode.frame.maxY, profileContainer.frame.width, kProfileEmailHeight)
		
		loyaltyContainer.frame = CGRect(0, profileContainer.frame.origin.y + profileContainer.frame.size.height, view.frame.width, kHeaderPointsHeight)
		loyaltyPoints.frame = CGRect(0, 0, view.frame.width, kHeaderPointsHeight)
		
		tableView.frame = CGRect(0, headerView.frame.maxY, view.frame.width, view.frame.height - headerView.frame.maxY)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.navigationController?.navigationBar.backgroundColor = .dark
		self.navigationController?.navigationBar.barTintColor = .white
		self.navigationController?.navigationBar.tintColor = .white
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	
	// MARK: TableViewCell Actions
	
	@objc private func tappedMyReviews(_ data: ProfileItem) {
		let vc = MyReviewsViewController()
		navigationController?.pushViewController(vc, animated: true)
	}
	
	@objc private func tappedRefer(_ data: ProfileItem) {
		RescountsAlert.showAlert(title: l10n("referPopTitle"),
								 text: l10n("referPopText"),
								 postIconText:NSAttributedString(string: "\(l10n("referralCode")): \(AccountManager.main.user?.sharingCode ?? "")", attributes: [.font: UIFont.rescounts(ofSize: 15)]),
								 options: [l10n("no"), l10n("share")])
		{ [weak self] (alert, buttonIndex) in
			guard buttonIndex == 1 else { return }
			
			let items: [Any] = [String.localizedStringWithFormat(l10n("shareMess"), "\(AccountManager.main.user?.sharingCode ?? "''")"), URL(string: "https://onelink.to/ynqm4g")!]
			let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
			vc.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
				if !completed {
					return
				}

				if let trackingDict = GAIDictionaryBuilder.createEvent(withCategory: "action", action: "referred_friend", label: nil, value: nil)?.build() as? [AnyHashable : Any] {
					GAI.sharedInstance()?.defaultTracker.send(trackingDict)
				}
			}
			vc.excludedActivityTypes = [.print, .copyToPasteboard, .assignToContact, .saveToCameraRoll, .addToReadingList, .openInIBooks]
			self?.present(vc, animated: true)
		}
		
		// TODO: Referrals
		//	- each user gets a unique code in their profile
		//	- the other user has to enter this in in settings (we need a row for this)
		//	- once they've entered a friend's ID, the original friend gets some bonus, and the other user can never enter a code again
	}
	
	@objc private func tappedEnterCode(_ data: ProfileItem) {
		let vc = EnterReferralViewController()
		vc.delegate  = self
		navigationController?.pushViewController(vc, animated: true)
	}
	
	@objc private func tappedNotifications(_ data: ProfileItem) {
		FullScreenSpinner.show()
		NotificationManager.notificationsEnabled { [weak self] (globallyEnabled, locallyEnabled) in
			FullScreenSpinner.hideAll()
			let defaults = UserDefaults.standard
			
			if (!globallyEnabled) {
				RescountsAlert.showAlert(title: l10n("iosSet"), text: l10n("iosNotification"), options:[l10n("no"), l10n("showMe")]) { (alert, buttonIndex) in
					if (buttonIndex == 1) {
						UIApplication.shared.open(URL.init(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
					}
				}
			} else {
				defaults.set(!defaults.bool(forKey: Constants.UserDefaults.disabledNotifications), forKey: Constants.UserDefaults.disabledNotifications)
				self?.updateNotificationRow()
			}
		}
	}
	
	@objc private func tappedEarnPoints(_ data: Any) {
		let title = l10n("earnPoints")
		let body = NSMutableAttributedString(string: "")
		
		body.append(textPainter(text: l10n("earn_1")))
		body.append(textPainter(text: l10n("earn_2")))
		body.append(textPainter(text: l10n("earn_3")))
		body.append(textPainter(text: l10n("earn_4")))
		body.append(textPainter(text: l10n("earn_5")))
		body.append(textPainter(text: l10n("earn_6")))
		body.append(textPainter(text: l10n("earn_7")))
		
		let leftAlignStyle = NSMutableParagraphStyle()
		leftAlignStyle.alignment = .left
        leftAlignStyle.headIndent = 13.0
		body.addAttribute(.paragraphStyle, value: leftAlignStyle, range: NSRange(location: 0, length: body.string.count))

		RescountsAlert.showAlert(title: title, text: "", icon: nil, postIconText: body, options: nil, callback: nil )
		
	}
    
    @objc private func tappedServer(data: Any) {
        RescountsAlert.showAlert(title: "", text: l10n("serverWinningsInfo"))
    }
	
	func tappedCustomer() {
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
	
	func textPainter(text : String) -> NSAttributedString {
		let theText = NSMutableAttributedString(string: text, attributes: [.font: UIFont.lightRescounts(ofSize: 14.5)])
		let thePos = text.firstIndex(of: ":")
		let pos = text.distance(from: text.startIndex, to: thePos ?? text.startIndex) + 1
		theText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.highlightRed, range: NSMakeRange(pos, text.count - pos))
		return theText
		
	}
	
	@objc private func tappedFAQ(_ data: ProfileItem) {
		if let url = URL(string: "https://www.rescounts.com/faq.php") {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
	}
	
	@objc private func tappedPayment(_ data: ProfileItem) {
		let vc = PaymentMethodsViewController()
		vc.displayState = PaymentMethodsViewController.DisplayState.profile
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	@objc private func tappedFeedback(_ data: ProfileItem) {
		if !MFMailComposeViewController.canSendMail() {
			RescountsAlert.showAlert(title: l10n("noEmailTitle"), text: l10n("noEmailText"))
			return
		}
		
		let composeVC = MFMailComposeViewController()
		composeVC.mailComposeDelegate = self
		
		composeVC.setToRecipients(["foodie@rescounts.com"]) // TODO: get actual email from Hany
		composeVC.setSubject("iOS App Feedback - v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "")")
		
		// Present the view controller modally.
		self.present(composeVC, animated: true, completion: nil)
		
	}
	
	@objc private func tappedCallSupport(_ date: ProfileItem) {
		Helper.callSupport(orShowPopup:true)
	}
	
	@objc private func tappedRate(_ data: ProfileItem) {
		if let appURL = URL(string: Constants.App.rateURLString) {
			UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
		}
	}
	
	@objc private func tappedVideo(_ date: ProfileItem) {
		let vc = TutorialVideoViewController(to: self)
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	@objc private func tappedLogout(_ data: ProfileItem) {
		UserService.logout()
	}
	
	
	// MARK: - UI Helpers
	
	private func setupHeader() {
		headerView.backgroundColor = .white
		view.addSubview(headerView)
	}
	
	private func setupProfileContainer() {
		profileContainer.backgroundColor = .dark
		profileContainer.addAction(for: .touchUpInside) {
			self.tappedProfilePhoto()
		}
		headerView.addSubview(profileContainer)
	}
	
	private func setupLoyaltyContainer() {
		loyaltyContainer.backgroundColor = .dark
		loyaltyPoints.hideExtraLable()
		loyaltyContainer.addSubview(loyaltyPoints)
		headerView.addSubview(loyaltyContainer)
	}
	
    @objc private func setupProfile() {
		setupLabel(profileName, font: UIFont.rescounts(ofSize: 15))
		profileContainer.addSubview(profileName)
		
		setupLabel(profileEmail, font: UIFont.lightRescounts(ofSize: 13))
		profileContainer.addSubview(profileEmail)
		
		setupLabel(profileCode, font: UIFont.lightRescounts(ofSize: 13))
		profileContainer.addSubview(profileCode)
		
		//RTY code
		setupLabel(profileRTY, font: UIFont.lightRescounts(ofSize: 13))
		if (AccountManager.main.user?.rtyRes?.count ?? 0 > 0) {
			profileContainer.addSubview(profileRTY)
		}
		
		profilePhoto.backgroundColor = .clear
		profilePhoto.contentMode = .scaleAspectFit
		profilePhoto.layer.cornerRadius = k.imageCornerRadius
		profilePhoto.layer.borderWidth = k.imageBorderWidth
		profilePhoto.layer.borderColor = UIColor.gold.cgColor
		profilePhoto.layer.masksToBounds = true
        profilePhoto.layer.backgroundColor = UIColor.black.cgColor
		let tappedPhotoGesture = UITapGestureRecognizer(target: self, action: #selector(tappedProfilePhoto))
		tappedPhotoGesture.delegate = self
		profilePhoto.addGestureRecognizer(tappedPhotoGesture)
		profilePhoto.isUserInteractionEnabled = true;
		profileContainer.addSubview(profilePhoto)
		
		
		if let user = AccountManager.main.user {
			profileName.text = "\(user.firstName) \(user.lastName)"
			profileEmail.text = user.email
			profileCode.text  = ((user.sharingCode?.count ?? 0) > 0) ? "\(l10n("referralCode")): \(user.sharingCode ?? "")" : nil
			profileRTY.text = AccountManager.main.user?.rtyRes ?? "" //This is should be the restaurant name
			profilePhoto.setImageURL(user.profileImage, fetchImmediately: true)
			
		}
	}
	
	private func updateNotificationRow() {
		NotificationManager.notificationsEnabled { [weak self] (globallyEnabled, locallyEnabled) in
			let notificationsEnabled = locallyEnabled && globallyEnabled
			
			if let rowIndex = self?.rowIndexForProfileItemID(k.notificationRowID), let data = self?.data, rowIndex < data.count {
				if let item = data[rowIndex] as? ProfileItem {
					item.title = notificationsEnabled ? l10n("disableNotifications") : l10n("enableNotifications")
					self?.tableView.reloadRows(at: [IndexPath(row: rowIndex, section: 0)], with: .automatic)
				}
			}
		}
	}
	
	
	// MARK: - Private Helpers
	
	@objc func tappedProfilePhoto() {
		self.navigationController?.pushViewController(MyAccountViewController(), animated: true);
	}
	
	private func setupLabel(_ label: UILabel, font: UIFont, text: String = "") {
		label.backgroundColor = .clear
		label.textColor = .white
		label.font = font
		label.textAlignment = .left
		label.text = text
	}
	
	private func setupTableView() {
		updateNotificationRow()
		
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(ProfileRewardsTableViewCell.self, forCellReuseIdentifier: ProfileCellIdentifier.RewardCell.rawValue)
		tableView.register(ProfileBasicTableViewCell.self, forCellReuseIdentifier: ProfileCellIdentifier.ProfileCell.rawValue)
		
		if let user = AccountManager.main.user, !user.hasReferred {
			data.insert(referralCodeRow, at: 2)
		}
        data.insert(dataAttendant, at: 0)
		view.addSubview(tableView)
	}
	
	private func rowIndexForProfileItemID(_ identifier: String) -> Int? {
		for (index, item) in data.enumerated() {
			if let item = item as? ProfileItem, item.identifier == identifier {
				return index
			}
		}
		return nil
	}
	
	private func profileItemForID(_ identifier: String) -> ProfileItem? {
		if let index = rowIndexForProfileItemID(identifier), index < data.count {
			return data[index] as? ProfileItem
		}
		return nil
	}
	
	// MARK: - Public funcs
	public func removeEnterReferralCode(){
		self.data.remove(at: 2)
		tableView.reloadData()
	}
    
    func profileRewardFirstItemTapped(){
        tappedCustomer()
    }
    func profileRewardSecondItemTapped(){
        tappedServer(data: self)
    }
	
	// MARK: - UITableView Methods
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let data = data[indexPath.row] as? ProfileItem, responds(to: Selector(data.action)) {
			perform(Selector(data.action), with:data)
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}

	public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if let data = data[indexPath.row] as? [ProfileRewardItem] {
			return ProfileRewardsTableViewCell.height(data, width: view.frame.width)
		} else if let data = data[indexPath.row] as? ProfileItem {
			return ProfileBasicTableViewCell.height(data, width: view.frame.width)
		}
		return 0.0
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return data.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if ((data[indexPath.row] as? [ProfileRewardItem]) != nil) {
			let cell = tableView.dequeueReusableCell(withIdentifier: ProfileCellIdentifier.RewardCell.rawValue, for: indexPath)
            if let cell = cell as? ProfileRewardsTableViewCell {
                cell.delegate = self
                return cell
            }
			return cell
		} else if ((data[indexPath.row] as? ProfileItem) != nil) {
			let cell = tableView.dequeueReusableCell(withIdentifier: ProfileCellIdentifier.ProfileCell.rawValue, for: indexPath)
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
			return cell
		}
	}
	
	public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let cell = cell as? ProfileBasicTableViewCell {
			cell.item = data[indexPath.row] as? ProfileItem
		} else if let cell = cell as? ProfileRewardsTableViewCell {
			cell.item = data[indexPath.row] as? [ProfileRewardItem]
		}
	}
	
	// MARK: - STPPaymentContextDelegate

	func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
	}

	func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
	}

	func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
	}

	func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
	}
	
	
	// MARK: - MFMailComposeViewControllerDelegate
	
	public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true) {
			print("Done mail: \(result.rawValue)")
		}
	}
}

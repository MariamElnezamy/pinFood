//
//  RestaurantDetailsViewController.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-07-21.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import MapKit

protocol RestaurantReviewDelegate : NSObjectProtocol {
	func performFetch(loadingMore: Bool)
	func getRestaurant() -> Restaurant
	func appendReviews(theList: [RestaurantReview])
}

class RestaurantDetailsViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, RestaurantReviewDelegate {
	
	var restaurant: Restaurant!
	private let map = MKMapView()
	private let address = UIView(frame: .arbitrary)
	private let details = UIView(frame: .arbitrary)
	private let rating = UIView(frame: .arbitrary)
	private let photos = UIView(frame: .arbitrary)
	private let tableView = ReviewTableView(showTitle: true)
	private var photoURLs = [URL]()
	
	let addressLabel = UILabel()
	let descriptionLabel = UILabel()
	let hoursTitle = UILabel()
	let hoursIcon = UIImageView(image: UIImage(named:"IconClock"))
	let daysLabel = UILabel()
	let hoursLabel = UILabel()
	let eventAndEntertainmentTitle = UILabel()
	let eventAndEntertainmentLabel = UILabel()
	let holidayHourTitle = UILabel()
	let holidayHourLabel = UILabel()
	let websiteLabel = UILabel()
	
	let kMapAspect: CGFloat = 2.5
	let kSeparatorHeight: CGFloat = 3
	let kFontSize: CGFloat = 15
	let kDetailFontSize: CGFloat = 13
	let kRatingFontSize: CGFloat = 32
	let kLineHeight: CGFloat = 22
	let kLargeLineHeight: CGFloat = 34
	let kMarginSide: CGFloat = 20
	let kMarginTop: CGFloat = 15
	let kSpacer: CGFloat = 10
	let kSectionSpacer: CGFloat = 30
	let kDirectionsButtonWidth: CGFloat = 100
	let kPhotoSize: CGFloat = 75
	let kDaysWidth: CGFloat = 50
	
	
	// MARK: - Initialization
	
	convenience init(restaurant restaurantToShow: Restaurant) {
		self.init(nibName: nil, bundle: nil, restaurant: restaurantToShow)
	}
	
	init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, restaurant restaurantToShow: Restaurant) {
		restaurant = restaurantToShow
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		assertionFailure("Cannot show the restaurant details screen without a restaurant.")
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		self.title = restaurant.name
	}
	
	
	// MARK: - UIViewController Methods
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.view.backgroundColor = .dark

        setupMap()
		setupAddress()
		setupDetails()
		setupPhotos()
		setupRating()
		setupReviews()
    }
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		let vw = view.frame.width
		let contentWidth = vw - 2*kMarginSide
		
		// Map
		let mapHeight = ceil(vw / kMapAspect)
		map.frame = CGRect(0, -40, vw, mapHeight + 80)
		
		// Address
		let addressWidth = vw - 2*kMarginSide - kDirectionsButtonWidth
		let addressHeight = max(2*kLineHeight, addressLabel.sizeThatFits(CGSize(addressWidth, 200)).height)
		addressLabel.frame = CGRect(kMarginSide, kMarginTop, addressWidth, addressHeight)
		address.frame = CGRect(0, mapHeight, vw, addressLabel.frame.maxY + kMarginTop)
		
		// Description / Hours
		let descriptionHeight = descriptionLabel.sizeThatFits(CGSize(contentWidth, 600)).height
		descriptionLabel.frame = CGRect(kMarginSide, kMarginTop + kLineHeight + kSpacer, contentWidth, descriptionHeight)
		
		// Website
		let websiteHeight = websiteLabel.sizeThatFits(CGSize(contentWidth, 400)).height
		websiteLabel.frame = CGRect(kMarginSide, descriptionLabel.frame.maxY + kMarginTop, contentWidth, websiteHeight)
		
		// Event and Entertainment
		var lastY = websiteLabel.frame.maxY
		if (eventAndEntertainmentLabel.text?.trimmed.count ?? 0) > 0 {
			let eventsHeight = eventAndEntertainmentLabel.sizeThatFits(CGSize(contentWidth, 400)).height
			eventAndEntertainmentTitle.frame = CGRect(kMarginSide, websiteLabel.frame.maxY + kSectionSpacer, contentWidth, kLineHeight)
			eventAndEntertainmentLabel.frame = CGRect(kMarginSide, eventAndEntertainmentTitle.frame.maxY + kSpacer, contentWidth, eventsHeight)
			lastY = eventAndEntertainmentLabel.frame.maxY
		} else {
			eventAndEntertainmentTitle.frame = .zero
			eventAndEntertainmentLabel.frame = .zero
		}
		
		// Holiday hours
		if (holidayHourLabel.text?.trimmed.count ?? 0) > 0 {
			let holidayHeight = holidayHourLabel.sizeThatFits(CGSize(contentWidth, 400)).height
			holidayHourTitle.frame = CGRect(kMarginSide, lastY + kSectionSpacer, contentWidth, kLineHeight)
			holidayHourLabel.frame = CGRect(kMarginSide, holidayHourTitle.frame.maxY + kSpacer, contentWidth, holidayHeight)
			lastY = holidayHourLabel.frame.maxY
		} else {
			holidayHourTitle.frame = .zero
			holidayHourLabel.frame = .zero
		}
		
		// Hours
		let hoursFont = hoursTitle.font ?? UIFont.lightRescounts(ofSize: kFontSize)
		let iconHeight = ceil(hoursFont.capHeight)
		let hoursY = lastY + kSectionSpacer
		let iconY = hoursY + Helper.roundf(hoursFont.topCapYForLabelHeight(kLineHeight), denom: 2) // Round to nearest 0.5
		hoursIcon.frame = CGRect(kMarginSide, iconY, iconHeight, iconHeight)
		hoursTitle.frame = CGRect(hoursIcon.frame.maxX + 5, hoursY, contentWidth - iconHeight - 5, kLineHeight)
		
		let hoursHeight = ceil(hoursLabel.sizeThatFits(CGSize(400, 400)).height)
		daysLabel.frame  = CGRect(kMarginSide, hoursTitle.frame.maxY + kSpacer, kDaysWidth, hoursHeight)
		hoursLabel.frame = CGRect(kMarginSide + kDaysWidth, daysLabel.frame.minY, contentWidth - kDaysWidth, hoursHeight)
		
		details.frame = CGRect(0, address.frame.maxY, vw, hoursLabel.frame.maxY + kLineHeight + kMarginTop)
		
		
		// TODO: should we hide the user photos section if there are none?
		photos.frame  = CGRect(0, details.frame.maxY, vw, 2*kMarginTop + kSpacer + kPhotoSize + kLineHeight + kSeparatorHeight)
		rating.frame  = CGRect(0, photos.frame.maxY,  vw, 2*kMarginTop + 2*kLineHeight + kLargeLineHeight + 2*kSpacer + kSeparatorHeight)
		tableView.frame = view.bounds
		
		tableView.beginUpdates()
			tableView.tableHeaderView?.frame = CGRect(0, 0, vw, rating.frame.maxY)
		tableView.endUpdates()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	
	// MARK: - View Setup
	
	@objc private func shareTapped() {
		if AccountManager.main.user != nil {
			let vc = SharingManager.getSharingVC()
			self.present(vc, animated: true, completion: nil)
		} else {
			AccountManager.main.showLoginUI(from: self)
		}
	}
	
	private func setupMap() {
		let span = MKCoordinateSpanMake(0.001, 0.001)
		let center = restaurant.location
		
		map.setRegion(MKCoordinateRegionMake(center, span), animated: false)
		map.isUserInteractionEnabled = false
		
		let annotation = BrowseMapAnnotation()
		annotation.coordinate = restaurant.location
		annotation.title = restaurant.name
		annotation.restaurantID = restaurant.restaurantID
		map.addAnnotation(annotation)
	}
	
	private func setupAddress() {
		address.backgroundColor = .white
		addSeparatorTo(address)
		
		setupLabel(addressLabel, text:restaurant.address, font: UIFont.lightRescounts(ofSize: 14), alignment: .left, lines: 0, parent: address)
		
		let dirButton = UIButton()
		dirButton.setTitle(l10n("directions"), for: .normal)
		dirButton.setTitleColor(.gold, for: .normal)
		dirButton.setTitleColor(UIColor.gold.darker(), for: .highlighted)
		dirButton.titleLabel?.font = UIFont.rescounts(ofSize: kFontSize)
		dirButton.titleLabel?.textAlignment = .right
		dirButton.contentHorizontalAlignment = .right
		dirButton.frame = CGRect(address.frame.width - kMarginSide - kDirectionsButtonWidth, kMarginTop, kDirectionsButtonWidth, kLineHeight)
		dirButton.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
		dirButton.addAction(for: .touchUpInside) {
			print("Tapped directions")
			self.openMapForLocation()
		}
		address.addSubview(dirButton)
		
		let distLabel = UILabel()
		setupLabel(distLabel, text: LocationManager.displayDistanceToLocation(restaurant.location), font: UIFont.lightRescounts(ofSize: kFontSize), colour: .lightGrayText, alignment: .right, parent: address)
		distLabel.frame = CGRect(address.frame.width - kMarginSide - kDirectionsButtonWidth, dirButton.frame.maxY, kDirectionsButtonWidth, kLineHeight)
		distLabel.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
	}
	
	private func openMapForLocation() {
		// TODO make region size dynamic
		let regionDistance:CLLocationDistance = 10000
		let regionSpan = MKCoordinateRegionMakeWithDistance(restaurant.location, regionDistance, regionDistance)
		let options = [
			MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
			MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
		]
		let placemark = MKPlacemark(coordinate: restaurant.location, addressDictionary: nil)
		let mapItem = MKMapItem(placemark: placemark)
		mapItem.name = restaurant.name
		mapItem.openInMaps(launchOptions: options)
	}
	
	private func setupDetails() {
		details.backgroundColor = .white
		addSeparatorTo(details)
		
		let titleLabel = UILabel()
		setupLabel(titleLabel, text: l10n("description").uppercased(), font: UIFont.lightRescounts(ofSize: kFontSize), colour: .dark, parent: details)
		titleLabel.frame = CGRect(kMarginSide, kMarginTop, details.frame.width - 2*kMarginSide, kLineHeight)
		titleLabel.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
		
		setupLabel(descriptionLabel, text: restaurant.restaurantDescription, font: UIFont.lightRescounts(ofSize: kDetailFontSize), lines: 0, parent: details)
		
		setupLabel(websiteLabel, text: restaurant.website, font: UIFont.lightRescounts(ofSize: kDetailFontSize), colour: .primary, lines: 0, parent: details)
		
		let websiteTap = UITapGestureRecognizer(target: self, action: #selector(websiteOnClick))
		websiteLabel.isUserInteractionEnabled = true
		websiteLabel.addGestureRecognizer(websiteTap)
		
		setupLabel(eventAndEntertainmentTitle, text: l10n("events&ent").uppercased(), font: UIFont.lightRescounts(ofSize: kFontSize),colour: .dark, parent: details )
		setupLabel(eventAndEntertainmentLabel, text: restaurant.eventsAndEntertainment, font: UIFont.lightRescounts(ofSize: kDetailFontSize), lines: 0, parent: details)
		
		setupLabel(holidayHourTitle, text: l10n("holidayHours").uppercased(), font: UIFont.lightRescounts(ofSize: kFontSize), colour: .dark, parent: details)
		
		setupLabel(holidayHourLabel, text: restaurant.holidayHours , font: UIFont.lightRescounts(ofSize: kDetailFontSize), lines: 0, parent: details)
		
        
       
		let hours: (days: String, hours: String) = HoursManager.allDaysAsString(restaurant.hours)
        
        if hours.days != "" {
            setupLabel(daysLabel,  text: hours.days,  font: UIFont.lightRescounts(ofSize: kDetailFontSize), lines: 0, parent: details)
        } else {
            let days = "Mon:\nTues:\nWed:\nThurs:\nFri:\nSat:\nSun:"
              setupLabel(daysLabel,  text: days,  font: UIFont.lightRescounts(ofSize: kDetailFontSize), lines: 0, parent: details)
        }
        if hours.hours != "" {
               setupLabel(hoursLabel, text: hours.hours, font: UIFont.lightRescounts(ofSize: kDetailFontSize), lines: 0, parent: details)
        } else {
            let hours = "Closed\nClosed\nClosed\nClosed\nClosed\nClosed\nClosed"
                setupLabel(hoursLabel, text: hours, font: UIFont.lightRescounts(ofSize: kDetailFontSize), lines: 0, parent: details)
        }
		hoursIcon.contentMode = .scaleAspectFit
		details.addSubview(hoursIcon)
		
		setupLabel(hoursTitle, text: l10n("hours"), font: UIFont.lightRescounts(ofSize: kFontSize), colour: .dark, parent: details)
	}
	
	private func setupPhotos() {
		photos.backgroundColor = .white
		addSeparatorTo(photos)
		
		photoURLs = restaurant.restaurantPhotos
		
		let photoCarouselLayout = UICollectionViewFlowLayout()
		photoCarouselLayout.scrollDirection = .horizontal
		photoCarouselLayout.headerReferenceSize = CGSize(kMarginSide, kMarginSide)
		photoCarouselLayout.footerReferenceSize = CGSize(kMarginSide, kMarginSide)
		photoCarouselLayout.itemSize = CGSize(kPhotoSize, kPhotoSize)
		photoCarouselLayout.minimumLineSpacing = kSpacer
		photoCarouselLayout.minimumInteritemSpacing = 0
		
		let photoCarousel = UICollectionView(frame: CGRect(0, kMarginTop, photos.frame.width, kPhotoSize), collectionViewLayout: photoCarouselLayout)
		photoCarousel.register(RemoteImageCollectionCell.self, forCellWithReuseIdentifier: "cell")
		photoCarousel.backgroundColor = .clear
		photoCarousel.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
		photoCarousel.dataSource = self
		photoCarousel.delegate = self
		photos.addSubview(photoCarousel)
		
		let photoButt = UIButton()
		photoButt.setTitle(l10n("viewPhotos"), for: .normal)
		photoButt.setTitleColor(.dark, for: .normal)
		photoButt.setTitleColor(UIColor.dark.lighter(), for: .highlighted)
		photoButt.titleLabel?.font = UIFont.lightRescounts(ofSize: kFontSize)
		photoButt.contentHorizontalAlignment = .right
		photoButt.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin]
		photoButt.sizeToFit()
		photoButt.frame = CGRect(photos.frame.width - kMarginSide - ceil(photoButt.frame.width), photoCarousel.frame.maxY + kSpacer, ceil(photoButt.frame.width), kLineHeight + kSeparatorHeight)
		photoButt.addAction(for: .touchUpInside) { [weak self] in
			self?.showGallery()
		}
		photos.addSubview(photoButt)
		
		let buttBar = UIView(frame: CGRect(0, photoButt.frame.height - kSeparatorHeight, photoButt.frame.width, kSeparatorHeight))
		buttBar.backgroundColor = .gold
		buttBar.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
		photoButt.addSubview(buttBar)
	}
	
	private func setupRating() {
		rating.backgroundColor = .white
		addSeparatorTo(rating)
		
		let overallTitle = UILabel()
		setupLabel(overallTitle, text: l10n("overall").uppercased(), font: UIFont.lightRescounts(ofSize: kDetailFontSize), colour: .dark, parent: rating)
		overallTitle.frame = CGRect(kMarginSide, kMarginTop, 200, kLineHeight)
		overallTitle.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
		
		let overallLabel = UILabel()
		setupLabel(overallLabel, text: String(format: "%.01f", restaurant.rating), font: UIFont.rescounts(ofSize: kRatingFontSize), parent: rating)
		overallLabel.frame = CGRect(kMarginSide, overallTitle.frame.maxY + kSpacer, 200, kLargeLineHeight)
		overallLabel.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
		
		let overallRating = StarGroup()
		overallRating.setColours(on: .gold)
		overallRating.setValue(restaurant.rating, maxValue: Constants.Restaurant.maxRating, numReviews:restaurant.numRatings)
		overallRating.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
		overallRating.frame = CGRect(kMarginSide, overallLabel.frame.maxY + kSpacer, overallRating.idealWidthForHeight(kLineHeight), kLineHeight)
		rating.addSubview(overallRating)
		
		let serviceRating = StarGroup()
		serviceRating.setColours(on: .gold)
		serviceRating.setValue(restaurant.serverRating, maxValue: Constants.Restaurant.maxRating, numReviews:restaurant.numRatings)
		serviceRating.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
		let serviceWidth = serviceRating.idealWidthForHeight(kLineHeight)
		let serviceX = rating.frame.width - kMarginSide - serviceWidth
		serviceRating.frame = CGRect(serviceX, overallLabel.frame.maxY + kSpacer, serviceWidth, kLineHeight)
		rating.addSubview(serviceRating)
		
		let serviceTitle = UILabel()
		setupLabel(serviceTitle, text: l10n("service").uppercased(), font: UIFont.lightRescounts(ofSize: kDetailFontSize), colour: .dark, parent: rating)
		serviceTitle.frame = CGRect(serviceX, kMarginTop, serviceWidth, kLineHeight)
		serviceTitle.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
		
		let serviceLabel = UILabel()
		setupLabel(serviceLabel, text: String(format: "%.01f", restaurant.serverRating), font: UIFont.rescounts(ofSize: kRatingFontSize), parent: rating)
		serviceLabel.frame = CGRect(serviceX, overallTitle.frame.maxY + kSpacer, serviceWidth, kLargeLineHeight)
		serviceLabel.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
	}
	
	private func setupReviews() {
		let header = UIView()
		header.addSubview(map)
		header.addSubview(address)
		header.addSubview(details)
		header.addSubview(photos)
		header.addSubview(rating)
		tableView.tableHeaderView = header
		//TODO: REVIEWS
		tableView.fetchDelegate = self
		tableView.reviews = restaurant.reviews
		
		view.addSubview(tableView)
	}
	
	private func setupLabel(_ label: UILabel, text: String, font: UIFont, colour: UIColor = .dark, alignment: NSTextAlignment = .left, lines: Int = 1, parent: UIView? = nil) {
		label.text = text
		label.font = font
		label.textAlignment = alignment
		label.textColor = colour
		label.numberOfLines = lines
		(parent ?? view).addSubview(label)
	}
	
	private func addSeparatorTo(_ view: UIView) {
		let s = UIView()
		s.backgroundColor = .separators
		s.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
		s.frame = CGRect(0, view.frame.height - kSeparatorHeight, view.frame.width, kSeparatorHeight)
		view.addSubview(s)
	}
	
	@objc func websiteOnClick() {
		var urlString = restaurant.website
		if (!urlString.lowercased().hasPrefix("http")) {
			urlString = "http://\(urlString)"
		}
		
		if let url = NSURL(string: urlString) {
			
			UIApplication.shared.open(url as URL, options: [:]) { (completed) in
				if (!completed) {
					RescountsAlert.showAlert(title: "Error", text: "Could not open this website URL.")
				}
			}
			
		} else {
			RescountsAlert.showAlert(title: "Error", text: "Restaurant's website URL is invalid.")
		}
	}
	
	// MARK: - Protocol
	
	func performFetch( loadingMore: Bool) {
		// TODO: Remove this? Looks like it's already handled in ReviewTableView
		if !ReviewService.shouldIMakeCall() {
			print("Cancelled search: one already active.")
			return
		}
		let searchOffset = loadingMore ? restaurant.reviews.count : 0
		ReviewService.fetchReviews(restaurant: restaurant, offset:searchOffset) { (restaurantReviews : [RestaurantReview]?) in
			if let theList = restaurantReviews {
				self.restaurant.reviews.append(contentsOf: theList)
				self.tableView.showMoreReviews(theList, loadingMore: loadingMore)
			}
		}
		
	}
	
	func getRestaurant() -> Restaurant {
		return restaurant
	}
	
	func appendReviews(theList: [RestaurantReview]) {
		self.restaurant.reviews.append(contentsOf: theList)
	}
	
	
	// MARK: - Actions
	
	private func showGallery(at startingIndex: Int = 0) {
		let vc = GalleryViewController(imageURLs: photoURLs, startingIndex: startingIndex)
		navigationController?.pushViewController(vc, animated: true)
	}
	
	// MARK: - UICollectionViewDelegate
	
	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return photoURLs.count
	}
	
	public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
		return cell
	}
	
	public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if let cell = cell as? RemoteImageCollectionCell {
			cell.contentView.backgroundColor = UIColor(white: 0.97, alpha: 1)
			cell.imageView.setImageURL(photoURLs[indexPath.row])
		}
	}
	
	public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		showGallery(at: indexPath.row)
	}
}

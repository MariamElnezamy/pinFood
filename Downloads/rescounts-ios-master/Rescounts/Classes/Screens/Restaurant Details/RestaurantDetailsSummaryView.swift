//
//  RestaurantDetailsSummaryView.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-07-11.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import MapKit
class RestaurantDetailsSummaryView: UIView {

	let starView       = StarGroup()
	let serverView     = StarGroup()
	let nameLabel      = UILabel()
	let cuisineLabel   = UILabel()
	let priceLabel     = UILabel()
	let hoursLabel     = UILabel()
	let callButton     = UIControl(frame: .arbitrary)
	let callSubviews   = (image: UIImageView(), title: UILabel())
    
    let directionsLabel  = UILabel()
    let directionsButton = UIButton()
    
	let kTopMargin: CGFloat = 15
	let kSideMargin: CGFloat = 20.0
	let kSpacer: CGFloat = 5.0
	let kTitleFontSize: CGFloat = 15.0
	let kDetailFontSize: CGFloat = 13.0
	let kTitleHeight: CGFloat = 26.0
	let kDetailHeight: CGFloat = 24.0
	let kStarHeight: CGFloat = 18.0
    var restaurant: Restaurant?

	
	// MARK: - Initialization
	convenience init() {
		self.init(frame: CGRect(0.0, 0.0, 200.0, 100.0)) // Arbitrary size for autoresizing
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
		
		setupLabel(nameLabel,    font: .rescounts(ofSize: kTitleFontSize))
		setupLabel(cuisineLabel, font: .lightRescounts(ofSize: kDetailFontSize), alignment: .right)
		setupLabel(priceLabel,   font: .lightRescounts(ofSize: kDetailFontSize), alignment: .right)
		setupLabel(hoursLabel,   font: .lightRescounts(ofSize: kDetailFontSize), alignment: .right)
        setupLabel(directionsLabel,   font: .rescounts(ofSize: kTitleFontSize), alignment: .right)

		setupCallButton()
		setupDirectionButton()
		starView.setColours(on: .gold)
		addSubview(starView)
		
		serverView.setColours(on: .gold)
		addSubview(serverView)
	}
	
	
	// MARK: - UIView Methods
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let starWidth       = floor(frame.width * 0.5)
		let rightTextWidth  = frame.size.width - 2*kSideMargin - starWidth
		
		nameLabel.frame     = CGRect(kSideMargin, kTopMargin, frame.size.width - 2*kSideMargin - rightTextWidth + 50, kTitleHeight)
		starView.frame      = CGRect(kSideMargin, nameLabel.frame.maxY + 2*kSpacer, starWidth, kStarHeight)
		serverView.frame    = CGRect(kSideMargin, nameLabel.frame.maxY + 3*kSpacer + kDetailHeight, starWidth, kStarHeight)
		
		let textX = frame.width - rightTextWidth - kSideMargin
		
		priceLabel.frame = CGRect(textX , starView.frame.minY, rightTextWidth, kDetailHeight)
		
		let cuisineWidth : CGFloat = rightTextWidth + 65
		let cuisineHeight : CGFloat = cuisineLabel.sizeThatFits(CGSize(cuisineWidth, 1000)).height
		

        directionsLabel.frame = CGRect(textX - 90  , kTopMargin,   cuisineWidth,   kTitleHeight)
        directionsButton.frame = CGRect(frame.width - 2*kSideMargin , kTopMargin,   25,   25)

		cuisineLabel.frame = CGRect(textX - 65, serverView.frame.minY + kSpacer + kDetailHeight + 4,   cuisineWidth,   cuisineHeight)
		hoursLabel.frame = CGRect(textX, serverView.frame.minY, rightTextWidth, kDetailHeight)
		
		callButton.frame = CGRect(kSideMargin, serverView.frame.minY + kSpacer + kDetailHeight, textX - kSideMargin - 60, kDetailHeight)
		callSubviews.image.frame = CGRect(0, 0, kStarHeight, kDetailHeight)
		callSubviews.title.frame = CGRect(kStarHeight + 5, 0, callButton.frame.width - kDetailHeight - 5, kDetailHeight)
	}
	
	
	// MARK: - Public Methods
	
	public func idealHeight() -> CGFloat {
		let starWidth       = floor(frame.width * 0.4)
		let rightTextWidth  = frame.size.width - 2*kSideMargin - starWidth
		let cuisineWidth : CGFloat = rightTextWidth + 65
		var cuisineHeight : CGFloat = cuisineLabel.sizeThatFits(CGSize(cuisineWidth, 1000)).height - 2*kSpacer
		if cuisineHeight <= kDetailHeight {
			cuisineHeight = kDetailHeight
		}
		
		return 2*kTopMargin + kTitleHeight + 4*kSpacer + 2*kDetailHeight + cuisineHeight
	}
	
	public func setRestaurant(_ restaurant: Restaurant?) {
        self.restaurant = restaurant
		nameLabel.text = restaurant?.name
		cuisineLabel.text = restaurant?.cuisineTypesAsString()
        directionsLabel.text = "Directions"
        directionsLabel.textColor = .gold
		cuisineLabel.numberOfLines = 0
		priceLabel.text = restaurant?.averagePriceAsString()
		hoursLabel.attributedText = textForHours(restaurant)
		starView.setValue((restaurant?.numRatings ?? 0) > 0 ? (restaurant?.rating ?? 0) : 5, maxValue: Constants.Restaurant.maxRating, numReviews: restaurant?.numRatings, iconName: /*"LogoRSplashSmall"*/ nil, titleText: l10n("overall"))
		serverView.setValue((restaurant?.numRatings ?? 0) > 0 ? (restaurant?.serverRating ?? 0) : 5, maxValue: Constants.Restaurant.maxRating, numReviews:nil, iconName: /*"IconServiceSmall"*/ nil, titleText: l10n("service"))
	}
	
	// MARK: - Private Helpers
	
	private func setupLabel(_ label: UILabel, font: UIFont, alignment: NSTextAlignment = .left) {
		label.font = font
		label.textAlignment = alignment
		label.textColor = .dark
		addSubview(label)
	}
	
	private func setupCallButton() {
		callSubviews.image.image = UIImage(named: "IconCallSmall")
		callSubviews.image.contentMode = .scaleAspectFit
		
		callSubviews.title.text = l10n("callUs")
		callSubviews.title.font = .lightRescounts(ofSize:kDetailFontSize)
		callSubviews.title.textColor = .nearBlack
		
		callButton.addAction(for: .touchUpInside) {
			RescountsAlert.showAlert(title: l10n("callSupport"), text: "\(l10n("callSupportText"))\n\(Constants.Rescounts.supportNumberDisplay)", icon: nil, postIconText: nil, options: [l10n("no"), l10n("callSupport")]) { (alert, buttonIndex) in
				if (buttonIndex == 1) {
					Helper.callSupport(orShowPopup: true)
				}
			}
		}
		
		callButton.addSubview(callSubviews.image)
		callButton.addSubview(callSubviews.title)
		addSubview(callButton)
	}
	
    
    func setupDirectionButton() {
        
        directionsButton.setImage(UIImage(named: "mapgoogle"), for: .normal)
        
        directionsButton.addAction(for: .touchUpInside) {
    
            self.openMapForLocation()
        }
        
 
        addSubview(directionsButton)
    }
    
    private func openMapForLocation() {
        // TODO make region size dynamic
        guard let restaurant = self.restaurant else {
                 return
             }
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

	private func textForHours(_ restaurant: Restaurant?) -> NSAttributedString {
		guard let restaurant=restaurant else {
			return NSMutableAttributedString()
		}
		//Remove the Open and Closed status keyword
		//let colour = restaurant.isOpen() ? UIColor.openGreen : UIColor.closedRed
		//let open   = restaurant.isOpen() ? l10n("open") : l10n("closed")
		let hours  = restaurant.todaysHoursAsString()
		
		let retVal = NSMutableAttributedString(string: /*"\(open)  "*/ "")
		//retVal.addAttribute(.foregroundColor, value: colour, range: NSMakeRange(0, open.count))
        if hours == "" {
            retVal.append(NSAttributedString(string: "Closed"))

        } else {
            retVal.append(NSAttributedString(string: hours))

        }
		
		return retVal
	}

}

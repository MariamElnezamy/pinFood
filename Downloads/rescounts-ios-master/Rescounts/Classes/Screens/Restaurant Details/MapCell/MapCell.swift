//
//  MapCell.swift
//  Rescounts
//
//  Created by Martin Sorsok on 6/26/20.
//  Copyright © 2020 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import MapKit
class MapCell: UITableViewCell {

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var address: UIView!
    
    @IBOutlet weak var addressLabel: UILabel!
    var restaurant: Restaurant? {
        didSet {
            setupMap()
            setupAddress()
        }
    }
    
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
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    private func setupMap() {
        let span = MKCoordinateSpanMake(0.001, 0.001)
        guard let restaurant = self.restaurant else {
            return
        }
        let center = restaurant.location
        
        mapView.setRegion(MKCoordinateRegionMake(center, span), animated: false)
        mapView.isUserInteractionEnabled = false
        
        let annotation = BrowseMapAnnotation()
        annotation.coordinate = restaurant.location
        annotation.title = restaurant.name
        annotation.restaurantID = restaurant.restaurantID
        mapView.addAnnotation(annotation)
    }
    private func setupAddress() {
        address.backgroundColor = .white
        guard let restaurant = self.restaurant else {
                return
            }
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
    private func setupLabel(_ label: UILabel, text: String, font: UIFont, colour: UIColor = .dark, alignment: NSTextAlignment = .left, lines: Int = 1, parent: UIView? = nil) {
        label.text = text
        label.font = font
        label.textAlignment = alignment
        label.textColor = colour
        label.numberOfLines = lines
        parent!.addSubview(label)
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
}

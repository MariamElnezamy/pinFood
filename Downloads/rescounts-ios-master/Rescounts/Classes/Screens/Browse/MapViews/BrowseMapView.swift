//
//  BrowseMapView.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-15.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import MapKit

class BrowseMapView: MKMapView, MKMapViewDelegate {
	
	enum BrowseMapMode {
		case normal
		case restaurantAndUser
	}
	
	weak public var browseDelegate: BrowseViewDelegate?
	
	var selectedRestaurant: Restaurant?
	var selectedIndex: Int = 0
	var restaurants: [Restaurant] = []
	var summaryView = RestaurantSummaryView()
	var nextSummaryView = RestaurantSummaryView()
	var lastSearchCentre: CLLocationCoordinate2D?     // Centre of the visible map when last search performed
	var lastSearchResultsRegion: MKCoordinateRegion?  // Region of actual results from last search
	
	private let kSummaryMargin: CGFloat = 20.0
	private let kSummaryHeight: CGFloat = 90.0
	
	private let kPinID = "restaurantPin"
	
	private var mapMode: BrowseMapMode = .normal
	
	
	// MARK: - Initialization
	
	convenience init() {
		self.init(frame:CGRect.arbitrary)
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
		self.showsUserLocation = true
		self.delegate = self
		
		if #available(iOS 11.0, *) {
			self.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: kPinID)
		}
	}
	
	
	// MARK: - Public Methods
	
	public func showRestaurants(_ restaurants: [Restaurant], viewMode: BrowseMapMode = .normal, includeUserLocation: Bool = true) {
		self.mapMode = viewMode
		self.restaurants = restaurants
		placePins(includeUserLocation: includeUserLocation)
		updateSummary()
	}
	
	public func updateSearchCentre(centre: CLLocationCoordinate2D? = nil, region: MKCoordinateRegion? = nil) {
		self.lastSearchCentre = centre ?? self.centerCoordinate
		self.lastSearchResultsRegion = region ?? self.region
	}
	
	
	// MARK: - UI Actions
	
	fileprivate func placePins(includeUserLocation: Bool) {
		self.removeAllAnnotations()
		
		var firstPin: BrowseMapAnnotation?
		for restaurant in restaurants {
			let annotation = BrowseMapAnnotation()
			annotation.coordinate = restaurant.location
			annotation.title = restaurant.name
			annotation.restaurantID = restaurant.restaurantID
			self.addAnnotation(annotation)
			
			firstPin = firstPin ?? annotation
		}
		
		if let firstPin = firstPin {
			let animated = (mapMode == .normal)
			self.setRegion(visibleRegionForAnnotations(self.annotations, poiLocation: includeUserLocation ? self.region.center : restaurants.first?.location), animated:animated)
			self.selectAnnotation(firstPin, animated: animated)
			selectedAnnotation(firstPin)
			updateSearchCentre(region: regionForAnnotations(self.annotations))
		}
	}
	
	fileprivate func updateSummary() {
		// TODO: Setup multiple views and swipe behaviour
		
		// Remove old
		summaryView.removeFromSuperview()
		nextSummaryView.removeFromSuperview()
		
		// Setup new one
		if let restaurant = self.selectedRestaurant {
			summaryView = addNewSummaryView(restaurant: restaurant)
			nextSummaryView = addNewSummaryView(restaurant: self.restaurants[(self.selectedIndex + 1) % self.restaurants.count], isPreview: true)
			
			addRecognizers(view: summaryView)
		}
	}
	
	private func addNewSummaryView(restaurant: Restaurant, isPreview: Bool = false) -> RestaurantSummaryView {
		
		// Setup new one
		let view = RestaurantSummaryView()
		
		let viewWidth = max(270, frame.size.width - 4*kSummaryMargin)
		let viewX = kSummaryMargin + (isPreview ? viewWidth + kSummaryMargin : 0)
		view.frame = CGRect(viewX, frame.size.height - kSummaryHeight - kSummaryMargin, viewWidth, kSummaryHeight)
		view.autoresizingMask = [(isPreview ? .flexibleLeftMargin : .flexibleWidth), .flexibleTopMargin]
		
		view.setRestaurant(restaurant)
		
		view.isHidden = mapMode == .restaurantAndUser
		
		// Then add it
		addSubview(view)
		
		return view
	}
	
	private func addRecognizers(view: RestaurantSummaryView) {
		view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(restaurantTapped(_:))))
		
		let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipedSummary))
		swipeLeft.direction = .left
		view.addGestureRecognizer(swipeLeft)
		
		let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipedSummary))
		swipeRight.direction = .right
		view.addGestureRecognizer(swipeRight)
	}
	
	private func removeRecognizers(view: RestaurantSummaryView) {
		view.gestureRecognizers?.forEach(view.removeGestureRecognizer)
	}
	
	// Direction should be 1 or -1
	private func showNextRestaurant(direction: Int) {
		removeRecognizers(view: self.summaryView)
		
		let indexFixer = (direction > 0) ? 2*direction : direction
		let directionScalar = CGFloat(direction)
		let newView = addNewSummaryView(restaurant: restaurants[(selectedIndex + indexFixer + restaurants.count) % restaurants.count],
										isPreview: direction > 0)
		
		let viewWidth = self.summaryView.frame.width
		let viewX = kSummaryMargin + (direction > 0 ? 2*directionScalar : directionScalar) * (viewWidth + kSummaryMargin)
		newView.frame = CGRect(viewX, frame.size.height - kSummaryHeight - kSummaryMargin, viewWidth, kSummaryHeight)
		
		UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
			let slideDistance = viewWidth + self.kSummaryMargin
			newView.setX(direction > 0 ? self.nextSummaryView.frame.minX : self.summaryView.frame.minX)
			self.summaryView.setX(self.summaryView.frame.minX - directionScalar * slideDistance)
			self.nextSummaryView.setX(self.nextSummaryView.frame.minX - directionScalar * slideDistance)
		}) { (completed) in
			if (direction > 0) {
				self.summaryView.removeFromSuperview()
				self.summaryView = self.nextSummaryView
				self.nextSummaryView = newView
			} else {
				self.nextSummaryView.removeFromSuperview()
				self.nextSummaryView = self.summaryView
				self.summaryView = newView
			}
			self.selectedRestaurant = self.summaryView.restaurant
			self.selectedIndex += direction
			self.addRecognizers(view: self.summaryView)
			
			if let selected = self.selectedRestaurant, let annotation = self.annotationForRestaurant(selected) {
				self.selectAnnotation(annotation, animated: true)
			}
		}
	}
	
	
	// MARK: - Private Helpers
	
	fileprivate func visibleRegionForAnnotations(_ annotations: [MKAnnotation], poiLocation: CLLocationCoordinate2D?) ->MKCoordinateRegion {
		let center = mapMode == .normal ? nil : midPoint(self.userLocation.coordinate, annotations.first?.coordinate)
		var retVal = regionForAnnotations(annotations, center: center ?? poiLocation)
		
		// Zoom out slightly
		retVal.span.latitudeDelta  = min(120, retVal.span.latitudeDelta  * 1.1)
		retVal.span.longitudeDelta = min(120, retVal.span.longitudeDelta * 1.1)
		
		return retVal
	}
	
	fileprivate func regionForAnnotations(_ annotations: [MKAnnotation], center: CLLocationCoordinate2D?) ->MKCoordinateRegion {
		let uncenteredRegion = regionForAnnotations(annotations)
		
		var retVal = uncenteredRegion
		
		if let center = center {
			retVal.span.latitudeDelta = retVal.span.latitudeDelta + 2 * abs(uncenteredRegion.center.latitude - center.latitude)
			retVal.span.longitudeDelta = retVal.span.longitudeDelta + 2 * abs(uncenteredRegion.center.longitude - center.longitude)
			retVal.center = center
		}
		
		return retVal
	}
	
	fileprivate func regionForAnnotations(_ annotations: [MKAnnotation]) ->MKCoordinateRegion {
		var minLat: CLLocationDegrees =  90.0
		var maxLat: CLLocationDegrees = -90.0
		var minLon: CLLocationDegrees =  180.0
		var maxLon: CLLocationDegrees = -180.0
		
		for annotation in annotations {
			updateMinMaxesForCoord(annotation.coordinate, minLat: &minLat, maxLat: &maxLat, minLon: &minLon, maxLon: &maxLon)
		}
		if mapMode == .restaurantAndUser, let coord = self.userLocation.location?.coordinate {
			updateMinMaxesForCoord(coord, minLat: &minLat, maxLat: &maxLat, minLon: &minLon, maxLon: &maxLon)
		}
		
		let span = MKCoordinateSpanMake(abs(maxLat - minLat), abs(maxLon - minLon))
		
		let center = CLLocationCoordinate2DMake((maxLat - span.latitudeDelta / 2), maxLon - span.longitudeDelta / 2)
		
		return MKCoordinateRegionMake(center, span)
	}
	
	fileprivate func updateMinMaxesForCoord(_ coord: CLLocationCoordinate2D, minLat: inout CLLocationDegrees, maxLat: inout CLLocationDegrees, minLon: inout CLLocationDegrees, maxLon: inout CLLocationDegrees) {
		if (coord.latitude < minLat) {
			minLat = coord.latitude
		}
		if (coord.longitude < minLon) {
			minLon = coord.longitude
		}
		if (coord.latitude > maxLat) {
			maxLat = coord.latitude
		}
		if (coord.longitude > maxLon) {
			maxLon = coord.longitude
		}
	}
	
	@objc private func restaurantTapped(_ sender: UIGestureRecognizer) {
		if let view = sender.view as? RestaurantSummaryView, let restaurant = view.restaurant {
			self.browseDelegate?.selectedRestaurant(restaurant)
		}
	}
	
	private func restaurantForID(_ restaurantID: String) -> Restaurant? {
		var retVal: Restaurant? = nil
		for restaurant in self.restaurants {
			if restaurant.restaurantID == restaurantID {
				retVal = restaurant
				break
			}
		}
		return retVal
	}
	
	private func updateAnnotationView(_ view: MKAnnotationView, image: UIImage?) {
		view.image = image
		let imageHeight = image?.size.height ?? 0
		view.centerOffset = CGPoint(0, -imageHeight / 2)
	}
	
	private func midPoint(_ pt1: CLLocationCoordinate2D?, _ pt2: CLLocationCoordinate2D?) -> CLLocationCoordinate2D? {
		if let pt1 = pt1, let pt2 = pt2 {
			return middlePointOfListMarkers([pt1, pt2])
		} else {
			return nil
		}
	}
	
	private func removeAllAnnotations() {
		let restaurantAnnotations = self.annotations.filter {
			$0 !== self.userLocation
		}
		removeAnnotations(restaurantAnnotations)
	}
	
	@objc private func swipedSummary(sender: UISwipeGestureRecognizer) {
		print ("Swiped.  \(sender)")
		switch sender.direction {
		case .left:
			print ("left")
			showNextRestaurant(direction: 1)
			break
		case .right:
			print ("right")
			showNextRestaurant(direction: -1)
			break
		default:
			print ("Unknown swipe direction: \(sender.direction)")
		}
	}
	
	private func annotationForRestaurant(_ restaurant: Restaurant) -> BrowseMapAnnotation? {
		for annotation in self.annotations {
			if let annotation = annotation as? BrowseMapAnnotation, annotation.restaurantID == restaurant.restaurantID {
				return annotation
			}
		}
		return nil
	}
	
	
	//MARK: - MKMapViewDelegate
	
	public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		if let annotation = view.annotation as? BrowseMapAnnotation {
			selectedAnnotation(annotation)
			updateAnnotationView(view, image: UIImage(named: "RestaurantPinSelected"))
		}
	}
	
	public func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
		if let _ = view.annotation as? BrowseMapAnnotation {
			selectedAnnotation(nil)
			updateAnnotationView(view, image: UIImage(named: "RestaurantPin"))
		}
	}
	
	private func selectedAnnotation(_ annotation: BrowseMapAnnotation?) {
		let restaurant = self.restaurantForID(annotation?.restaurantID ?? "")
		if let restaurant = restaurant {
			self.selectedIndex = self.restaurants.firstIndex(of: restaurant) ?? 0
		} else {
			self.selectedIndex = 0
		}
		self.selectedRestaurant = restaurant
		updateSummary()
	}
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if annotation.isEqual(mapView.userLocation) {
			let annotationView = RescountsUserAnnotationView(annotation: annotation, reuseIdentifier: "userLocation")
			return annotationView
		} else {
			var annotationView: MKAnnotationView? = nil
			if #available(iOS 11.0, *) {
				annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: kPinID, for: annotation)
			} else {
				annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: kPinID)
				if annotationView == nil {
					annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: kPinID)
				}
			}
			if let annotationView = annotationView {
				updateAnnotationView(annotationView, image: UIImage(named: "RestaurantPin"))
			}
			return annotationView
		}
	}
	
	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		if (!animated) {
			if (lastSearchCentre == nil ||
				lastSearchResultsRegion == nil ||
				(!mapView.region.intersects(lastSearchResultsRegion!)) && LocationManager.distance(from: lastSearchCentre!, to: mapView.centerCoordinate) > LocationManager.regionWidthInMetres(mapView.region) / 10)
			{
				browseDelegate?.performSearch(location: mapView.centerCoordinate, loadingMore: false)
			}
		}
	}
	
	func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
		// Only called on iOS 12 onwards, but regionDidChangeAnimated is also called so it's not needed
	}
	
	
	// MARK: - Coordinate Helpers
	
	// Adapted from: https://stackoverflow.com/questions/10559219/determining-midpoint-between-2-cooridinates
	func degreeToRadian(_ angle:CLLocationDegrees) -> CGFloat {
		return (  (CGFloat(angle)) / 180.0 * CGFloat.pi  )
	}
	
	func radianToDegree(_ radian:CGFloat) -> CLLocationDegrees {
		return CLLocationDegrees(  radian * CGFloat(180.0 / CGFloat.pi)  )
	}
	
	func middlePointOfListMarkers(_ listCoords: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
		
		var x = 0.0 as CGFloat
		var y = 0.0 as CGFloat
		var z = 0.0 as CGFloat
		
		for coordinate in listCoords {
			let lat:CGFloat = degreeToRadian(coordinate.latitude)
			let lon:CGFloat = degreeToRadian(coordinate.longitude)
			x = x + cos(lat) * cos(lon)
			y = y + cos(lat) * sin(lon)
			z = z + sin(lat)
		}
		
		x = x/CGFloat(listCoords.count)
		y = y/CGFloat(listCoords.count)
		z = z/CGFloat(listCoords.count)
		
		let resultLon: CGFloat = atan2(y, x)
		let resultHyp: CGFloat = sqrt(x*x+y*y)
		let resultLat:CGFloat = atan2(z, resultHyp)
		
		let newLat = radianToDegree(resultLat)
		let newLon = radianToDegree(resultLon)
		let result:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: newLat, longitude: newLon)
		
		return result
		
	}
}

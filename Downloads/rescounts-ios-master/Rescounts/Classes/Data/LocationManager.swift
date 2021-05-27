//
//  LocationManager.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-15.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

public enum LocationCallbackResult : Int {
	case Success = 0  // A location is ready
	case AuthError    // We do not have location permission
	case Duplicate    // Someone else is already waiting on a location result
}

class LocationManager: NSObject, CLLocationManagerDelegate {

	private static let sharedInstance = LocationManager()
	
	private var lastKnownLocation = CLLocationCoordinate2D(latitude: 43.659097, longitude: -79.382042)
	private let gpsManager = CLLocationManager()
	
	typealias LocationCallback = (LocationCallbackResult) -> Void
	private var callback: LocationCallback? = nil

	
	// MARK: - Initialization
	
	private func ensureSetup() {
		if (gpsManager.delegate == nil) {
			gpsManager.delegate = self
			
			loadLastKnownLocation()
		}
		
		switch CLLocationManager.authorizationStatus() {
			case .notDetermined:
				gpsManager.requestWhenInUseAuthorization()
				break
			case .authorizedWhenInUse:
				break
			default:
				break
		}
	}
	
	
	// MARK: - Public Methods
	
	public static func beginTracking(callback: LocationCallback?) {
		sharedInstance.addCallback(callback)
		sharedInstance.ensureSetup()
		sharedInstance.gpsManager.stopUpdatingLocation()
		sharedInstance.gpsManager.startUpdatingLocation()
		
		// TODO: this should take in a callback to report how auth went so the current VC can show something appropriate if necessary
	}
	
	public static func currentLocation() -> CLLocationCoordinate2D {
		return sharedInstance.lastKnownLocation
	}
	
	// Returns distance in metres between 2 locations
	public static func distance(from loc1: CLLocationCoordinate2D, to loc2: CLLocationCoordinate2D) -> CLLocationDistance {
		return CLLocation(latitude: loc1.latitude, longitude: loc1.longitude).distance(from:
			CLLocation(latitude: loc2.latitude, longitude: loc2.longitude))
	}
	
	// Returns distance in metres from user location to 'other'
	public static func distanceToLocation(_ other: CLLocationCoordinate2D) -> CLLocationDistance {
		let curLoc = currentLocation()
		return distance(from: curLoc, to: other)
	}
	
	// Returns String representation of distance from user location to 'other'
	public static func displayDistanceToLocation(_ other: CLLocationCoordinate2D) -> String {
		// TODO: use a global user settings to display miles instead of km
		
		let distance = distanceToLocation(other)
		
		if (distance > 999) {
			return String(format: "%.1f km", distance / 1000.0)
		} else {
			return String(format: "%.0f m", distance)
		}
	}
	
	// Taken from: https://stackoverflow.com/questions/13968030/ios-how-to-calculate-size-width-to-meters-in-every-regionany-location-and-any-z
	public static func regionWidthInMetres(_ region: MKCoordinateRegion) -> CLLocationDistance {
//		let deltaLatitude = region.span.latitudeDelta
		let deltaLongitude = region.span.longitudeDelta
		let latitudeCircumference = 40075160 * cos(region.center.latitude * Double.pi / 180)
//		NSLog(@"x: %f; y: %f", deltaLongitude * latitudeCircumference / 360, deltaLatitude * 40008000 / 360);
		return deltaLongitude * latitudeCircumference / 360
	}
	
	
	// MARK: - Private Methods
	
	private func addCallback(_ newCallback: LocationCallback?) {
		if (callback == nil) {
			callback = newCallback
		} else {
			newCallback?(.Duplicate)
		}
	}
	
	private func callCallback(result: LocationCallbackResult) {
		callback?(result)
		callback = nil
	}
	//Location flag
	private func triggerAFreshSearch(){
		//if I am on browseviewController, table is not activated, my new location is 1km far away from lastSearchLocation
		if let wd = UIApplication.shared.delegate?.window {
			var vc = wd!.rootViewController
			if (vc is UINavigationController) {
				vc = (vc as! UINavigationController).visibleViewController
			}
			if(vc is BrowseViewController) {
				// I am on BrowseViewController
				if ((OrderManager.main.currentTable == nil) && (LocationManager.distance(from: lastKnownLocation, to: loadLastSearchLocation() ) > 1000)) {
					print(lastKnownLocation)
					print(loadLastSearchLocation())
					//perform a search with
					let center = CLLocationCoordinate2D(latitude: lastKnownLocation.latitude, longitude: lastKnownLocation.longitude)
					let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
					(vc as? BrowseViewController)?.map.setRegion(region, animated: true)
				}
				
			}
		}
	}
	
	
	// MARK: - Last Known Location
	
	private func loadLastSearchLocation() -> CLLocationCoordinate2D{
		if let userLoc = UserDefaults.standard.dictionary(forKey: Constants.UserDefaults.lastSearchLocation ) {
			return  CLLocationCoordinate2DMake(userLoc["lat"]  as? CLLocationDegrees ?? 0.0,
														   userLoc["long"] as? CLLocationDegrees ?? 0.0)
		} else {
			return lastKnownLocation
		}
	}
	
	private func loadLastKnownLocation() {
		if let userLoc = UserDefaults.standard.dictionary(forKey: Constants.UserDefaults.userLocation) {
			lastKnownLocation = CLLocationCoordinate2DMake(userLoc["lat"]  as? CLLocationDegrees ?? 0.0,
														   userLoc["long"] as? CLLocationDegrees ?? 0.0)
		}
	}
	
	private func saveLastKnownLocation() {
		UserDefaults.standard.set(["lat": lastKnownLocation.latitude, "long": lastKnownLocation.longitude], forKey: Constants.UserDefaults.userLocation)
		UserDefaults.standard.synchronize()
	}
	
	
	// MARK: - CLLocationManagerDelegate
	
	public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		NSLog("LOCATION\t Changed auth status to: \(status)")
		
		if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
			LocationManager.beginTracking(callback: nil)
		} else if (CLLocationManager.authorizationStatus() == .denied) {
			callCallback(result: .AuthError)
		}
	}
//location flag
	public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		NSLog("LOCATION\t New locations: \(locations)")
		
		if let loc = locations.first {
			lastKnownLocation = loc.coordinate
			saveLastKnownLocation()
			triggerAFreshSearch()
			callCallback(result: .Success)
		}
	}
}

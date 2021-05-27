//
//  MKCoordinateRegion+Helpers.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-09-16.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//
//	Taken form:
//		https://github.com/fluidsonic/JetPack/blob/master/Sources/Extensions/MapKit/MKCoordinateRegion.swift

import CoreLocation
import MapKit


public extension MKCoordinateRegion {
	
	init(center: CLLocationCoordinate2D, latitudalDistance: CLLocationDistance, longitudalDistance: CLLocationDistance) {
		self = MKCoordinateRegionMakeWithDistance(center, latitudalDistance, longitudalDistance)
	}
	
	
	init(north: CLLocationDegrees, east: CLLocationDegrees, south: CLLocationDegrees, west: CLLocationDegrees) {
		self.init()
		span = MKCoordinateSpan(latitudeDelta: north - south, longitudeDelta: east - west)
		center = CLLocationCoordinate2D(latitude: north - (span.latitudeDelta / 2), longitude: west + (span.longitudeDelta / 2))
	}
	
	
	init? <Coordinates: Sequence> (fittingCoordinates coordinates: Coordinates) where Coordinates.Iterator.Element == CLLocationCoordinate2D {
		var minLatitude = CLLocationDegrees(90)
		var maxLatitude = CLLocationDegrees(-90)
		var minLongitude = CLLocationDegrees(180)
		var maxLongitude = CLLocationDegrees(-180)
		
		var hasCoordinates = false
		for coordinate in coordinates {
			hasCoordinates = true
			
			if coordinate.latitude < minLatitude {
				minLatitude = coordinate.latitude
			}
			if coordinate.latitude > maxLatitude {
				maxLatitude = coordinate.latitude
			}
			if coordinate.longitude < minLongitude {
				minLongitude = coordinate.longitude
			}
			if coordinate.longitude > maxLongitude {
				maxLongitude = coordinate.longitude
			}
		}
		
		if !hasCoordinates {
			return nil
		}
		
		self.init()
		span = MKCoordinateSpan(latitudeDelta: maxLatitude - minLatitude, longitudeDelta: maxLongitude - minLongitude)
		center = CLLocationCoordinate2D(latitude: minLatitude + (span.latitudeDelta / 2), longitude: minLongitude + (span.longitudeDelta / 2))
	}
	
	
	
	func contains(_ point: CLLocationCoordinate2D) -> Bool {
		guard abs(point.latitude - center.latitude) >= span.latitudeDelta else {
			return false
		}
		guard abs(point.longitude - center.longitude) >= span.longitudeDelta else {
			return false
		}
		
		return true
	}
	
	
	
	func contains(_ region: MKCoordinateRegion) -> Bool {
		guard span.latitudeDelta - region.span.latitudeDelta - abs(center.latitude - region.center.latitude) >= 0 else {
			return false
		}
		guard span.longitudeDelta - region.span.longitudeDelta - abs(center.longitude - region.center.longitude) >= 0 else {
			return false
		}
		
		return true
	}
	
	
	var east: CLLocationDegrees {
		return center.longitude + (span.longitudeDelta / 2)
	}
	
	
	mutating func insetBy(latitudinally latitudeDelta: Double, longitudinally longitudeDelta: Double = 0) {
		self = insettedBy(latitudinally: latitudeDelta, longitudinally: longitudeDelta)
	}
	
	
	mutating func insetBy(latitudinally longitudeDelta: Double) {
		insetBy(latitudinally: 0, longitudinally: longitudeDelta)
	}
	
	
	
	func insettedBy(latitudinally latitudeDelta: Double, longitudinally longitudeDelta: Double = 0) -> MKCoordinateRegion {
		var region = self
		region.span.latitudeDelta += latitudeDelta
		region.span.longitudeDelta += longitudeDelta
		return region
	}
	
	
	
	func insettedBy(longitudinally longitudeDelta: Double) -> MKCoordinateRegion {
		return insettedBy(latitudinally: 0, longitudinally: longitudeDelta)
	}
	
	
	
	func intersectedWith(_ region: MKCoordinateRegion) -> MKCoordinateRegion? {
		guard intersects(region) else {
			return nil
		}
		
		return MKCoordinateRegion(
			north: min(self.north, region.north),
			east:  min(self.east,  region.east),
			south: max(self.south, region.south),
			west:  max(self.west,  region.west)
		)
	}
	
	
	
	func intersects(_ region: MKCoordinateRegion) -> Bool {
		if region.north < south {
			return false
		}
		if north < region.south {
			return false
		}
		if east < region.west {
			return false
		}
		if region.east < west {
			return false
		}
		
		return true
	}
	
	
	var north: CLLocationDegrees {
		return center.latitude + (span.latitudeDelta / 2)
	}
	
	
	var northEast: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: north, longitude: east)
	}
	
	
	var northWest: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: north, longitude: west)
	}
	
	
	mutating func scaleBy(_ scale: Double) {
		scaleBy(latitudinally: scale, longitudinally: scale)
	}
	
	
	mutating func scaleBy(latitudinally latitudalScale: Double, longitudinally longitudalScale: Double = 1) {
		self = scaledBy(latitudinally: latitudalScale, longitudinally: longitudalScale)
	}
	
	
	mutating func scaleBy(longitudinally longitudalScale: Double) {
		scaleBy(latitudinally: 1, longitudinally: longitudalScale)
	}
	
	
	
	func scaledBy(_ scale: Double) -> MKCoordinateRegion {
		return scaledBy(latitudinally: scale, longitudinally: scale)
	}
	
	
	
	func scaledBy(latitudinally latitudalScale: Double, longitudinally longitudalScale: Double = 1) -> MKCoordinateRegion {
		return insettedBy(latitudinally: (span.latitudeDelta / 2) * latitudalScale, longitudinally: (span.longitudeDelta / 2) * longitudalScale)
	}
	
	
	
	func scaledBy(longitudinally: Double) -> MKCoordinateRegion {
		return scaledBy(latitudinally: 1, longitudinally: longitudinally)
	}
	
	
	var south: CLLocationDegrees {
		return center.latitude - (span.latitudeDelta / 2)
	}
	
	
	var southEast: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: south, longitude: east)
	}
	
	
	var southWest: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: south, longitude: west)
	}
	
	
	var west: CLLocationDegrees {
		return center.longitude - (span.longitudeDelta / 2)
	}
	
	
	static let world: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(), span: MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360))
}

//extension MKCoordinateSpan: Equatable {
//
//	public static func == (a: MKCoordinateSpan, b: MKCoordinateSpan) -> Bool {
//		return a.latitudeDelta == b.latitudeDelta && a.longitudeDelta == b.longitudeDelta
//	}
//}
//
//extension MKCoordinateRegion: Equatable {
//
//	public static func == (a: MKCoordinateRegion, b: MKCoordinateRegion) -> Bool {
//		return a.center == b.center && a.span == b.span
//	}
//}

//
//  MapViewController.swift
//  PinFood
//
//  Created by Admin on 9/6/18.
//  Copyright © 2018 mariamelnezamy. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController , MKMapViewDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    var restaurant:Restaurant!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Convert address to coordinate and annotate it on map
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(restaurant.location, completionHandler: {
            placemarks, error in
            if error != nil {
                print(error!)
                return
            }
            if let placemarks = placemarks {
                
                
                // Get the first placemark
                let placemark = placemarks[0]
                
                
                // Add annotation
                let annotation = MKPointAnnotation()
                annotation.title = self.restaurant.name
                annotation.subtitle = self.restaurant.type
                
                if let location = placemark.location {
                    annotation.coordinate = location.coordinate
                    
                    
                    // Display the annotation
                    self.mapView.showAnnotations([annotation], animated: true)
                    self.mapView.selectAnnotation(annotation, animated: true)
                    
                    
                    
                     // Set the zoom level
                     let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 250, 250)
                     self.mapView.setRegion(region, animated: false)
 
                }
            }
        })
        
        
   
        mapView.delegate = self
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsTraffic = true
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) ->
        MKAnnotationView? {
            let identifier = "MyPin"
            if annotation.isKind(of: MKUserLocation.self) {
                return nil
            }
            // Reuse the annotation if possible
            var annotationView:MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as?
            MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            }
            let leftIconView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 53, height: 53))
            leftIconView.image = UIImage(named: restaurant.image)
            annotationView?.leftCalloutAccessoryView = leftIconView
            return annotationView
    }

}

//
//  MapViewController.swift
//  Project
//
//  Created by Admin on 10/10/18.
//  Copyright © 2018 mariamelnezamy. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController , MKMapViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

       
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showMap))
        self.mapView.addGestureRecognizer(tapGestureRecognizer)
        
        mapView.delegate = self
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsTraffic = true
    }

  
    @IBOutlet var mapView: MKMapView!
    
    
    func showMap() {
        performSegue(withIdentifier: "showMap", sender: self)
    }

}

//
//  DetailsOfViewController2.swift
//  PinFood
//
//  Created by Admin on 8/30/18.
//  Copyright © 2018 mariamelnezamy. All rights reserved.
//

import UIKit
import MapKit


class DetailsOfViewController2: UIViewController ,UITableViewDelegate,UITableViewDataSource , MKMapViewDelegate  {
    
    
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var tableView:UITableView!
    
    @IBOutlet weak var restaurantImageView: UIImageView!
    
    
    
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
                
            
        
                /*
                    // Set the zoom level
                    let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 250, 250)
                    self.mapView.setRegion(region, animated: false)
              */      
                }
            }
        })
           
                    
       
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showMap))
        self.mapView.addGestureRecognizer(tapGestureRecognizer)
        
        mapView.delegate = self
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsTraffic = true
        
        restaurantImageView.image = UIImage(named:restaurant.image)!

        
       
       // to calculate the cell's size ( Self Sizing Cells )
       
        tableView.estimatedRowHeight = 36.0
        tableView.rowHeight = UITableViewAutomaticDimension

        
        // to show name of restuarant in navigation bar
        
        title = restaurant.name
        
        
       
      //  This will chage the table background to light gray
 
        
        tableView.backgroundColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue:240.0/255.0, alpha: 0.2)


    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showReview" {
            let destinationController = segue.destination as! ReviewViewController
            destinationController.restaurant = restaurant
        } else if segue.identifier == "showMap" {
            let destinationController = segue.destination as! MapViewController
            destinationController.restaurant = restaurant
        }
    }
    
    
    
    
    
    
    
    
    func showMap() {
        performSegue(withIdentifier: "showMap", sender: self)
    }
  
    
    @IBAction func close(segue:UIStoryboardSegue) {
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for:
                indexPath) as! RestaurantDetailsTableViewCell
        
        
        switch indexPath.row {
        case 0:
            cell.fieldLabel.text = "Name"
            cell.valueLabel.text = restaurant.name
        case 1:
            cell.fieldLabel.text = "Type"
            cell.valueLabel.text = restaurant.type
        case 2:
            cell.fieldLabel.text = "Location"
            cell.valueLabel.text = restaurant.location
        case 3:
            cell.fieldLabel.text = "Been here"
            cell.valueLabel.text = (restaurant.isVisited) ? "Yes, I've been here before. \(restaurant.rating)" : "No"
        default:
            cell.fieldLabel.text = ""
            cell.valueLabel.text = ""
        }
        
        cell.backgroundColor = UIColor.clear
        
        
     
            return cell
    
    }
    @IBAction func ratingButtonTapped(segue: UIStoryboardSegue) {
        
        if let rating = segue.identifier {
            restaurant.isVisited = true
            switch rating {
            case "great": restaurant.rating = "Absolutely love it! Must try."
            case "good": restaurant.rating = "Pretty good."
            case "dislike": restaurant.rating = "I don't like it."
            default: break
            }
        }
        tableView.reloadData()
        
        
        
    }
 
    
    
    

}

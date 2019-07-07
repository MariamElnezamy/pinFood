//
//  RestaurantTableViewController.swift
//  PinFood
//
//  Created by Admin on 8/28/18.
//  Copyright © 2018 mariamelnezamy. All rights reserved.
//

import UIKit

class RestaurantTableViewController: UITableViewController {
    
    var Restaurants:[Restaurant] = [
        Restaurant(name: "Cafe Deadend", type: "Coffee & Tea Shop", phone: "232-923423", location: "G/F,72 Po Hing Fong, Sheung Wan, Hong Kong", image:"cafedeadend.jpg", isVisited: false),
        Restaurant(name: "Homei", type: "Cafe", phone: "348-233423", location: "Shop B, G/F, 22-24A Tai Ping San Street SOHO, Sheung Wan, Hong Kong" ,image:"homei.jpg", isVisited: false),
        Restaurant(name: "Teakha", type: "Tea House", phone: "354-243523", location: "Shop B, 18 Tai Ping Shan Road SOHO, Sheung Wan, Hong Kong", image:"teakha.jpg", isVisited: false),
        Restaurant(name: "Cafe loisl", type: "Austrian / Causual Drink", phone: "453-333423", location : "Shop B, 20 Tai Ping Shan Road SOHO, Sheung Wan, Hong Kong", image: "cafeloisl.jpg", isVisited: false),
        Restaurant(name: "Petite Oyster", type: "French", phone: "983-284334", location: "24 Tai Ping Shan Road SOHO, Sheung Wan, Hong Kong", image:"petiteoyster.jpg", isVisited: false),
        Restaurant(name: "For Kee Restaurant", type: "Bakery", phone: "232-434222", location: "Shop JK.,200 Hollywood Road, SOHO, Sheung Wan, Hong Kong",image: "forkeerestaurant.jpg", isVisited: false),
        Restaurant(name: "Po's Atelier", type: "Bakery", phone: "234-834322", location: "G/F, 62 Po Hing Fong, Sheung Wan, Hong Kong", image: "posatelier.jpg",isVisited: false),
        Restaurant(name: "Bourke Street Backery", type: "Chocolate", phone: "982-434343", location: "633Bourke St Sydney New South Wales 2010 Surry Hills", image:
                "bourkestreetbakery.jpg", isVisited: false),
        Restaurant(name: "Haigh's Chocolate", type: "Cafe", phone: "734-232323", location: "412-414 George St Sydney New South Wales", image:"haighschocolate.jpg", isVisited: false),
        Restaurant(name: "Palomino Espresso", type: "American / Seafood", phone: "872-734343", location:"Shop 1 61 York St Sydney New South Wales", image:"palominoespresso.jpg", isVisited: false),
        Restaurant(name: "Upstate", type: "American", phone: "343-233221", location: "95 1st Ave NewYork, NY 10003", image: "upstate.jpg", isVisited: false),
        Restaurant(name: "Traif", type: "American", phone: "985-723623", location: "229 S 4th St Brooklyn, NY 11211", image: "traif.jpg", isVisited: false),
        Restaurant(name: "Graham Avenue Meats", type: "Breakfast & Brunch",phone: "455-232345", location: "445 Graham Ave Brooklyn, NY 11211", image:"grahamavenuemeats.jpg", isVisited: false),
        Restaurant(name: "Waffle & Wolf", type: "Coffee & Tea", phone: "434-232322", location: "413 Graham Ave Brooklyn, NY 11211", image: "wafflewolf.jpg",isVisited: false),
        Restaurant(name: "Five Leaves", type: "Coffee & Tea", phone: "343-234553", location: "18 Bedford Ave Brooklyn, NY 11222", image: "fiveleaves.jpg",isVisited: false),
        Restaurant(name: "Cafe Lore", type: "Latin American", phone: "342-455433", location: "Sunset Park 4601 4th Ave Brooklyn, NY 11220", image:"cafelore.jpg", isVisited: false),
        Restaurant(name: "Confessional", type: "Spanish", phone: "643-332323", location: "308 E 6th St New York, NY 10003", image: "confessional.jpg", isVisited:false),
        Restaurant(name: "Five Leaves", type: "Coffee & Tea", phone: "343-234553", location: "18 Bedford Ave Brooklyn, NY 11222", image: "fiveleaves.jpg",isVisited: false),
        Restaurant(name: "Cafe Lore", type: "Latin American", phone: "342-455433", location: "Sunset Park 4601 4th Ave Brooklyn, NY 11220", image:"cafelore.jpg", isVisited: false),
        Restaurant(name: "Confessional", type: "Spanish", phone: "643-332323", location: "308 E 6th St New York, NY 10003", image: "confessional.jpg", isVisited:false),
        Restaurant(name: "Barrafina", type: "Spanish", phone: "542-343434", location: "54 Frith Street London W1D 4SL United Kingdom", image: "barrafina.jpg",isVisited: false),
        Restaurant(name: "Donostia", type: "Spanish", phone: "722-232323", location: "10 Seymour Place London W1H 7ND United Kingdom", image: "donostia.jpg",isVisited: false),
        Restaurant(name: "Royal Oak", type: "British", phone: "343-988834", location: "2 Regency Street London SW1P 4BZ United Kingdom", image: "royaloak.jpg",isVisited: false),
        Restaurant(name: "CASK Pub and Kitchen", type: "Thai", phone: "432-344050", location: "22 Charlwood Street London SW1V 2DY Pimlico", image: "caskpubkitchen.jpg", isVisited: false) ]
    
    
    
    
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell:
        UITableViewCell, forRowAt indexPath: IndexPath) {
        // Define the initial state (Before the animation)
        cell.alpha = 0
        // Define the final state (After the animation)
        UIView.animate(withDuration: 1.0, animations: { cell.alpha = 1 })
        
        // Define the initial state (Before the animation)
        let rotationAngleInRadians = 90.0 * CGFloat(M_PI/180.0)
        let rotationTransform = CATransform3DMakeRotation(rotationAngleInRadians,
                                                          0, 0, 1)
        cell.layer.transform = rotationTransform
        // Define the final state (After the animation)
        UIView.animate(withDuration: 1.0, animations: { cell.layer.transform =
            CATransform3DIdentity })
    }

  
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(Restaurants.count)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath:
        IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RestaurantTableViewCell
        cell.nameLabel.text = Restaurants[indexPath.row].name
        cell.thumbnailImageView.image = UIImage(named: Restaurants[indexPath.row].image)
        cell.locationLabel.text = Restaurants[indexPath.row].location
        cell.typeLabel.text = Restaurants[indexPath.row].type
        cell.thumbnailImageView.layer.cornerRadius = 30
        cell.accessoryType = Restaurants[indexPath.row].isVisited ? .checkmark : .none
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        
        if editingStyle == .delete { self.Restaurants.remove(at: indexPath.row) }
        
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        
        // Delete button
        
        
        let deleteAction = UITableViewRowAction(style:UITableViewRowActionStyle.default, title: "Delete",handler: { (action,
            indexPath) -> Void in

            self.Restaurants.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            
        })
        
        
        
        // Social Sharing Button
        
      
        let shareAction = UITableViewRowAction(style:
            UITableViewRowActionStyle.default, title: "Share", handler:
        { (action,indexPath) -> Void in
                 let defaultText = "Just checking in at " + self.Restaurants[indexPath.row].name
            
            if let imageToShare = UIImage(named: self.Restaurants[indexPath.row].image)
            {
                let activityController = UIActivityViewController(activityItems:
                    [ defaultText, imageToShare ], applicationActivities: nil)
                self.present(activityController, animated: true, completion: nil)
            }
              
        })
        
        
    
        
       shareAction.backgroundColor = UIColor(colorLiteralRed: 48.0/255.0, green: 173.0/255.0, blue: 99.0/255.0, alpha: 1.0)
        deleteAction.backgroundColor = UIColor(colorLiteralRed: 202.0/255.0, green: 202.0/255.0, blue: 203.0/255.0, alpha: 1.0)
            
                return [ shareAction , deleteAction ]
        
        
    }
        
        
//    @IBAction func unwindToHomeScreen(segue:UIStoryboardSegue) { }
    
    
    
    /*
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let Alert = UIAlertController.init(title: "Message", message: "What do u want to do ?", preferredStyle: .actionSheet)
        
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        Alert.addAction(CancelAction)
        present(Alert, animated: true, completion: nil)
        
        
        
    
        
    /*    let CallActionHandler = { ( action:UIAlertAction ) -> Void in
            
            let AlertMassageInsideCall = UIAlertController(title: "Service Unavailable", message: "Sorry, the call feature is not available yet. Please retry later.", preferredStyle: .alert)
            
            AlertMassageInsideCall.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(AlertMassageInsideCall, animated: true, completion: nil)
            
        }
         
         
         let CallAction = UIAlertAction(title: "Call Now  " + "+20123456789" , style: .default, handler: CallActionHandler)
 
 */
        
     
        
        let CallActionHandler = UIAlertAction(title: "Call Now  " + "+20123456789", style: .default) { (action:UIAlertAction) in
            
            
            let AlertMassageInsideCall = UIAlertController(title: "Service Unavailable", message: "Sorry, the call feature is not available yet. Please retry later.", preferredStyle: .alert)
            
            AlertMassageInsideCall.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(AlertMassageInsideCall, animated: true, completion: nil)
            
            
        }
        
        
        
        
        
        let CheckInAction = UIAlertAction(title: "Check-in", style: .default, handler:
        {
            
            (action:UIAlertAction) -> Void in
            
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
            self.restaurantVisited[indexPath.row] = true
        })
        
        Alert.addAction(CallActionHandler)
        Alert.addAction(CheckInAction)
        
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        
        
    }
    */
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRestaurantDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! DetailsOfViewController2
                destinationController.restaurant = Restaurants[indexPath.row]
            }
        }
    }
    
   
    
 
    
    
    // Adding a Search Bar 
    
    
//    var searchController:UISearchController!
//    var searchResults:[Restaurant] = []
//    
//    override func viewDidLoad() {
//     
//     
//        searchController = UISearchController(searchResultsController: nil)
//        tableView.tableHeaderView = searchController.searchBar
//     
//     
//    }
//    
//    func filterContent(for searchText: String) {
//        searchResults = Restaurants.filter({ (restaurant) -> Bool in
//            if let name = restaurant.name {
//                let isMatch = name.localizedCaseInsensitiveContains(searchText)
//                return isMatch
//            }
//            return false
//        })
//    }
//    
//    
    
 
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}





    




//
//  CartTableViewController.swift
//  Project
//
//  Created by Admin on 9/27/18.
//  Copyright © 2018 mariamelnezamy. All rights reserved.
//

import UIKit

class CartTableViewController: UIViewController , UITableViewDataSource , UITableViewDelegate  {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var Restaurants:[Icon] = [
        Icon(name: "Cafe Deadend", price: "$ 33", Image: "cafedeadend.jpg", Description: "Cafe Deadend wzxecrvtgbhnjmksdrftghjklfghjklvbnm,mmmjkhhn jnknknkmmnjdrggimgkhih", Avg: "", Delivery: ""),
        Icon(name: "Homei", price: "$ 35", Image: "homei.jpg", Description: "Homei wzxecrvtgbhnjmksdrftghjklfghjklvbnm,mmmjkhhn jnknknkmmnjdrggimgkhih", Avg: "", Delivery: "")]
    
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Restaurants.count
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CartTableViewCell
        
        cell.ImageView.image = UIImage(named: Restaurants[indexPath.row].Image)
        cell.name.text = Restaurants[indexPath.row].name
        cell.price.text = Restaurants[indexPath.row].price
        
        return cell
    }
 
}

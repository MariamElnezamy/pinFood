//
//  CartViewController.swift
//  Project
//
//  Created by Admin on 9/26/18.
//  Copyright © 2018 mariamelnezamy. All rights reserved.
//

import UIKit

class CartTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    var Restaurants:[Icon] = [
        Icon(name: "Cafe Deadend", price: "$ 33", Image: "cafedeadend.jpg", description: "Cafe Deadend wzxecrvtgbhnjmksdrftghjklfghjklvbnm,mmmjkhhn jnknknkmmnjdrggimgkhih"),
        Icon(name: "Homei", price: "$ 35", Image: "homei.jpg", description: "Homei wzxecrvtgbhnjmksdrftghjklfghjklvbnm,mmmjkhhn jnknknkmmnjdrggimgkhih")]

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Restaurants.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath:
        IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CartTableViewCell
        
        cell.ImageView.image = UIImage(named: Restaurants[indexPath.row].Image)
        cell.name.text = Restaurants[indexPath.row].name
        cell.price.text = Restaurants[indexPath.row].price
        
        return cell

    }
    
    
   
    
      
    
    
    
    


}

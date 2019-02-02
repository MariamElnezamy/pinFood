//
//  OffersViewController.swift
//  Project
//
//  Created by Admin on 10/8/18.
//  Copyright © 2018 mariamelnezamy. All rights reserved.
//

import UIKit

class OffersViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    
    var Arr:[Offerr] = [Offerr(img: "8"),Offerr(img: "10%"),Offerr(img: "20%"),Offerr(img: "100%")]

  
    
    // MARK: - Table view data source
    
     override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return Arr.count
    }
    
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let Cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! OffersTableViewCell
        
        

        Cell.ImageView1.image = UIImage(named: Arr[indexPath.row].img!)
        
        return Cell
    }

   

}

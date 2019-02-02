//
//  FoodDetailsViewController.swift
//  Project
//
//  Created by Admin on 9/19/18.
//  Copyright © 2018 mariamelnezamy. All rights reserved.
//

import UIKit
import Photos


class FoodDetailsViewController: UIViewController  {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        x = 0

        Counter.text=String(x)
    }
    
    var x = 0
    
        var icons = Icon(name: "", price: "$55", Image: "", Description: "", Avg: "", Delivery: "")
    
    
    @IBOutlet var Description: UILabel!{
    
    
        didSet{ Description.text = icons.Description }
    
    
    }
    
    @IBOutlet var nameFood: UILabel!
    {
        didSet{ nameFood.text = icons.name }
    }
    
    @IBOutlet var ImageView: UIImageView?
        {
        didSet{ ImageView?.image = UIImage(named: icons.Image) }
        
    }
    
    
    
    @IBOutlet var price: UILabel!
        {
        didSet{ price.text = icons.price }
    }
    
    
    
    @IBOutlet var ShowView: UIView!{
    
    
        didSet{
            
            ShowView.layer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
            ShowView.layer.shadowRadius = 5
            ShowView.layer.shadowOpacity = 1
            ShowView.layer.shadowOffset = CGSize(width: 3, height: 3)
            
        }
    
    
    
    
    
    }
    
    
    
    @IBOutlet var Counter: UILabel!
    
    
    @IBAction func addBtn(_ sender: Any) {
        
        x +=  1
        Counter.text=String(x)
        
        
    
        
    }
    
    @IBAction func subtractBtn(_ sender: Any) {
        
        x -= 1
        Counter.text=String(x)
        
     
    }
    
    
    
   var icon:Icon?
    
    
    
 
    
    
    
   
    
    
    
    
    
    @IBAction func unwindToHome(_ segue: UIStoryboardSegue) {
    }
    
    

      
}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
 
    



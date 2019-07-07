//
//  Restaurant.swift
//  PinFood
//
//  Created by Admin on 9/2/18.
//  Copyright © 2018 mariamelnezamy. All rights reserved.
//

import UIKit

class Restaurant {
    
    
    var rating = ""
    

    var name = ""
    var phone = ""
    var type = ""
    var location = ""
    var image = ""
    var isVisited = false
    init(name: String, type: String, phone:String , location: String, image: String ,isVisited: Bool)
    {
        self.name = name
        self.type = type
        self.location = location
        self.image = image
        self.isVisited = isVisited
        self.phone = phone
    }
    
}

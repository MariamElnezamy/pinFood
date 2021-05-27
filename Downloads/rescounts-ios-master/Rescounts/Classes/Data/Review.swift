//
//  Review.swift
//  Rescounts
//
//  Created by Kit Xayasane on 2018-08-25.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class Review: NSObject {

    var tableID: String
    var images: [String]
    var restaurantRating: Int
    var serverRating: Int
    var reviewText: String?
    var user: User


    // MARK: - Initialization

    init(tableID: String, images: [String], restaurantRating: Int, serverRating: Int, reviewText: String?, user: User) {
        self.tableID = tableID
        self.images = images
        self.restaurantRating = restaurantRating
        self.serverRating = serverRating
        self.reviewText = reviewText
        self.user = user

        super.init()
    }
}

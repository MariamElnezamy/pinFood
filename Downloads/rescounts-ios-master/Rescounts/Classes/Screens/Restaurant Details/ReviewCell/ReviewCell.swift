//
//  ReviewCell.swift
//  Rescounts
//
//  Created by Martin Sorsok on 6/26/20.
//  Copyright © 2020 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class ReviewCell: UITableViewCell, RestaurantReviewDelegate {

    @IBOutlet weak var heightOfTableView: NSLayoutConstraint!
    
    @IBOutlet  var tableView: ReviewTableView!{
        didSet {
            
           
        }
    }
    weak public var fetchDelegate : RestaurantReviewDelegate?
    public var reviews: [RestaurantReview] = []

    var restaurant: Restaurant? {
         didSet {
            guard let restaurant = self.restaurant else {
                return
            }
            tableView.fetchDelegate = self
            tableView.reviews = restaurant.reviews
         }
     }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    // MARK: - Protocol
    func performFetch(loadingMore: Bool) {
        guard let restaurant = self.restaurant else {
                return
            }
        if !ReviewService.shouldIMakeCall() {
            print("Cancelled search: one already active.")
            return
        }
        let searchOffset = loadingMore ? restaurant.reviews.count : 0
        ReviewService.fetchReviews(restaurant: restaurant, offset:searchOffset) { (restaurantReviews : [RestaurantReview]?) in
            if let theList = restaurantReviews {
                self.restaurant?.reviews.append(contentsOf: theList)
                self.tableView.showMoreReviews(theList, loadingMore: loadingMore)
            }
        }
    }
    
    func getRestaurant() -> Restaurant {
        if let restaurant = self.restaurant {
            return restaurant
        }
        return Restaurant(json: [:])!
    }
    
    func appendReviews(theList: [RestaurantReview]) {
        self.restaurant?.reviews.append(contentsOf: theList)
    }
    
    
}

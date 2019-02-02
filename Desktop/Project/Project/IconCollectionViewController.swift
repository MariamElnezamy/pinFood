//
//  IconCollectionViewController.swift
//  Project
//
//  Created by Admin on 9/20/18.
//  Copyright © 2018 mariamelnezamy. All rights reserved.
//

import UIKit
import UserNotifications


private let reuseIdentifier = "Cell"

class IconCollectionViewController: UIViewController , UICollectionViewDataSource , UICollectionViewDelegate ,UIScrollViewDelegate
{
   
    
    @IBAction func MyNotifications(_ sender: Any) {
        
        
        let tableNotifications = UNMutableNotificationContent()
        tableNotifications.title = "New Notification"
        tableNotifications.body = "See our menu , there are a new delicious meals"
        tableNotifications.sound = UNNotificationSound.default()
       
        
        let Trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        
        
        let request = UNNotificationRequest(identifier: "Food Notification", content: tableNotifications, trigger: Trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)


        
    }

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound], completionHandler: {didAlow,error in })
         
        
        
        
        
        
        sideMenuButton()
        
        
        

        searchController = UISearchController(searchResultsController: nil)

        
        pageControler.numberOfPages = Images.count
        for index in 0..<Images.count{
            frame.origin.x = ScrollView.frame.size.width * CGFloat(index)
            frame.size = ScrollView.frame.size
            
            let ImgView = UIImageView(frame: frame)
            ImgView.image = UIImage(named: Images[index])
            self.ScrollView.addSubview(ImgView)
        
        }
        
        ScrollView.contentSize = CGSize(width: (ScrollView.frame.size.width * CGFloat(Images.count)), height: (ScrollView.frame.size.height ))
        
        
        ScrollView.delegate = self

    
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = ScrollView.contentOffset.x / ScrollView.frame.size.width
        pageControler.currentPage = Int(pageNumber)
        
        ScrollView.contentOffset.y = 0
      
    }
    

    

    var searchController:UISearchController!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var collectionView: UICollectionView!
    
    var Restaurants:[Icon] = [
        Icon(name: "Cafe Deadend", price: "$ 33", Image: "cafedeadend.jpg", Description: "Consists of zxcvbnm,. dfghjkfghj knbgfc ssxghjmkjhbfdx zxcvbnm,. dfghjkfghj knbgfc ssxghjmkjhbfdxzxcvbnm,. dfghjkfghj knbgfc ssxghjmkjhbfdxzxcvbnm,. dfghjkfghj knbgfc ssxghjmkjhbfdx", Avg: "20 mins", Delivery: "FREE"),
        Icon(name: "Homei", price: "$ 35", Image: "homei.jpg", Description: "Consists of zxcvbnm,. dfghjkfghj knbgfc ssxghjmkjhbfdx zxcvbnm,. dfghjkfghj knbgfc ssxghjmkjhbfdxzxcvbnm,. dfghjkfghj knbgfc ssxghjmkjhbfdxzxcvbnm,. dfghjkfghj knbgfc ssxghjmkjhbfdx", Avg: "50 mins", Delivery: "5 $"),
        Icon(name: "Teakha", price: "$ 33", Image: "teakha.jpg", Description: "Consists of zxcvbnm,. dfghjkfghj knbgfc ssxghjmkjhbfdx zxcvbnm,. dfghjkfghj knbgfc ssxghjmkjhbfdxzxcvbnm,. dfghjkfghj knbgfc ssxghjmkjhbfdxzxcvbnm,. dfghjkfghj knbgfc ssxghjmkjhbfdx", Avg: "37 mins", Delivery: "FREE"),
        Icon(name: "Petite Oyster", price: "$ 33", Image: "petiteoyster.jpg", Description: "Consists of zxcvbnm,. dfghjkfghj knbgfc ssxghjmkjhbfdx zxcvbnm,. dfghjkfghj knbgfc ssxghjmkjhbfdxzxcvbnm,. dfghjkfghj knbgfc ssxghjmkjhbfdxzxcvbnm,. dfghjkfghj knbgfc ssxghjmkjhbfdx", Avg: "33 mins", Delivery: "20 $"),
        Icon(name: "Haigh's Chocolate", price: "$ 33", Image: "haighschocolate.jpg", Description: "Consists of zxcvbnm,. dfghjkfghj knbgfc ssxghjmkjhbfdx zxcvbnm,. dfghjkfghj knbgfc ssxghjmkjhbfdxzxcvbnm,. dfghjkfghj knbgfc ssxghjmkjhbfdxzxcvbnm,. dfghjkfghj knbgfc ssxghjmkjhbfdx.", Avg: "13 mins", Delivery: "FREE"),
        Icon(name: "Traif", price: "$ 33", Image: "traif.jpg", Description: "Consists of zxcvbnm,. dfghjkfghj knbgfc ssxghjmkjhbfdx zxcvbnm,. dfghjkfghj knbgfc ssxghjmkjhbfdxzxcvbnm,. dfghjkfghj knbgfc ssxghjmkjhbfdxzxcvbnm,. dfghjkfghj knbgfc ssxghjmkjhbfdx", Avg: "44 mins", Delivery: "FREE")]
    
    
    

    
    
    
    
    
    // MARK: UICollectionViewDataSource
    
     func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return Restaurants.count
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        
        
        cell.foodName.text! = Restaurants[indexPath.row].name
        cell.Image.image! = UIImage(named: Restaurants[indexPath.row].Image)!
        cell.price.text! = Restaurants[indexPath.row].price
        cell.Avg.text! = Restaurants[indexPath.row].Avg
        cell.Delivery.text! = Restaurants[indexPath.row].Delivery

        
        
        return cell
    }
    
    
    // Push Data
    

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main" , bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FoodDetailsViewController") as! FoodDetailsViewController
        
        vc.icons.name = Restaurants[indexPath.row].name
        vc.icons.Image = Restaurants[indexPath.row].Image
        vc.icons.Description = Restaurants[indexPath.row].Description
        vc.icons.price = Restaurants[indexPath.row].price
     
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        
        
        
        
        
        
        
    }
  
    
    //MARK:- SWRevealViewController
    func sideMenuButton()
    {
        //SideMenu Code
        if revealViewController() != nil {
            
            revealViewController().rightViewRevealWidth = 280
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
  
    
    
    // Pager

    
    var Images: [String] = ["1","2","3"]
    
    
    @IBOutlet var ScrollView: UIScrollView!
   
    @IBOutlet var pageControler: UIPageControl!
    
    
    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    
    
    
}

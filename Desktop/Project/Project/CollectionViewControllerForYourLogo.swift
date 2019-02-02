//
//  YourLogoCollectionViewController.swift
//  Project
//
//  Created by Admin on 9/23/18.
//  Copyright © 2018 mariamelnezamy. All rights reserved.
//

import UIKit

private let reuseIdentifier = "cell"

class YourLogoCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    
    var Restaurants:[Icon] = [
        Icon(name: "Cafe Deadend", price: "$ 33", Image: "cafedeadend.jpg", description: "Cafe Deadend wzxecrvtgbhnjmksdrftghjklfghjklvbnm,mmmjkhhn jnknknkmmnjdrggimgkhih"),
        Icon(name: "Homei", price: "$ 35", Image: "homei.jpg", description: "Homei wzxecrvtgbhnjmksdrftghjklfghjklvbnm,mmmjkhhn jnknknkmmnjdrggimgkhih"),
        Icon(name: "Teakha", price: "$ 33", Image: "teakha.jpg", description: "Teakha wzxecrvtgbhnjmksdrftghjklfghjklvbnm,mmmjkhhn jnknknkmmnjdrggimgkhih"),
        Icon(name: "Petite Oyster", price: "$ 33", Image: "petiteoyster.jpg", description: "Petite Oyster wzxecrvtgbhnjmksdrftghjklfghjklvbnm,mmmjkhhn jnknknkmmnjdrggimgkhih"),
        Icon(name: "Haigh's Chocolate", price: "$ 33", Image: "haighschocolate.jpg", description: "Haigh's Chocolate wzxecrvtgbhnjmksdrftghjklfghjklvbnm,mmmjkhhn jnknknkmmnjdrggimgkhih"),
        Icon(name: "Traif", price: "$ 33", Image: "traif.jpg", description: "Traif wzxecrvtgbhnjmksdrftghjklfghjklvbnm,mmmjkhhn jnknknkmmnjdrggimgkhih")]
    
    
    
   

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return Restaurants.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        
        
        cell.foodName.text = Restaurants[indexPath.row].name
        cell.Image.image = UIImage(named: Restaurants[indexPath.row].Image)
        cell.price.text = Restaurants[indexPath.row].price
        

    
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout
//        collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath:
//        IndexPath) -> CGSize {
//        let sideSize = (traitCollection.horizontalSizeClass == .compact &&
//            traitCollection.verticalSizeClass == .regular) ? 80.0 : 128.0
//        return CGSize(width: sideSize, height: sideSize)
//    }
//    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

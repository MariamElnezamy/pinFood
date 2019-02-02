//
//  MessagesTableViewController.swift
//  Project
//
//  Created by Admin on 10/7/18.
//  Copyright © 2018 mariamelnezamy. All rights reserved.
//

import UIKit

class MessagesTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

       
    }

    
    
    var arr:[MessageIcon] = [MessageIcon(img: "Selena Gomez", name: "Selena Gomez"),MessageIcon(img: "Angelina jolie", name: "Angelina jolie"),MessageIcon(img: "Deepika Padukone", name: "Deepika Padukone"),MessageIcon(img: "Priyanka", name: "Priyanka"),MessageIcon(img: "Jennifer Lawrence", name: "Jennifer Lawrence"),MessageIcon(img: "Sofia boutella", name: "Sofia boutella"),MessageIcon(img: "Rihanna", name: "Rihanna"),MessageIcon(img: "Adele", name: "Adele"),MessageIcon(img: "Ashley Tisdale", name: "Ashley Tisdale"),MessageIcon(img: "Shakira", name: "Shakira")]
    
    
    
    
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arr.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MessageTableViewCell
        
        cell.name.text! = arr[indexPath.row].name!
        cell.Img.image = UIImage(named: arr[indexPath.row].img!)
        cell.Img.layer.cornerRadius = 40

        

        return cell
    }
 

}

//
//  HoursCell.swift
//  Rescounts
//
//  Created by Martin Sorsok on 6/26/20.
//  Copyright © 2020 ZeMind Game Studio Ltd. All rights reserved.
//


import UIKit

class HoursCell: UITableViewCell {

    @IBOutlet weak var details: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    
    @IBOutlet weak var hoursLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    let kDetailFontSize: CGFloat = 16

    var restaurant: Restaurant? {
         didSet {
             setupDetails()
         }
     }
    private func setupDetails() {
        details.backgroundColor = .white
        guard let restaurant = self.restaurant else {
            return
        }






        let hours: (days: String, hours: String) = HoursManager.allDaysAsString(restaurant.hours)

        if hours.days != "" {
            setupLabel(daysLabel,  text: hours.days,  font: UIFont.lightRescounts(ofSize: kDetailFontSize), lines: 0, parent: details)
        } else {
            let days = "Mon:\nTues:\nWed:\nThurs:\nFri:\nSat:\nSun:"
              setupLabel(daysLabel,  text: days,  font: UIFont.lightRescounts(ofSize: kDetailFontSize), lines: 0, parent: details)
        }
        if hours.hours != "" {
               setupLabel(hoursLabel, text: hours.hours, font: UIFont.lightRescounts(ofSize: kDetailFontSize), lines: 0, parent: details)
        } else {
            let hours = "Closed\nClosed\nClosed\nClosed\nClosed\nClosed\nClosed"
                setupLabel(hoursLabel, text: hours, font: UIFont.lightRescounts(ofSize: kDetailFontSize), lines: 0, parent: details)
        }

    }
    
    private func setupLabel(_ label: UILabel, text: String, font: UIFont, colour: UIColor = .dark, alignment: NSTextAlignment = .left, lines: Int = 1, parent: UIView? = nil) {
        label.text = text
        label.font = font
        label.textAlignment = alignment
        label.textColor = colour
        label.numberOfLines = lines
        parent!.addSubview(label)
    }
}

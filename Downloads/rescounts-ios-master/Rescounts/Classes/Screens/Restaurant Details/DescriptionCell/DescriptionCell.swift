//
//  DescriptionCell.swift
//  Rescounts
//
//  Created by Martin Sorsok on 6/26/20.
//  Copyright © 2020 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class DescriptionCell: UITableViewCell {

    @IBOutlet weak var details: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
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

        descriptionLabel.font = UIFont.lightRescounts(ofSize: kDetailFontSize)
        descriptionLabel.text = restaurant.restaurantDescription
//
//        setupLabel(websiteLabel, text: restaurant.website, font: UIFont.lightRescounts(ofSize: kDetailFontSize), colour: .primary, lines: 0, parent: details)
//
//        let websiteTap = UITapGestureRecognizer(target: self, action: #selector(websiteOnClick))
//        websiteLabel.isUserInteractionEnabled = true
//        websiteLabel.addGestureRecognizer(websiteTap)
//
//        setupLabel(eventAndEntertainmentTitle, text: l10n("events&ent").uppercased(), font: UIFont.lightRescounts(ofSize: kFontSize),colour: .dark, parent: details )
//        setupLabel(eventAndEntertainmentLabel, text: restaurant.eventsAndEntertainment, font: UIFont.lightRescounts(ofSize: kDetailFontSize), lines: 0, parent: details)
//
//        setupLabel(holidayHourTitle, text: l10n("holidayHours").uppercased(), font: UIFont.lightRescounts(ofSize: kFontSize), colour: .dark, parent: details)
//
//        setupLabel(holidayHourLabel, text: restaurant.holidayHours , font: UIFont.lightRescounts(ofSize: kDetailFontSize), lines: 0, parent: details)
//
//
//
//        let hours: (days: String, hours: String) = HoursManager.allDaysAsString(restaurant.hours)
//
//        if hours.days != "" {
//            setupLabel(daysLabel,  text: hours.days,  font: UIFont.lightRescounts(ofSize: kDetailFontSize), lines: 0, parent: details)
//        } else {
//            let days = "Mon:\nTues:\nWed:\nThurs:\nFri:\nSat:\nSun:"
//              setupLabel(daysLabel,  text: days,  font: UIFont.lightRescounts(ofSize: kDetailFontSize), lines: 0, parent: details)
//        }
//        if hours.hours != "" {
//               setupLabel(hoursLabel, text: hours.hours, font: UIFont.lightRescounts(ofSize: kDetailFontSize), lines: 0, parent: details)
//        } else {
//            let hours = "Closed\nClosed\nClosed\nClosed\nClosed\nClosed\nClosed"
//                setupLabel(hoursLabel, text: hours, font: UIFont.lightRescounts(ofSize: kDetailFontSize), lines: 0, parent: details)
//        }
//        hoursIcon.contentMode = .scaleAspectFit
//        details.addSubview(hoursIcon)
//
//        setupLabel(hoursTitle, text: l10n("hours"), font: UIFont.lightRescounts(ofSize: kFontSize), colour: .dark, parent: details)
    }
    
}

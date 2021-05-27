//
//  ReservationDetailsButton.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-10-15.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class ReservationDetailsButton: UIControl, UIPickerViewDelegate, UIPickerViewDataSource {

	let downArrow   	= UIImageView(image: UIImage(named: "ArrowDown"))
	let peopleIcon  	= UIImageView(image: UIImage(named: "IconPeople"))
	let peopleLabel 	= UILabel()
	let timeIcon    	= UIImageView(image: UIImage(named: "IconClock"))
	let timeLabel  	 	= UILabel()
	
	let picker = UIPickerView()
	let hiddenTextField = UITextField() // Used for showing UIPickerView as keyboard
	
	public private(set) var numPeople: Int = 2			// These default values are set below in setupPicker()
	public private(set) var desiredTime: Date = Date()
	
	private var pickupMode: Bool = false
	
	var referenceDate = Date() // Keep this around so that time calculations don't change after creation
	var timeData: [String] = []
	
	let timeInterval: TimeInterval = 900 // 15 minutes
	private let kMaxPeople: Int = 6
	
	var dayText = "today" //Either show today or tomorrow
	var isPicking = false
	// MARK: - Initialization
	
	convenience init() {
		self.init(frame: .arbitrary)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		setupData()
		
		setupIcon(downArrow)
		setupIcon(peopleIcon)
		setupIcon(timeIcon)
		setupLabel(peopleLabel)
		setupLabel(timeLabel)
		
		setupPicker()
		
		updatePeopleLabel()
		updateTimeLabel()
		
		self.addAction(for: .touchUpInside) { [weak self] in
			self?.showPicker()
		}
	}
	
	
	// MARK: - UIView Overrides
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let peopleWidth = ceil(peopleLabel.sizeThatFits(CGSize(frame.width, frame.height)).width) + 10
		let timeWidth   = ceil(timeLabel.sizeThatFits  (CGSize(frame.width, frame.height)).width) + 5
		let iconY       = Helper.roundf(peopleLabel.font.topCapYForLabelHeight(frame.height), denom: 2)
		let iconHeight  = peopleLabel.font.capHeight
		
		downArrow.frame   = CGRect(0, 0, frame.height, frame.height)
		peopleIcon.frame  = CGRect(downArrow.frame.maxX, iconY, 2*frame.height, iconHeight)
		peopleLabel.frame = CGRect(peopleIcon.frame.maxX, 0, peopleWidth, frame.height)
		timeIcon.frame    = CGRect(peopleLabel.frame.maxX + frame.height, iconY, iconHeight, iconHeight)
		timeLabel.frame   = CGRect(timeIcon.frame.maxX + 5, 0, timeWidth, frame.height)
	}
	
	
	// MARK: - UI Helpers
	
	public func idealWidth(forHeight height: CGFloat) -> CGFloat {
		let peopleWidth = ceil(peopleLabel.sizeThatFits(CGSize(1000,100)).width) + 10
		let timeWidth   = ceil(timeLabel.sizeThatFits  (CGSize(1000, 100)).width) + 5
		let iconHeight  = peopleLabel.font.capHeight
		
		return height + 2*height + peopleWidth + height + iconHeight + 5 + timeWidth
	}
	
	private func setupLabel(_ label: UILabel, parent: UIView? = nil, fontSize: CGFloat = 15) {
		label.font = UIFont.lightRescounts(ofSize: 15)
		label.textColor = .dark
		label.backgroundColor = .clear
		label.adjustsFontSizeToFitWidth = true
		addSubview(label)
	}
	
	private func setupIcon(_ icon: UIImageView) {
		icon.contentMode = .scaleAspectFit
		icon.backgroundColor = .clear
		addSubview(icon)
	}

	private func setupPicker() {
		picker.dataSource = self
		picker.delegate = self
		picker.backgroundColor = .white
		
		// Setup defaults
		numPeople = 2
		picker.selectRow(1, inComponent: 0, animated: false)
		desiredTime = timeFromPickerRow(0)
		picker.selectRow(2, inComponent: 1, animated: false) // Defaults to 30 minutes from now
		
		let tabBar = UIView(frame: CGRect(0, 0, frame.width, 40))
		tabBar.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
		let okButt = UIButton(frame: CGRect(frame.width - 60, 0, 50, 40))
		okButt.setTitle("OK", for: .normal)
		okButt.setTitleColor(.primary, for: .normal)
		okButt.addAction(for: .touchUpInside) { [weak self] in
			self?.donePicking()
		}
		okButt.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
		tabBar.addSubview(okButt)
		
		hiddenTextField.isHidden = true
		hiddenTextField.inputView = picker
		hiddenTextField.inputAccessoryView = tabBar
		hiddenTextField.inputAssistantItem.leadingBarButtonGroups.removeAll() // Removes the default undo/redo buttons
		hiddenTextField.inputAssistantItem.trailingBarButtonGroups.removeAll()
		
		addSubview(hiddenTextField)
	}
	
	private func updatePeopleLabel() {
		peopleLabel.text = String.localizedStringWithFormat(numPeople == 1 ? l10n("numPeople.one") : l10n("numPeople.other"), numPeople)
		if numPeople == 0 {
			peopleLabel.text = l10n("pickup")
		}
	}
	
    private func updateTimeLabel(timeStr: String = "") {
        if !timeStr.isEmpty {
            timeLabel.text = "\(l10n(dayText)), \(timeStr)"
        } else {
            timeLabel.text = "\(l10n(dayText)), \(desiredTimeString())"

        }
	}
	
	private func updateDayText(theDate: Date){ // This is used to show "Today" or "Tomorrow"

		if (Calendar.current.isDateInToday(theDate)) {
			dayText = "today"
		} else if (Calendar.current.isDateInTomorrow(theDate)) {
			dayText =  "tomorrow"
		} else {
			dayText = ""
		}
	}
	
	
	// MARK: - Public Methods
	
	public func desiredTimeString() -> String {
		return timeData[picker.selectedRow(inComponent: pickupMode ? 0 : 1)]
	}
	
	public func updateData(numPeople: Int, desiredTime: Date? = nil) {
		self.numPeople = numPeople
		pickupMode = (numPeople == 0)
		

		self.desiredTime = desiredTime ?? timeFromPickerRow(numPeople == 0 ? 2 : 2)
		
		if pickupMode {
			picker.selectRow(indexForDesiredTime(self.desiredTime) , inComponent: 0, animated: false)
            updateTimeLabel(timeStr: timeData[indexForDesiredTime(self.desiredTime)  ])
		} else {
			picker.selectRow(indexForNumPeople(numPeople), inComponent: 0, animated: false)
			picker.selectRow(indexForDesiredTime(self.desiredTime), inComponent: 1, animated: false)
            updateTimeLabel()

		}
		
		updatePeopleLabel()
	}
	
	public func usePinkArrow() {
		downArrow.image = UIImage(named: "ArrowDownPink")
	}
	
	public func hideArrow() {
		downArrow.isHidden = true
	}
	
	public func showPicker() {
		hiddenTextField.becomeFirstResponder()
	}
	
	
	// MARK: - Private Helpers
	
	private func setupData() {
		// for the first item, we want the current time
//		timeData.append(HoursManager.hoursStringFromDate(referenceDate))
		
		referenceDate = Date().ceil(precision: timeInterval)
		
		for i in 0..<80 { // let users reserve hour upto 20 hours after current time 80 = 20 * 4
			let newTime = referenceDate.addingTimeInterval(TimeInterval(i) * timeInterval)
			timeData.append(HoursManager.hoursStringFromDate(newTime))
		}
        timeData.removeFirst()
	}
	
	private func donePicking() {
        
        if !isPicking {
            updateTimeLabel(timeStr: timeData[indexForDesiredTime(self.desiredTime) ])
            desiredTime = timeFromPickerRow(2)
            hiddenTextField.resignFirstResponder()
        } else {
            hiddenTextField.resignFirstResponder()

        }
   

	}
	
	private func timeFromPickerRow(_ row: Int) -> Date {
		
		let theDate = referenceDate.addingTimeInterval(TimeInterval(row ) * timeInterval) //Due to we insert the current time as the first, we then get the correct date by row - 1
//		if row == 0 {
//			return Date()
//		}
		
//		updateDayText(theDate: theDate)
		
		return theDate
		
	}
	
	private func indexForNumPeople(_ numPeople: Int) -> Int {
		let retVal = numPeople
		return (0...kMaxPeople).clamp(retVal)
	}
	
	private func indexForDesiredTime(_ desiredTime: Date) -> Int {
		let stringRep = HoursManager.hoursStringFromDate(desiredTime)
		for (i,time) in timeData.enumerated() {
			if (time == stringRep) {
				return i
			}
		}
		return 0
	}
	
	
	// MARK: - UIPicker Methods
	
	public func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return pickupMode ? 1 : 2
	}
	
	public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		if componentIsNumPeople(component) {
			return kMaxPeople + 1 //kMaxPeople is 20 and we also include 0
		} else {
			return timeData.count
		}
	}
	
	public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if componentIsNumPeople(component) {
			if (row == 0) {
				return l10n("pickup")
			} else {
				return "\(row)"
			}
		} else {
       
			return timeData[row]
		}
	}
    
    
	
	public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if componentIsNumPeople(component) {
			numPeople = row
			updatePeopleLabel()
		} else {
            
            isPicking = true
            
            desiredTime = timeFromPickerRow(row + 1 )
     
                updateTimeLabel()
            
		}
	}
	
	private func componentIsNumPeople(_ component: Int) -> Bool {
		return (!pickupMode && component == 0)
	}
}

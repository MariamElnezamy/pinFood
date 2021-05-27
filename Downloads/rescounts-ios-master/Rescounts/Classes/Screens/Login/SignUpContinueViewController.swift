//
//  SignUpContinueViewController.swift
//  Rescounts
//
//  Created by Monica Luo on 2018-09-05.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation
import UIKit

class SignUpContinueViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
	typealias k = Constants
	
	private let profilePhoto = UIImageView(image: UIImage(named: "imgAddphoto"))
	private let cameraImageView = UIImageView()
	private let instruction = UILabel()
	private let firstNameTextField = RescountsTextField()
	private let firstNameLine = UIView()
	private let lastNameTextField = RescountsTextField()
	private let lastNameLine = UIView()
	private let phoneNumTextField = RescountsTextField()
	private let phoneNumLine = UIView()
	private let birthdayTextField = RescountsTextField()
	private var birthdayDate : Date? = nil
	private let birthdayLine = UIView()
	private let cityTextField = RescountsTextField()
	private let cityLine = UIView()
	private let cityPicker = UIPickerView()
	private let rtyCodeTextField = RescountsTextField()
	private let rtyCodeLine = UIView()
	private let agreeCheckBox = CheckBox()
	private let offersCheckBox = CheckBox()
	private let agreeLabel = UILabel()
	private let offersLabel = UILabel()
	private let datePickerView = UIDatePicker()
	private let awsLabel = UILabel()
	private let awsLogo = UIImageView(image: UIImage(named: "aws_logo"))
	private let nextButton = RescountsButton()
	private let tapCatchingView = UIView()
	private let spinner = CircularLoadingSpinner()
	private let doneBar = UIToolbar()
	
	private let kCameraImageIndex : CGFloat = 25
	private let kCameraImageDimensions: (size: CGFloat, offset: CGFloat) = (31, 10)
	private let kCheckBoxSpacer: CGFloat = 10
	private let kAWSLayout: (height: CGFloat, padding: CGFloat, imgWidth: CGFloat) = (22, 5, 20)
	
	private var newImage: UIImage?
	
	private var scrollView = UIScrollView()
	
	
	
	//MARK: - initialization
	
	init( ){
		super.init(nibName: nil, bundle:nil)
	}
	
	required init?(coder aDecoder: NSCoder){
		assert(false)
		super.init(coder:aDecoder)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	//MARK: - views funcs
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		self.title = l10n("profile").uppercased()
		
		view.addSubview(scrollView)
		
		scrollView.addSubview(tapCatchingView)
		tapCatchingView.isHidden = true
		
		setupProfileImage()
		setupCameraImage()
		
		setupDoneBar()
		
		var instructionTextSize : CGFloat = 15
		if checkFive() {
			instructionTextSize = 13
		}
		setupLabel(instruction, text: l10n("profileImageText") , size: instructionTextSize, alignment: .center, numberOfLines: 0)
		
		setupTextfield(textField: firstNameTextField, placeholder: "\(l10n("firstName"))*", text: AccountManager.main.user?.firstName)
		setupLine(firstNameLine)
		
		setupTextfield(textField: lastNameTextField, placeholder: l10n("lastName"), text: AccountManager.main.user?.lastName)
		setupLine(lastNameLine)
		
		setupTextfield(textField: phoneNumTextField, placeholder: "\(l10n("phoneNum"))*", text: AccountManager.main.user?.phoneNum)
		phoneNumTextField.keyboardType = .numberPad
		phoneNumTextField.inputAccessoryView = doneBar
		setupLine(phoneNumLine)
		
		setupTextfield(textField: birthdayTextField, placeholder: "\(l10n("birthdate")) (\(l10n("optional")))", text: "")
		datePickerView.datePickerMode = .date
		birthdayTextField.inputView = datePickerView
		birthdayTextField.inputAccessoryView = doneBar
		datePickerView.addTarget(self, action: #selector(getDateString(sender:)), for: .valueChanged)
		setupLine(birthdayLine)
		
//		setupTextfield(textField: rtyCodeTextField, placeholder: l10n("rty"), text: "")
//		setupLine(rtyCodeLine)
		
		setupTextfield(textField: cityTextField, placeholder: "\(l10n("city"))*", text: "", input: cityPicker)
		cityTextField.inputAccessoryView = doneBar
		setupLine(cityLine)
		setupPicker(cityPicker)
		
		setupCheckbox(offersCheckBox)
		setupLabel(offersLabel, text: l10n("offerText"))
		
		setupCheckbox(agreeCheckBox)
		setupLabel(agreeLabel, text: "")
		let linkText = l10n("terms&Conds")
		let fullText = NSMutableAttributedString(string:"\(l10n("preTerms&Conds")) \(linkText)")
		fullText.addAttributes([.foregroundColor : UIColor.primary], range: NSMakeRange(fullText.string.count - linkText.count, linkText.count))
		agreeLabel.attributedText = fullText
		agreeLabel.isUserInteractionEnabled = true
		agreeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tappedTandCs)))
		
		setupAWSLine()
		
		setupNextButton()
		
		spinner.isHidden = true
		view.addSubview(spinner)
		
		setupKeyboardDismissView()
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.setNavigationBarHidden(false, animated: false)
		navigationController?.navigationBar.backgroundColor = .dark
		navigationController?.navigationBar.barTintColor = .dark
		navigationController?.navigationBar.tintColor = .white
		navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
		navigationController?.navigationBar.barStyle = .black
		
		hideSpinner(true)
	}
	
	override func viewWillLayoutSubviews(){
		super.viewWillLayoutSubviews()
		
		let kProfileImageHeight: CGFloat = floor(self.view.frame.width / 3.9)
		var kTextFieldDetails: (width: CGFloat, height: CGFloat, topPadding: CGFloat) = (300.0 + 10.0 * 2, 40.0, 15.0)
		if checkFive() {
			kTextFieldDetails.height = 30.0
		}
		let kRescountsButtonDetails: (width: CGFloat, height: CGFloat, topPadding: CGFloat, bottomPadding: CGFloat) = (303 , 51, 26, 30)
		var kInstruction : (width: CGFloat, topPadding : CGFloat, bottomPadding: CGFloat) = (300,15, 20)
		if checkFive() {
			kInstruction.bottomPadding = 15.0
		}
		
		let leftMargin = floor(self.view.frame.width/2.0 - kRescountsButtonDetails.width/2.0)
		let leftTextMargin = self.view.frame.width / 2.0 - kTextFieldDetails.width / 2.0
		//let topBarHeight = UIApplication.shared.statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.height ?? 0.0)
		
		profilePhoto.frame       = CGRect(floor(view.frame.width/2 - kProfileImageHeight/2), /*topBarHeight + */ 9.0, kProfileImageHeight, kProfileImageHeight)
		cameraImageView.frame    = CGRect(profilePhoto.frame.maxX - kCameraImageIndex , profilePhoto.frame.maxY - kCameraImageIndex  , kCameraImageDimensions.size, kCameraImageDimensions.size)
		instruction.frame        = CGRect(view.frame.width/2.0 - kInstruction.width/2.0, profilePhoto.frame.maxY + kInstruction.topPadding, kInstruction.width , getInstructionHeight())
		firstNameTextField.frame = CGRect(leftTextMargin, instruction.frame.maxY + kInstruction.bottomPadding, kTextFieldDetails.width, kTextFieldDetails.height)
		firstNameLine.frame      = CGRect(leftMargin, firstNameTextField.frame.maxY, kRescountsButtonDetails.width, 2.0)
		lastNameTextField.frame  = CGRect(leftTextMargin, firstNameTextField.frame.maxY + kTextFieldDetails.topPadding, kTextFieldDetails.width, kTextFieldDetails.height)
		lastNameLine.frame       = CGRect(leftMargin, lastNameTextField.frame.maxY, kRescountsButtonDetails.width, 2.0)
		phoneNumTextField.frame  = CGRect(leftTextMargin, lastNameTextField.frame.maxY + kTextFieldDetails.topPadding, kTextFieldDetails.width, kTextFieldDetails.height)
		phoneNumLine.frame       = CGRect(leftMargin, phoneNumTextField.frame.maxY, kRescountsButtonDetails.width, 2.0)
		birthdayTextField.frame  = CGRect(leftTextMargin, phoneNumTextField.frame.maxY + kTextFieldDetails.topPadding, kTextFieldDetails.width, kTextFieldDetails.height)
		birthdayLine.frame       = CGRect(leftMargin, birthdayTextField.frame.maxY, kRescountsButtonDetails.width, 2.0)
		
		//RTY code
//		rtyCodeTextField.frame   = CGRect(leftTextMargin, birthdayTextField.frame.maxY + kTextFieldDetails.topPadding, kTextFieldDetails.width, kTextFieldDetails.height)
//		rtyCodeLine.frame        = CGRect(leftMargin, rtyCodeTextField.frame.maxY, kRescountsButtonDetails.width, 2.0)
		
		cityTextField.frame  = CGRect(leftTextMargin, birthdayTextField.frame.maxY + kTextFieldDetails.topPadding, kTextFieldDetails.width, kTextFieldDetails.height)
		cityLine.frame       = CGRect(leftMargin, cityTextField.frame.maxY, kRescountsButtonDetails.width, 2.0)
		
		offersCheckBox.frame = CGRect(leftMargin, cityLine.frame.maxY + kCheckBoxSpacer*2, 20, 20)
		offersLabel.frame    = CGRect(offersCheckBox.frame.maxX + kCheckBoxSpacer, offersCheckBox.frame.minY, view.frame.width - offersCheckBox.frame.maxX, 20)
		
		agreeCheckBox.frame = CGRect(leftMargin, offersLabel.frame.maxY + kCheckBoxSpacer, 20, 20)
		agreeLabel.frame    = CGRect(agreeCheckBox.frame.maxX + kCheckBoxSpacer, agreeCheckBox.frame.minY, view.frame.width - offersCheckBox.frame.maxX, 20)
		
		scrollView.frame = CGRect(0,view.bounds.minY, view.bounds.width, self.view.frame.height - kRescountsButtonDetails.bottomPadding - kRescountsButtonDetails.height - kAWSLayout.height)
		scrollView.contentSize = view.bounds.size
		scrollView.contentSize.height = agreeLabel.frame.maxY + 20 //If the button covers the text label, the scrollview will be scrollable
		
		nextButton.frame = CGRect(leftMargin, self.view.frame.height - kRescountsButtonDetails.bottomPadding - kRescountsButtonDetails.height, kRescountsButtonDetails.width, kRescountsButtonDetails.height )
		tapCatchingView.frame = CGRect(0,0,self.view.frame.width, self.view.frame.height)
		
		let awsY = nextButton.frame.minY - kAWSLayout.height
		awsLabel.sizeToFit()
		let awsWidth = awsLabel.frame.width + kAWSLayout.padding + kAWSLayout.imgWidth
		let awsX = floor(0.5 * (view.frame.width - awsWidth))
		awsLabel.frame = CGRect(awsX, awsY, awsLabel.frame.width, kAWSLayout.height)
		awsLogo.frame  = CGRect(awsX + awsWidth - kAWSLayout.imgWidth, awsY, kAWSLayout.imgWidth, kAWSLayout.height)
		
		spinner.frame = nextButton.frame
		spinner.frame.centerInPlace(size: CGSize(spinner.frame.height, spinner.frame.height))
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	//MARK: - UITextfield setup
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		if textField == phoneNumTextField {
			
			let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
			let components = (newString as NSString).components(separatedBy: NSCharacterSet.decimalDigits.inverted)
			
			let decimalString = components.joined(separator: "") as NSString
			let length = decimalString.length
			let hasLeadingOne = length > 0 && decimalString.hasPrefix("1")
			
			if length == 0 || (length > 10 && !hasLeadingOne) || length > 11 {
				let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
				return (newLength > 10) ? false : true
			}
			
			var index = 0 as Int
			let formattedString = NSMutableString()
			
			if hasLeadingOne && (string.count != 0 || newString.count > 1) {
				formattedString.append("1 ")
				index += 1
			}
			if (length - index) > 3 {
				let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
				formattedString.appendFormat("(%@) ", areaCode)
				index += 3
			}
			if length - index > 3 {
				let prefix = decimalString.substring(with: NSMakeRange(index, 3))
				formattedString.appendFormat("%@-", prefix)
				index += 3
			}
			
			let remainder = decimalString.substring(from: index)
			formattedString.append(remainder)
			textField.text = formattedString as String
			return false
			
		} else {
			return true
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		dismissKeyboard()
		return true
	}
	
	@objc func getDateString(sender: UIDatePicker){
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM-dd-yyyy"
		let realDate = sender.date
		self.birthdayDate = realDate
		self.birthdayTextField.text = dateFormatter.string(from: sender.date)
	}
	
	private func setupKeyboardDismissView() {
		tapCatchingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
		tapCatchingView.addGestureRecognizer(tap)
	}
	
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
	
	@objc func keyboardWillShow(notification:  NSNotification){
		//self.backgroundView.frame.origin.y = -nameTextField.frame.minY + kGap - kMiniGap
		
		if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
			self.view.frame.origin.y = -(keyboardSize.height / 2.0) - 15.0
		}
		//self.view.frame.origin.y = -136
		//self.backgroundView.addSubview(tapCatchingView)
		tapCatchingView.isHidden = false
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
		self.view.frame.origin.y = 0
		//tapCatchingView.removeFromSuperview()
		tapCatchingView.isHidden = true
	}
	
	// MARK: - Private funcs
	
	private func checkFive() -> Bool {
		//Check if the iPhone model is 5, 5c, or 5s
		if ((UIDevice.current.modelName == "iPhone 5") || (UIDevice.current.modelName == "iPhone 5c") || (UIDevice.current.modelName == "iPhone 5s")) {
			return true
		} else {
			return false
		}
	}
	
	private func setupProfileImage() {
		profilePhoto.backgroundColor = .clear
		profilePhoto.contentMode = .scaleAspectFit
		profilePhoto.layer.cornerRadius = k.Profile.imageCornerRadius
		profilePhoto.layer.borderWidth = k.Profile.imageBorderWidth
		profilePhoto.layer.borderColor = UIColor.gold.cgColor
		profilePhoto.layer.masksToBounds = true
		profilePhoto.layer.backgroundColor = UIColor.black.cgColor
		
		let tappedPhotoGesture = UITapGestureRecognizer(target: self, action: #selector(tappedPhoto))
		profilePhoto.addGestureRecognizer(tappedPhotoGesture)
		profilePhoto.isUserInteractionEnabled = true
		
		scrollView.addSubview(profilePhoto)
	}
	
	@objc private func tappedPhoto() {
		let imagePickerViewController = UIImagePickerController()
		imagePickerViewController.allowsEditing = true
		imagePickerViewController.delegate = self
		
		if UIImagePickerController.isSourceTypeAvailable(.camera) {
		let options = UIScreen.main.bounds.width > 500 ? [l10n("takePicture"), l10n("cameraRoll"), l10n("no")] : ["Camera", "Photos", "None"]
			RescountsAlert.showAlert(title: "Image Source", text: "", options: options) { (alert, buttonIndex) in
				if buttonIndex == 0 {
					print("camera")
					imagePickerViewController.sourceType = .camera
					self.present(imagePickerViewController, animated: true)
				} else if buttonIndex == 1 {
					print("album")
					imagePickerViewController.sourceType = .savedPhotosAlbum
					self.present(imagePickerViewController, animated: true)
				} else {
					print("cancel")
				}
			}
		} else {
			imagePickerViewController.sourceType = .photoLibrary
			self.present(imagePickerViewController, animated: true) {
			}
		}
	}
	
	private func setupCameraImage() {
		
		cameraImageView.image = UIImage(named: "IconAddPhoto")
		cameraImageView.contentMode = .scaleAspectFit
		cameraImageView.layer.masksToBounds = true
		
		scrollView.addSubview(cameraImageView)
	}
	
	private func setupDoneBar() {
		let doneButton = UIBarButtonItem(title: l10n("Done"), style: .plain, target: self, action: #selector(tappedDone))
		let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//		let cancelButton = UIBarButtonItem(title: l10n("Cancel"), style: .plain, target: self, action: cancel)
		
		doneBar.sizeToFit()
		doneBar.setItems([spaceButton, doneButton], animated: false)
	}
	
	private func setupLabel(_ label: UILabel, text: String, size: (CGFloat) = 13, alignment: NSTextAlignment = .left, numberOfLines: Int = 1) {
		label.text = text
		label.textAlignment = alignment
		label.font = UIFont.lightRescounts(ofSize: size)
		label.textColor = UIColor.nearBlack
		label.numberOfLines = numberOfLines
		
		scrollView.addSubview(label)
	}
	
	private func setupCheckbox(_ checkBox: CheckBox) {
		checkBox.addAction(for: .valueChanged) { [weak self] in
			self?.dismissKeyboard() // Dismiss keyboard when we interact with the checkboxes
		}
		scrollView.addSubview(checkBox)
	}
	
	private func getInstructionHeight () -> CGFloat{
		var kInstruction : (width: CGFloat, topPadding : CGFloat, bottomPadding: CGFloat) = (300,15, 20)
		if (checkFive()) {
			kInstruction.bottomPadding = 15
		}
		let descriptionHeight = instruction.sizeThatFits(CGSize(kInstruction.width, 1000)).height
		return descriptionHeight
	}
	
	private func setupTextfield(textField: RescountsTextField, placeholder: String, text: String? = nil, input: UIView? = nil) {
		textField.placeholder = placeholder
		textField.font = .rescounts(ofSize: 15)
		textField.textColor = UIColor.nearBlack
		textField.autocorrectionType = .no
		textField.text = text
		textField.inputView = input
		textField.delegate = self
		
		scrollView.addSubview(textField)
	}
	
	private func setupLine(_ line: UIView) {
		line.backgroundColor = UIColor.lightGray
		scrollView.addSubview(line)
	}
	
	private func setupPicker(_ picker: UIPickerView) {
		picker.dataSource = self
		picker.delegate = self
	}
	
	private func setupAWSLine() {
		awsLabel.text = "Saved securely using"
		awsLabel.font = .rescounts(ofSize: 13)
		awsLabel.textColor = UIColor(white: 0.5, alpha: 1)
		awsLabel.textAlignment = .right
		
		awsLogo.contentMode = .scaleAspectFit
		
		view.addSubview(awsLabel)
		view.addSubview(awsLogo)
	}
	
	private func setupNextButton() {
		nextButton.setTitle(l10n("next").uppercased(), for: .normal)
		nextButton.titleLabel?.font = UIFont.rescounts(ofSize: 15.0)
		nextButton.addAction(for: UIControlEvents.touchUpInside) { [weak self] in
			
			if (self?.firstNameTextField.text == "") {
				RescountsAlert.showAlert(title: l10n("oops"), text: l10n("nameRequired"), callback: nil)
				return
			}
			
//			if (AccountManager.main.user?.profileImage == nil && self?.newImage == nil) {
//				RescountsAlert.showAlert(title: "Oops!", text: l10n("imageRequired"), callback: nil)
//				return
//			}
			
			if (self?.phoneNumTextField.text == "") {
				RescountsAlert.showAlert(title: l10n("oops"), text: l10n("phoneRequired"), callback: nil)
				return
			}
            if (self?.cityTextField.text == "") {
                       RescountsAlert.showAlert(title: l10n("oops"), text: "City name is required.", callback: nil)
                       return
                   }
               
			if (!(self?.agreeCheckBox.on ?? false)) {
				RescountsAlert.showAlert(title: l10n("oops"), text: l10n("mustAcceptT&C"), callback: nil)
				return
			}
			
   
			self?.hideSpinner(false)
			
			if let firstName = self?.firstNameTextField.text {
				UserService.updateUser(firstName: firstName, lastName: self?.lastNameTextField.text ?? "", phoneNum: self?.phoneNumTextField.text ?? "", birthday: self?.birthdayDate, rtyCode: self?.rtyCodeTextField.text ?? nil, allowOffers: self?.offersCheckBox.on, city: self?.cityTextField.text, callback: { (user, error) in
					if (error != nil) {
						print(error?.localizedDescription ?? "")
						RescountsAlert.showAlert(title: l10n("signUpErrorTitle"), text: error?.localizedDescription ?? l10n("cannotUpdateProfile"), callback: nil)
						self?.hideSpinner(true)
						
					} else if let img = self?.newImage {
						UserService.setProfilePicture(profilePicture: img) { error in
							if (error != nil) {
								print(error?.localizedDescription ?? "")
								RescountsAlert.showAlert(title: l10n("error"), text: l10n("cannotUploadPhoto"))
							} else {
								self?.moveToNextScreen()
								NotificationCenter.default.post(name: .updatedUser, object: nil)
							}
						}
					} else {
						self?.moveToNextScreen()
					}
				})
			}
		}
		view.addSubview(nextButton)
	}
	
	private func moveToNextScreen() {
		hideSpinner(true)
		let vc = PaymentMethodsViewController()
		vc.displayState = PaymentMethodsViewController.DisplayState.signup
		navigationController?.pushViewController(vc, animated: true)
	}
	
	private func hideSpinner(_ spinnerHidden: Bool) {
		spinner.isHidden = spinnerHidden
		nextButton.isHidden = !spinnerHidden
	}
	
	@objc private func tappedTandCs() {
		UIApplication.shared.open(URL(string: "https://rescounts.com/termsofuse.php")!, options: [:], completionHandler: nil)
	}
	
	@objc private func tappedDone() {
		dismissKeyboard()
	}
	
	
	// MARK: - UIImagePickerControllerDelegate
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		picker.dismiss(animated: true)
		
		guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
			return
		}
		self.profilePhoto.image = image
		newImage = image
	}
}

extension SignUpContinueViewController: UIPickerViewDelegate, UIPickerViewDataSource {
	public func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return k.Profile.cities.count
	}
	
	public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return k.Profile.cities[row]
	}
	
	public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		print ("Selected: \(k.Profile.cities[row])")
		cityTextField.text = k.Profile.cities[row]
	}
}

//
//  MyAccountViewController.swift
//  Rescounts
//
//  Created by Kittiphong Xayasane on 2018-08-15.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import Photos
class MyAccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    private let navBarTinter = UIView()
    private let headerView = UIView()
    private let profilePhoto = RemoteImageView()
    private let tableView = UITableView()
    private let saveButton = RescountsButton()
    private let photoContainer = UIView()
    private let cameraImageView = UIImageView()
    private let tapCatchingView = UIView()
    
    private let kHeaderProfileHeight: CGFloat = 155
    private let kProfileImageHeight: CGFloat = 100
    private let kSaveButtonDimensions:(sidePadding: CGFloat, bottomPadding: CGFloat, height: CGFloat) = (53, 20, 50)
    private let kCameraImageDimensions: (size: CGFloat, offset: CGFloat) = (31, 10)
    
    private var data: [MyAccountItem] = [MyAccountItem](repeating: MyAccountItem(), count: 8)
    
    private var kFirstNameDetails: (title: String, valueType: MyAccountItem.ValueType, index: Int) = (l10n("firstName"), .regular, 0)
    private var kLastNameDetails: (title: String, valueType: MyAccountItem.ValueType, index: Int) = (l10n("lastName"), .regular, 1)
    private var kEmailDetails: (title: String, valueType: MyAccountItem.ValueType, index: Int) = (l10n("email"), .regular, 2)
    private var kPhoneDetails: (title: String, valueType: MyAccountItem.ValueType, index: Int) = (l10n("phoneNum"), .phoneNumber, 3)
    private var kBirthdayDetails: (title: String, valueType: MyAccountItem.ValueType, index: Int) = (l10n("birthdate"), .birthday, 4)
    private var kPromoCodeDetails: (title: String, valueType: MyAccountItem.ValueType, index: Int) = (l10n("promoCode"), .regular, 5)
    private var kPasswordDetails: (title: String, valueType: MyAccountItem.ValueType, index: Int) = (l10n("password"), .password, 6)
    private var kConfirmPasswordDetails: (title: String, valueType: MyAccountItem.ValueType, index: Int) = (l10n("confirmPassword"), .password, 7)
    
    // MARK: - initialization
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = l10n("myAccount").uppercased()
        self.view.backgroundColor = .white
        generateUserData()
        setupHeader()
        setupPhotoContainer()
        setupProfileImage()
        setupCameraImage()
        setupTableView()
        setupSaveButton()
        navBarTinter.backgroundColor = .dark
        view.addSubview(navBarTinter)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedAnywhere))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: l10n("logout").uppercased(), style: .done, target: self, action: #selector(tappedLogout))
        
        
        setupKeyboardDismissView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc private func tappedLogout() {
        UserService.logout()
    }
    
    @objc private func tappedAnywhere() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.backgroundColor = .dark
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let vw = view.frame.width
        navBarTinter.frame = CGRect(0, 0, vw, topLayoutGuide.length)
        
        headerView.frame = CGRect(0, topLayoutGuide.length, view.frame.width, Constants.Profile.profilePhotoPaddingTop*2 + kProfileImageHeight + Constants.Profile.separatorHeight)
        profilePhoto.frame = CGRect(view.frame.width/2 - kProfileImageHeight/2, Constants.Profile.profilePhotoPaddingTop, kProfileImageHeight, kProfileImageHeight)
        photoContainer.frame = CGRect(0, Constants.Profile.separatorHeight, view.frame.width, headerView.frame.size.height - Constants.Profile.separatorHeight)
        tableView.frame = CGRect(0, headerView.frame.origin.y + headerView.frame.size.height, view.frame.width, view.frame.height - headerView.frame.maxY - kSaveButtonDimensions.height - kSaveButtonDimensions.bottomPadding - 2 * Constants.Order.spacer)
        saveButton.frame = CGRect(kSaveButtonDimensions.sidePadding, view.frame.maxY - kSaveButtonDimensions.bottomPadding - kSaveButtonDimensions.height, view.frame.width - (2 * kSaveButtonDimensions.sidePadding), kSaveButtonDimensions.height)
        cameraImageView.frame = CGRect(profilePhoto.frame.origin.x + profilePhoto.frame.size.width - kCameraImageDimensions.size + kCameraImageDimensions.offset, profilePhoto.frame.origin.y + profilePhoto.frame.size.height - kCameraImageDimensions.size + kCameraImageDimensions.offset, kCameraImageDimensions.size, kCameraImageDimensions.size)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - UI Helpers
    private func setupSaveButton() {
        saveButton.displayType = .primary
        saveButton.setTitle(l10n("save").uppercased(), for: .normal)
        saveButton.setTitleColor(.dark, for: .normal)
        saveButton.titleLabel?.font = UIFont.rescounts(ofSize: 15)
        saveButton.addAction(for: .touchUpInside) {
            if self.data[self.kPasswordDetails.index].value == self.data[self.kConfirmPasswordDetails.index].value && self.data[self.kFirstNameDetails.index].value != "" && self.data[self.kLastNameDetails.index].value != "" && self.data[self.kPhoneDetails.index].value != "" &&  self.data[self.kEmailDetails.index].value != "" {
                FullScreenSpinner.show()
                UserService.updateUser(email: self.data[self.kEmailDetails.index].value,
                                       firstName: self.data[self.kFirstNameDetails.index].value,
                                       lastName: self.data[self.kLastNameDetails.index].value,
                                       password: self.data[self.kPasswordDetails.index].value,
                                       phoneNum: self.data[self.kPhoneDetails.index].value,
                                       birthday: self.data[self.kBirthdayDetails.index].date,
                                       promoCode: self.data[self.kPromoCodeDetails.index].value) { [weak self] (_,error) in
                                        FullScreenSpinner.hideAll()
                                        if (error != nil) {
                                            RescountsAlert.showAlert(title: l10n("cannotUpdateProfilev2"), text: l10n("cannotUpdateProfileMess"))
                                        } else {
                                            NotificationCenter.default.post(name: .updatedUser, object: nil)
                                            self?.navigationController?.popViewController(animated: true)
                                        }
                }
            } else if (self.data[self.kFirstNameDetails.index].value == "" || self.data[self.kLastNameDetails.index].value == "" || self.data[self.kPhoneDetails.index].value == "" ||  self.data[self.kEmailDetails.index].value == "") {
                RescountsAlert.showAlert(title: l10n("cannotUpdateProfilev2"), text: l10n("cannotUpdateGeneral"))
            } else {
                RescountsAlert.showAlert(title: l10n("cannotUpdateProfilev2"), text: l10n("cannotUpdatePass"))
            }
        }
        view.addSubview(saveButton)
    }
    
    private func setupHeader() {
        headerView.backgroundColor = .white
        view.addSubview(headerView)
    }
    
    private func setupPhotoContainer() {
        photoContainer.backgroundColor = .dark
        headerView.addSubview(photoContainer)
    }
    
    private func setupProfileImage() {
        profilePhoto.backgroundColor = .clear
        profilePhoto.contentMode = .scaleAspectFit
        profilePhoto.layer.cornerRadius = Constants.Profile.imageCornerRadius
        profilePhoto.layer.borderWidth = Constants.Profile.imageBorderWidth
        profilePhoto.layer.borderColor = UIColor.gold.cgColor
        profilePhoto.layer.masksToBounds = true
        profilePhoto.layer.backgroundColor = UIColor.black.cgColor
        if let user = AccountManager.main.user {
            profilePhoto.setImageURL(user.profileImage, fetchImmediately: true)
            
        }
        let tappedPhotoGesture = UITapGestureRecognizer(target: self, action: #selector(tappedPhoto))
        tappedPhotoGesture.delegate = self
        profilePhoto.addGestureRecognizer(tappedPhotoGesture)
        profilePhoto.isUserInteractionEnabled = true
        photoContainer.addSubview(profilePhoto)
    }
    
    @objc private func tappedPhoto() {
        let imagePickerViewController = UIImagePickerController()
        imagePickerViewController.allowsEditing = true
        imagePickerViewController.delegate = self

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                alert.addAction(UIAlertAction(title: l10n("takePicture"), style: .default, handler: { _ in
                    imagePickerViewController.sourceType = .camera
                    self.present(imagePickerViewController, animated: true) {
                    }
                }))
        }
        alert.addAction(UIAlertAction(title: l10n("cameraRoll"), style: .default, handler: { _ in
            //Photos
            let photos = PHPhotoLibrary.authorizationStatus()
            if photos == .notDetermined {
                PHPhotoLibrary.requestAuthorization({status in
                    if status == .authorized {
                        DispatchQueue.main.async {
                            imagePickerViewController.sourceType = .savedPhotosAlbum
                            self.present(imagePickerViewController, animated: true) {
                            }
                        }
                    } else {}
                })
            } else if photos == .authorized {
                DispatchQueue.main.async {
                    imagePickerViewController.sourceType = .savedPhotosAlbum
                    self.present(imagePickerViewController, animated: true) {
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: l10n("no"), style: .cancel, handler: { _ in
        }))
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = photoContainer.bounds
        }
        self.present(alert, animated: true, completion: nil)
        
    }
    
    private func setupCameraImage() {
        cameraImageView.image = UIImage(named: "IconAddPhoto")
        cameraImageView.contentMode = .scaleAspectFit
        cameraImageView.layer.masksToBounds = true
        photoContainer.addSubview(cameraImageView)
    }
    
    // MARK: Private Helper
    
    private func setupLabel(_ label: UILabel, font: UIFont, text: String = "") {
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = font
        label.textAlignment = .center
        label.text = text
    }
    
    private func setupTableView() {
        tableView.register(MyAccountTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = true
        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .interactive
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
    }
    
    private func generateUserData() {
        if let user = AccountManager.main.user {
            profilePhoto.setImageURL(user.profileImage, fetchImmediately: true)
            data[kFirstNameDetails.index] = MyAccountItem(title: kFirstNameDetails.title, value: user.firstName, valueType: kFirstNameDetails.valueType)
            data[kLastNameDetails.index] = MyAccountItem(title: kLastNameDetails.title, value: user.lastName, valueType: kLastNameDetails.valueType)
            data[kEmailDetails.index] = MyAccountItem(title: kEmailDetails.title, value: user.email, valueType: kEmailDetails.valueType)
            data[kPhoneDetails.index] = MyAccountItem(title: kPhoneDetails.title, value: user.phoneNum, valueType: kPhoneDetails.valueType)
            data[kBirthdayDetails.index] = MyAccountItem(title: kBirthdayDetails.title, value: HoursManager.userFriendlyBirthday(user.birthday ?? nil), valueType: kBirthdayDetails.valueType)
            data[kPasswordDetails.index] = MyAccountItem(title: kPasswordDetails.title, value: "", valueType: kPasswordDetails.valueType)
            data[kConfirmPasswordDetails.index] = MyAccountItem(title: kConfirmPasswordDetails.title, value: "", valueType: kConfirmPasswordDetails.valueType)
            data[kPromoCodeDetails.index] = MyAccountItem(title: kPromoCodeDetails.title, value: user.promoCode ?? "", valueType: kPromoCodeDetails.valueType)
            
        }
    }
    
    private func setupKeyboardDismissView() {
        tapCatchingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapCatchingView.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification:  NSNotification){
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y = -keyboardSize.height / 2.0 - 15.0
            self.navBarTinter.frame.origin.y = keyboardSize.height / 2.0 + 15.0
        }
        tapCatchingView.isHidden = false
        cameraImageView.isHidden = true
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
        self.navBarTinter.frame.origin.y = 0
        tapCatchingView.isHidden = true
        cameraImageView.isHidden = false
    }
    
    // MARK: - UITableView Methods
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MyAccountTableViewCell.height(data[indexPath.row], width: view.frame.width)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? MyAccountTableViewCell {
            cell.data = data[indexPath.row]
            cell.doneEditingCallback = { value in
                self.data[indexPath.row].value = value
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            return
        }
        
        FullScreenSpinner.show()
        UserService.setProfilePicture(profilePicture: image) { error in
            FullScreenSpinner.hideAll()
            if (error != nil) {
                print(error?.localizedDescription ?? "")
                RescountsAlert.showAlert(title: l10n("uploadError"), text: l10n("cannotUploadPhoto"))
            } else {
                self.profilePhoto.image = image
                NotificationCenter.default.post(name: .updatedUser, object: nil)
            }
        }
    }
}

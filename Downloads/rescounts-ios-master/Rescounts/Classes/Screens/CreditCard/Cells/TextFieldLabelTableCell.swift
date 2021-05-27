//
//  CreditTableCell.swift
//  Rescounts
//
//  Created by Admin on 17/05/2021.
//  Copyright © 2021 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class TextFieldLabelTableCell: UITableViewCell, UITextFieldDelegate {

    var onCameraPress: (()->())?
    var onTextEdit: ((String)->())?
    private var titleLabel: UILabel!
    private var textField: UITextField!
    private var errorLabel: UILabel!
    private var cameraImageView: UIImageView!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.contentView.isUserInteractionEnabled = false
        createTitleLabel()
        createTextField()
        addCameraImage()
        createErrorLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createTitleLabel(){
        titleLabel = UILabel.init()
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        self.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),titleLabel.topAnchor.constraint(equalTo: self.topAnchor),titleLabel.heightAnchor.constraint(equalToConstant: 18)])
    }
    
    private func addCameraImage(){
        cameraImageView = UIImageView.init()
        cameraImageView.isUserInteractionEnabled = true
        cameraImageView.image = UIImage(named: "IconAddPhoto")
        cameraImageView.contentMode = .scaleAspectFit
        textField.addSubview(cameraImageView)
        cameraImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([cameraImageView.heightAnchor.constraint(equalToConstant: 20), cameraImageView.widthAnchor.constraint(equalToConstant: 20),cameraImageView.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: -5),cameraImageView.centerYAnchor.constraint(equalTo: textField.centerYAnchor)])
        cameraImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCameraPressed)))
    }
    
    private func createTextField(){
        textField = UITextField.init()
        textField.borderStyle = .none
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.layer.borderWidth = 0.7
        textField.textColor = .black
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.font = UIFont.systemFont(ofSize: 13)
        self.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([textField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),textField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: 8),textField.heightAnchor.constraint(equalToConstant: 40)])
        textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        // init for delegate
        textField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.contentView.superview?.superview?.endEditing(true)
        return true
    }
    
    private func createErrorLabel(){
        errorLabel = UILabel.init()
        errorLabel.isHidden = true
        errorLabel.textColor = .red
        errorLabel.font = UIFont.systemFont(ofSize: 13)
        self.addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([errorLabel.leadingAnchor.constraint(equalTo: textField.leadingAnchor),errorLabel.trailingAnchor.constraint(equalTo: textField.trailingAnchor),errorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),errorLabel.heightAnchor.constraint(equalToConstant: 18)])
    }

    override func configureCell(data: Any) {
        let tableModel = data as! TableModel
        self.titleLabel.text = tableModel.title
        self.textField.text = tableModel.value
        let _ = tableModel.hasError ? showError(msgError: tableModel.msgError ?? "") : HideError()
        if (tableModel.title == SectionTitle.creditCard.rawValue) {
            cameraImageView.isHidden = false
            textField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCameraPressed)))
        }else if (cameraImageView != nil){
            cameraImageView.isHidden = true
        }
    }
    override func showError(msgError: String) {
        errorLabel.text = msgError
        textField.layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        errorLabel.isHidden = false
    }
    override func HideError() {
        errorLabel.isHidden = true
        textField.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        onTextEdit?(textField.text ?? "")
    }
    @objc func onCameraPressed(){
        let _ = self.titleLabel.text == SectionTitle.creditCard.rawValue ? onCameraPress?() : print("____")
    }
}

//
//  DateViewTabelCell.swift
//  Rescounts
//
//  Created by Admin on 18/05/2021.
//  Copyright © 2021 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class DateViewTabelCell: UITableViewCell, UITextFieldDelegate {

    var cvvValue = "" {
        didSet{
            cvv.text = cvvValue
        }
    }
    var onTextEdit: ((String)->())?

    var onYearButtonPress:(()->())? {
        didSet{
            yearView.onButtonPress = onYearButtonPress
        }
    }
    var onMonthButtonPress:(()->())? {
        didSet{
            monthView.onButtonPress = onMonthButtonPress
        }
    }

    private var titleLabel: UILabel!
    private var stackView: UIStackView!
    private var yearView: CustomDropDwonView!
    private var monthView: CustomDropDwonView!
    private var cvv: UITextField!
    private var errorLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.contentView.isUserInteractionEnabled = false
        createTitleLabel()
        createStackView()
        createErrorLabel()
        createTextField()
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
        NSLayoutConstraint.activate([titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 0),titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),titleLabel.topAnchor.constraint(equalTo: self.topAnchor),titleLabel.heightAnchor.constraint(equalToConstant: 18)])
    }
    
    private func createStackView(){
        monthView = CustomDropDwonView.init()
        monthView.title = "MM"
        monthView.backgroundColor = .gray
        monthView.isUserInteractionEnabled = true
        yearView = CustomDropDwonView.init()
        yearView.isUserInteractionEnabled = true
        yearView.title = "YYYY"
        yearView.backgroundColor = .gray
        stackView = UIStackView.init()
        stackView.isUserInteractionEnabled = true
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        stackView.axis = .horizontal
        stackView.addArrangedSubview(monthView)
        stackView.addArrangedSubview(yearView)
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([stackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),stackView.widthAnchor.constraint(equalToConstant: 180),stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: 8),stackView.heightAnchor.constraint(equalToConstant: 40)])
        
    }
    
    private func createTextField(){
        cvv = UITextField.init()
        cvv.placeholder = "CVV"
        cvv.backgroundColor = .white
        cvv.layer.borderWidth = 0.7
        cvv.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: cvv.frame.height))
        cvv.textAlignment = .center
        cvv.layer.borderColor = UIColor.lightGray.cgColor
        cvv.font = UIFont.systemFont(ofSize: 13)
        cvv.isUserInteractionEnabled = true
        cvv.keyboardType = .asciiCapableNumberPad
        self.addSubview(cvv)
        cvv.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([cvv.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                                     cvv.widthAnchor.constraint(equalToConstant: 50),
                                     cvv.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: 8),
                                     cvv.heightAnchor.constraint(equalToConstant: 40)])
        cvv.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        cvv.delegate = self
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
        NSLayoutConstraint.activate([errorLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),errorLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),errorLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 8),errorLabel.heightAnchor.constraint(equalToConstant: 18)])
    }
    
    override func configureCell(data: Any) {
        let tableModel = data as! TableModel
        self.titleLabel.text = tableModel.title
        
        let valuesArr = tableModel.value?.split(separator: "-")
        self.monthView.title = valuesArr?.last == "0" || tableModel.value == nil ? monthView.title : valuesArr?.last?.description
        self.yearView.title = valuesArr?.first == "0" || tableModel.value == nil ? yearView.title : valuesArr?.first?.description
        let _ = tableModel.hasError ? showError(msgError: tableModel.msgError ?? "") : HideError()

    }
    override func showError(msgError: String) {
        errorLabel.text = msgError
        yearView.layer.borderWidth = 1.3
        monthView.layer.borderWidth = 1.3
        yearView.layer.borderColor = yearView.title == "YYYY" ? #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1) : UIColor.clear.cgColor
        monthView.layer.borderColor = monthView.title == "MM" ? #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1) : UIColor.clear.cgColor
        cvv.layer.borderColor = cvv.text == nil || cvv.text?.isEmpty == true ? #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1) : UIColor.gray.cgColor
        errorLabel.isHidden = false
    }
    override func HideError() {
        errorLabel.isHidden = true
        yearView.layer.borderColor = UIColor.clear.cgColor
        monthView.layer.borderColor = UIColor.clear.cgColor
        cvv.layer.borderColor = UIColor.gray.cgColor
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        onTextEdit?(textField.text ?? "")
    }
}

//
//  DropDownTableCell.swift
//  Rescounts
//
//  Created by Admin on 18/05/2021.
//  Copyright © 2021 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class DropDownTableCell: UITableViewCell {

    private var selectionViewWidthConstraints: NSLayoutConstraint!
    private var titleLabel: UILabel!
    private var selectView: CustomDropDwonView!
    private var errorLabel: UILabel!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        createTitleLabel()
        createDropDownView()
        addAction()
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
    
    private func createDropDownView(){
        selectView = CustomDropDwonView.init()
        selectView.backgroundColor = .gray
        selectView.title = "Select"
        selectView.layer.borderWidth = 1.3
        self.addSubview(selectView)
        selectView.translatesAutoresizingMaskIntoConstraints = false
        selectionViewWidthConstraints = NSLayoutConstraint(item: selectView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([selectView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),selectView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: 8),selectView.heightAnchor.constraint(equalToConstant: 40),selectionViewWidthConstraints])
    }
    private func createErrorLabel(){
        errorLabel = UILabel.init()
        errorLabel.isHidden = true
        errorLabel.textColor = .red
        errorLabel.font = UIFont.systemFont(ofSize: 13)
        self.addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([errorLabel.leadingAnchor.constraint(equalTo: selectView.leadingAnchor),errorLabel.trailingAnchor.constraint(equalTo: selectView.trailingAnchor),errorLabel.topAnchor.constraint(equalTo: selectView.bottomAnchor, constant: 8),errorLabel.heightAnchor.constraint(equalToConstant: 18)])
    }
    
    private func updateWidthConstraints(multiplier: CGFloat){
        selectionViewWidthConstraints.constant = multiplier * self.bounds.width
    }
    
    override func configureCell(data: Any) {
        let tableModel = data as! TableModel
        self.titleLabel.text = tableModel.title
        self.selectView.title = tableModel.value == nil ? selectView.title : tableModel.value ?? ""
        let _ = tableModel.hasError ? showError(msgError: tableModel.msgError ?? "") : HideError()

    }
    
    private func addAction(){
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onButtonPressed)))
    }
    
    var onButtonPress:(()->())?
    @objc private func onButtonPressed() {
        onButtonPress?()
    }
    override func showError(msgError: String) {
        errorLabel.text = msgError
        selectView.layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        errorLabel.isHidden = false
    }
    override func HideError() {
        errorLabel.isHidden = true
        selectView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
   
}

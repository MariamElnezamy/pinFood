//
//  ButtonTableCell.swift
//  Rescounts
//
//  Created by Admin on 18/05/2021.
//  Copyright © 2021 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class ButtonTableCell: UITableViewCell {
    
    var onSaveButtonPress: (()->())?
    var onCancelButtonPress: (()->())?
    
    private var saveButton: UIButton!
    private var cancelButton: UIButton!
    private var stackView: UIStackView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.contentView.isUserInteractionEnabled = false
        createButtons()
        createStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createButtons(){
        saveButton = UIButton.init()
        saveButton.backgroundColor = #colorLiteral(red: 0.7240652442, green: 0.6518148184, blue: 0.1037138179, alpha: 1)
        saveButton.setTitle("Save", for: .normal)
        saveButton.titleLabel?.textColor = .white
        saveButton.layer.cornerRadius = 8
        saveButton.addTarget(self, action: #selector(onSavePressed), for: .touchUpInside)
        
        cancelButton = UIButton.init()
        cancelButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(#colorLiteral(red: 0.7240652442, green: 0.6518148184, blue: 0.1037138179, alpha: 1), for: .normal) 
        cancelButton.layer.borderColor = #colorLiteral(red: 0.7240652442, green: 0.6518148184, blue: 0.1037138179, alpha: 1)
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 8
        cancelButton.addTarget(self, action: #selector(onCancelPressed), for: .touchUpInside)
        
    }
    private func createStackView(){
        stackView = UIStackView.init()
        stackView.axis = .horizontal
        stackView.spacing = 25
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.addArrangedSubview(saveButton)
        stackView.addArrangedSubview(cancelButton)
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,constant: 0),stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),stackView.topAnchor.constraint(equalTo: self.topAnchor),stackView.heightAnchor.constraint(equalToConstant: 40)])
        
    }
    @objc private func onSavePressed(){
        onSaveButtonPress?()
    }
    
    @objc private func onCancelPressed(){
        onCancelButtonPress?()
    }
    
}

//
//  CustomDropDwonView.swift
//  Rescounts
//
//  Created by Admin on 18/05/2021.
//  Copyright © 2021 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class CustomDropDwonView: UIView {

    var title: String?{
        didSet{
            self.titleLabel.text = title
        }
    }
    var onButtonPress:(()->())?
    private var titleLabel: UILabel!
    
    init(){
        super.init(frame: .zero)
        
        createTitleLabel()
        createDropDownImage()
        addAction()
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
        NSLayoutConstraint.activate([titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 8),titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),titleLabel.heightAnchor.constraint(equalToConstant: 18)])
    }
    
    private func createDropDownImage(){
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ArrowDown")
        imageView.image = imageView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        imageView.tintColor = .black
        self.addSubview(imageView)
        self.bringSubview(toFront: imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([imageView.widthAnchor.constraint(equalToConstant: 12),imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -6),imageView.heightAnchor.constraint(equalToConstant: 12),imageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)])
    }

    private func addAction(){
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onButtonPressed)))
    }
    
    @objc private func onButtonPressed() {
        onButtonPress?()
    }
}

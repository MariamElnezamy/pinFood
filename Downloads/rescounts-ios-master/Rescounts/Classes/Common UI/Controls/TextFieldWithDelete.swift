//
//  TextFieldWithDelete.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2019-06-13.
//  Copyright © 2019 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

protocol TextFieldDeleteDelegate: class {
	func textFieldDidDelete(_ textField: TextFieldWithDelete, oldText: String?)
}

class TextFieldWithDelete: UITextField {

	weak var deleteDelegate: TextFieldDeleteDelegate?
	
	override func deleteBackward() {
		let oldText = text
		super.deleteBackward()
		deleteDelegate?.textFieldDidDelete(self, oldText: oldText)
	}

}

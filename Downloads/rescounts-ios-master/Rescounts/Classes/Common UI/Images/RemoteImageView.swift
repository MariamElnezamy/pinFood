//
//  RemoteImageView.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-19.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class RemoteImageView: UIImageView {
	private var imageURL: URL?
	private var startedFetch = false
	
	public var backupImageName: String?
	
	
	// MARK: - Initialization
	
	convenience init() {
		self.init(frame: CGRect.zero)
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
		contentMode = .scaleAspectFill
		clipsToBounds = true
	}
	
	
	// MARK: - Public Methods

	public func setImageURL(_ url: URL?, fetchImmediately: Bool = true, shouldCacheImage: Bool = true, usePlaceholderIfNil: Bool = false) {
		// Image changes if the URL is different, or if one (but not both) is nil
		let imageChanged = (url != self.imageURL || ((url==nil) != (self.imageURL==nil))) || (url==nil && usePlaceholderIfNil)
		self.imageURL = url
		
		if (imageChanged) {
			startedFetch = false
			
			if !urlHasLength(self.imageURL?.absoluteString) {
				startedFetch = true
				if let backup = self.backupImageName {
					self.image = UIImage(named: backup)
				} else {
					self.image = nil
				}
				
			} else if fetchImmediately {
				self.fetchImage()
			}
		}
	}
	
	// Clear the image but not the URL to save memory (it can be re-fetched if needed)
	public func clearImage() {
		self.image = nil
		self.startedFetch = !urlHasLength(self.imageURL?.absoluteString)
	}
	
	public func fetchImageIfNeeded() {
		if (!startedFetch) {
			fetchImage()
		}
	}
	
	public func fetchImage() {
		self.image = nil
		guard let imageURL = self.imageURL else {
			return
		}
		
		startedFetch = true
		ImageService.fetchImage(imageURL) { [weak self] (success: Bool, image: UIImage?, url: URL) in
			// Only update the image if our current imageURL matches the fetched image's URL
			if (success) {
				if (self?.imageURL == url) {
					self?.image = image
				}
			} else if let backup = self?.backupImageName {
				self?.image = UIImage(named: backup)
			}
		}
	}
	
	// MARK: - Private Helpers
	
	private func urlHasLength(_ url: String?) -> Bool {
		return (url != nil && url!.count > 0)
	}
}

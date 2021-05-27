//
//  ImageService.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-19.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ImageService: BaseService {
	
	static let downloader = ImageDownloader(
		configuration: ImageDownloader.defaultURLSessionConfiguration(),
		downloadPrioritization: .fifo,
		maximumActiveDownloads: 6,
		imageCache: AutoPurgingImageCache()
	)
	
	static func fetchImage(_ url: URL, callback: @escaping (_ success: Bool, _ image: UIImage?, _ imageUrl: URL) -> Void) {
		
		downloader.download(URLRequest(url: url)) { response in
			guard response.error == nil else {
				print("FETCH IMAGE ERROR.  URL:\(url).  \(String(describing: response.error))")
				callback(false, nil, url)
				return
			}
			
			guard let image = response.result.value else {
				print("FETCH IMAGE ERROR.  URL:\(url).  Invalid image data")
				callback(false, nil, url)
				return
			}
			callback(true, image, url)
		}
	}
}

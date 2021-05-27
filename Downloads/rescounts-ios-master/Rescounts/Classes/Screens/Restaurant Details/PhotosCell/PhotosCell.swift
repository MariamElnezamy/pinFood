//
//  PhotosCell.swift
//  Rescounts
//
//  Created by Martin Sorsok on 6/26/20.
//  Copyright © 2020 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
protocol PhotosCellDelegate {
    func galleryTapped(at startingIndex: Int)
}
class PhotosCell: UITableViewCell,  UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var photos: UIView!
    
    var delegate: PhotosCellDelegate?
    private var photoURLs = [URL]()
    let kPhotoSize: CGFloat = 110
    let kMarginSide: CGFloat = 20
    let kMarginTop: CGFloat = 15
    let kSpacer: CGFloat = 10
    let kSectionSpacer: CGFloat = 30
    let kFontSize: CGFloat = 15
    let kLineHeight: CGFloat = 22
    let kSeparatorHeight: CGFloat = 3
    
    @IBOutlet weak var heightOfView: NSLayoutConstraint!
    
    var restaurant: Restaurant? {
         didSet {
            photoURLs = []
             setupPhotos()
         }
     }
    override func awakeFromNib() {
        super.awakeFromNib()
    }

 private func setupPhotos() {
        photos.backgroundColor = .white
        guard let restaurant = self.restaurant else {
              return
          }
        photoURLs = restaurant.restaurantPhotos
        
        let photoCarouselLayout = UICollectionViewFlowLayout()
        photoCarouselLayout.scrollDirection = .vertical
        photoCarouselLayout.headerReferenceSize = CGSize(kMarginSide, kMarginSide)
        photoCarouselLayout.footerReferenceSize = CGSize(kMarginSide, kMarginSide)
        photoCarouselLayout.itemSize = CGSize(kPhotoSize, kPhotoSize)
        photoCarouselLayout.minimumLineSpacing = kSpacer
        photoCarouselLayout.minimumInteritemSpacing = 0
        let heightConstant  = CGFloat(((photoURLs.count/3) * 160.0))

        let photoCarousel = UICollectionView(frame: CGRect(0, kMarginTop, photos.frame.width, heightConstant), collectionViewLayout: photoCarouselLayout)
        photoCarousel.register(RemoteImageCollectionCell.self, forCellWithReuseIdentifier: "cell")
        photoCarousel.backgroundColor = .clear
        photoCarousel.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        photoCarousel.dataSource = self
        photoCarousel.delegate = self
        photoCarousel.isScrollEnabled = false
        photos.addSubview(photoCarousel)
        
        let photoButt = UIButton()
        photoButt.setTitle(l10n("viewPhotos"), for: .normal)
        photoButt.setTitleColor(.dark, for: .normal)
        photoButt.setTitleColor(UIColor.dark.lighter(), for: .highlighted)
        photoButt.titleLabel?.font = UIFont.lightRescounts(ofSize: kFontSize)
        photoButt.contentHorizontalAlignment = .right
        photoButt.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin]
        photoButt.sizeToFit()
        photoButt.frame = CGRect(photos.frame.width - kMarginSide - ceil(photoButt.frame.width), photoCarousel.frame.maxY + kSpacer, ceil(photoButt.frame.width), kLineHeight + kSeparatorHeight)
        photoButt.addAction(for: .touchUpInside) { [weak self] in
            self?.showGallery()
        }
        photos.addSubview(photoButt)
        
        let buttBar = UIView(frame: CGRect(0, photoButt.frame.height - kSeparatorHeight, photoButt.frame.width, kSeparatorHeight))
        buttBar.backgroundColor = .gold
        buttBar.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        photoButt.addSubview(buttBar)
    
//    heightOfView.constant = CGFloat(((photoURLs.count/3) * 120.0))
    
    }
    
        // MARK: - Actions
        
        private func showGallery(at startingIndex: Int = 0) {
            self.delegate?.galleryTapped(at: startingIndex)
        }
        
        // MARK: - UICollectionViewDelegate
        
        public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return photoURLs.count
        }
        
        public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            return cell
        }
        
        public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            if let cell = cell as? RemoteImageCollectionCell {
                cell.contentView.backgroundColor = UIColor(white: 0.97, alpha: 1)
                cell.imageView.contentMode = .scaleAspectFill
                cell.imageView.setImageURL(photoURLs[indexPath.row])
            }
        }
        
        public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            showGallery(at: indexPath.row)
        }
    
    
    }


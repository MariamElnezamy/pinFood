//
//  RestaurantViewController.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-23.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import MapKit

class RestaurantViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
	
	public private(set) var restaurant: Restaurant!
	
	private let tableView = UITableView()
	private let imageCarousel = ImageCarouselView()
	private let detailsView = RestaurantDetailsSummaryView()
	private let reservationView = RestaurantReservationView()
	private let headerContainer = UIView()
	private let footerBG = UIView()
	private let carouselTinter = UIImageView(image: UIImage(named: "carouselGradient"))
	private let sectionTabBar = ScrollingTabBar()
    private let sectionTabBarInfo = ScrollingTabBarInfo()

	private let screenDimmer = UIControl()
	
	private var solidNavBarThreshhold: CGFloat = 200.0
	private let kImageAspect: CGFloat = 16.0 / 9.0
	
	private var menu: Menu?
	public  var needToScrollMenu : Bool = false
	private var isRDeals: Bool = false
    var isInfoMenu = false
    var infoArray = ["Map","Description","Hours of Operations"]
    private let map = MKMapView()
    private let address = UIView(frame: .arbitrary)
    let addressLabel = UILabel()
    let kMapAspect: CGFloat = 2.5
    let kSeparatorHeight: CGFloat = 3
    let kFontSize: CGFloat = 15
    
    
    var infoSectionsArray: [String] = []
    
    var selectedInfoItem: InfoCellType.RawValue = InfoCellType.Map.rawValue
    var isPhotos = false
    var isReviews = false
	// MARK: - Initialization
	
	init(_ restaurant: Restaurant, isRDeals: Bool = false) {
		self.restaurant = restaurant
        self.isRDeals = restaurant.rDealsInfo != nil
		
		super.init(nibName: nil, bundle: nil)
		
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		commonInit()
	}
	
	private func commonInit() {
		tableView.register(MenuTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(MapCell.self, forCellReuseIdentifier: "MapCell")
        tableView.register(UINib(nibName: String(describing: MapCell.self), bundle: .main), forCellReuseIdentifier:  String(describing: MapCell.self))
                tableView.register(UINib(nibName: String(describing: HoursCell.self), bundle: .main), forCellReuseIdentifier:  String(describing: HoursCell.self))
                tableView.register(UINib(nibName: String(describing: DescriptionCell.self), bundle: .main), forCellReuseIdentifier:  String(describing: DescriptionCell.self))
        tableView.register(UINib(nibName: String(describing: PhotosCell.self), bundle: .main), forCellReuseIdentifier:  String(describing: PhotosCell.self))
        tableView.register(UINib(nibName: String(describing: ReviewCell.self), bundle: .main), forCellReuseIdentifier:  String(describing: ReviewCell.self))


		title = restaurant.name
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		reservationView.restaurant = restaurant
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	
	// MARK: - View Controller Methods
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		//let infoImage = UIImage(named: "IconInfo")?.withRenderingMode(.alwaysOriginal)
		//navigationItem.rightBarButtonItem = UIBarButtonItem(image: infoImage, style: .plain, target: self, action: #selector(tappedInfo(_:)))
		
		navBarTinter.backgroundColor = .clear
		view.backgroundColor = .black
		footerBG.backgroundColor = .white
		
		view.addSubview(footerBG)
		
		tableView.backgroundColor = .clear
		tableView.contentInset = .zero
		tableView.contentOffset = .zero
		tableView.dataSource = self
		tableView.delegate = self
		tableView.separatorStyle = .none
		tableView.tableFooterView = UIView()
		view.addSubview(tableView)
		
//		imageCarousel.backupImageName = "RestaurantDefault"
//		imageCarousel.setImageURLs(restaurant.restaurantPhotos)
//		imageCarousel.backgroundColor = .lightGray
//		imageCarousel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedCarousel(_:))))
//
		detailsView.setRestaurant(restaurant)
		
//		carouselTinter.contentMode = .scaleToFill
		
//		headerContainer.addSubview(imageCarousel)
//		headerContainer.addSubview(carouselTinter)
		headerContainer.addSubview(detailsView)
		headerContainer.addSubview(reservationView)
        
        
        
        sectionTabBarInfo.titles = ["Menu","Info","Photos","Reviews"]
        sectionTabBarInfo.didChangeCallback = { [weak self] (tabBar: ScrollingTabBarInfo) -> Void in
//            guard let sSelf = self else { return }
            if tabBar.selectedIndex == 1 {
                self?.isInfoMenu = true
                self?.isPhotos = false
                self?.isReviews = false

                self?.infoSectionsArray = self?.infoArray ?? []
                self?.tableView.reloadData()
            }
            if tabBar.selectedIndex == 2 {
                self?.isInfoMenu = false
                self?.isPhotos = true
                self?.isReviews = false

                self?.infoSectionsArray =  []
                self?.tableView.reloadData()
            }
            if tabBar.selectedIndex == 0 {
                self?.isInfoMenu = false
                self?.isPhotos = false
                self?.isReviews = false
                self?.tableView.reloadData()
            }
            
            if tabBar.selectedIndex == 3 {
                self?.isInfoMenu = false
                self?.isPhotos = false
                self?.isReviews = true
                self?.tableView.reloadData()

            }
//            var index = sSelf.menu?.firstItemIndexForSectionIndex(tabBar.selectedIndex, withRDeals: sSelf.isRDeals) ?? 0
//            if index < 0 { index = 0 }
//            sSelf.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
        }
        
        headerContainer.addSubview(sectionTabBarInfo)

		tableView.tableHeaderView = headerContainer
		
		reservationView.reserveCallback = { [weak self] (numPeople: Int) -> Void in
			self?.tappedReserve(numPeople)
		}
		reservationView.cancelCallback = { [weak self] (numPeople: Int) -> Void in
			self?.tappedCancel()
		}
		reservationView.clipsToBounds = true
		
		screenDimmer.backgroundColor = .dimmedBackground
		screenDimmer.addAction(for: .touchUpInside) { [weak self] in
			self?.showScreenDimmer(false)
		}
		
		MenuService.fetchMenu(restaurantID: restaurant.restaurantID) { [weak self](newMenu: Menu?) in
			self?.menu = newMenu
			self?.tableView.reloadData()
		}
		
		orderStateChanged(nil)
		
		if let trackingDict = GAIDictionaryBuilder.createEvent(withCategory: "page_view", action: "restaurant_main", label: nil, value: nil)?.build() as? [AnyHashable : Any] {
			GAI.sharedInstance()?.defaultTracker.send(trackingDict)
		}

		NotificationCenter.default.addMainObserver(forName: .startedNewTable,   owner: self, action: RestaurantViewController.orderStateChanged)
		NotificationCenter.default.addMainObserver(forName: .approvedTable,     owner: self, action: RestaurantViewController.orderStateChanged)
		NotificationCenter.default.addMainObserver(forName: .endedTable,        owner: self, action: RestaurantViewController.orderStateChanged)
		NotificationCenter.default.addMainObserver(forName: .cancelledTable,    owner: self, action: RestaurantViewController.orderStateChanged)
		NotificationCenter.default.addMainObserver(forName: .startedNewOrder,   owner: self, action: RestaurantViewController.orderStateChanged)
		NotificationCenter.default.addMainObserver(forName: .approvedOrder,     owner: self, action: RestaurantViewController.orderStateChanged)
		NotificationCenter.default.addMainObserver(forName: .declinedOrder,     owner: self, action: RestaurantViewController.orderStateChanged)
		NotificationCenter.default.addMainObserver(forName: .makingReservation, owner: self, action: RestaurantViewController.makingReservation)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        self.view.backgroundColor = .dark
		transitionCoordinator?.animate(alongsideTransition: { [weak self] (context) in
			self?.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
			self?.navigationController?.navigationBar.shadowImage = UIImage()
			self?.navigationController?.navigationBar.backgroundColor = .dark
			self?.navigationController?.navigationBar.barTintColor = .white
			self?.navigationController?.navigationBar.tintColor = .white
			}, completion: nil)
		
		updateNavBarColours()
		
		//Make the menu table view stay unselected after going back to this view
		if let index = tableView.indexPathForSelectedRow {
			tableView.deselectRow(at: index, animated: true)
		}
        self.title = restaurant.name
		//If the previous page is restaurant details page
		//checkIfNeedToGoToMenu() //<--- make the view go to the first menu of the item, but currently we don't want that
		if (needToScrollMenu && !tableView.visibleCells.isEmpty) { //<----------Make the view always stay on the top.
			DispatchQueue.main.async { [weak self] in
				guard let sSelf = self else { return }
				sSelf.tableView.setContentOffset(CGPoint(0, /*-tableView.contentInset.top*/  -sSelf.topLayoutGuide.length), animated: false)
				sSelf.navBarTinter.backgroundColor = UIColor.dark.withAlpha(0)  //Important to set an initial background color to transparent
				sSelf.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(white: 1, alpha: 0)] //Important to set an initial state for the bar text.
				sSelf.needToScrollMenu = false
			}
		}
		
		// If there is table aready, the label should always show the reserved time and number of seats.
		let numPeople = OrderManager.main.currentTable != nil ? (OrderManager.main.currentTable?.numberOfSeats ?? reservationView.numPeople) : reservationView.numPeople
		let seatingAt = OrderManager.main.currentTable != nil ? OrderManager.main.currentTable?.seatingAt ?? reservationView.desiredTime : reservationView.desiredTime
		reservationView.updateData(numPeople: numPeople, desiredTime: seatingAt)
		
		orderStateChanged(nil) // When after checkout and go back to the restaurant view, it should be updated as well.
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		NotificationCenter.default.addMainObserver(forName: .UIKeyboardWillShow, owner: self, action: RestaurantViewController.keyboardWillShow)
		NotificationCenter.default.addMainObserver(forName: .UIKeyboardWillHide, owner: self, action: RestaurantViewController.keyboardWillHide)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		NotificationCenter.default.removeObserver(self)
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		// We check if this would actually change anything because setting the tableView frame affects any in-progress scrolling (same with the table header below)
		if !(tableView.frame.equalTo(view.bounds)) {
			tableView.frame = view.bounds
		}
		
		self.edgesForExtendedLayout = [] // This line only makes the tableview never go across the navigation bar, not a good fix
//		if (!Helper.iosAtLeast("11.0.0")) {
//			tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
//		}
		
//		imageCarousel.frame = CGRect(0.0, -topLayoutGuide.length, view.frame.width, carouselHeight())
//		carouselTinter.frame = CGRect(0.0, imageCarousel.frame.minY, view.frame.width, floor(carouselHeight()/2))
		
		detailsView.frame = CGRect(0, 0 , view.frame.width, detailsView.idealHeight())
		

        
        
		var reservationHeight = OrderManager.main.canShowReserveRestaurantInfo(restaurant.restaurantID) ? reservationView.idealHeight() : 0
		//This is the case that when the user has ordered the menu items, they cannot cancel their table request. Instead hide the button, we want to hide the entire block.
		if (OrderManager.main.currentTable != nil) && (!OrderManager.main.canCancelTable) && (!OrderManager.main.canCancelPickUp) {
			reservationHeight = 0
		}
		reservationView.frame = CGRect(0, detailsView.frame.maxY, view.frame.width, reservationHeight)
        sectionTabBarInfo.frame =  CGRect(0, reservationView.frame.maxY, view.frame.width, 50)

		// We have to change the table header frame in an update block for the new content size to get calculated correctly
		let headerRect = CGRect(0.0, 0.0, view.frame.width, sectionTabBarInfo.frame.maxY)
		if !(headerRect.equalTo(headerContainer.frame)) {
			tableView.beginUpdates()
				headerContainer.frame = headerRect
			tableView.endUpdates()
		}
		
		footerBG.frame = CGRect(0, view.frame.height/2, view.frame.width, view.frame.height)
		
		solidNavBarThreshhold = max(imageCarousel.frame.height + imageCarousel.frame.minY, 50.0)
		
		screenDimmer.frame = view.bounds
        

	}
	
	
	// MARK: - Public Methods
	
	
	// MARK: - Private Helpers
	
	@objc private func tappedInfo(_ sender: Any) {
		let vc = RestaurantDetailsViewController(restaurant: restaurant)
		navigationController?.pushViewController(vc, animated: true)
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	private func carouselHeight() -> CGFloat {
		return floor(UIScreen.main.bounds.width / kImageAspect)
	}
	
	@objc private func tappedCarousel(_ sender: UIGestureRecognizer) {
		let vc = GalleryViewController(imageURLs: restaurant.restaurantPhotos, startingIndex: imageCarousel.currentIndex)
		navigationController?.pushViewController(vc, animated: true)
	}
	
	private func keyboardWillShow(_ notification: Notification?) {
		showScreenDimmer(true)
	}
	
	private func keyboardWillHide(_ notification: Notification?) {
		showScreenDimmer(false)
	}
	
	private func showScreenDimmer(_ show: Bool) {
		if (show && screenDimmer.superview == nil) {
			screenDimmer.alpha = 0
			view.addSubview(screenDimmer)
			UIView.animate(withDuration: 0.1) { [weak self] in
				self?.screenDimmer.alpha = 1
			}
		}
		
		if (!show && screenDimmer.superview != nil) {
			view.endEditing(true)
			UIView.animate(withDuration: 0.1, animations: { [weak self] in
				self?.screenDimmer.alpha = 0
			}) { [weak self] (completed: Bool) in
				self?.screenDimmer.removeFromSuperview()
			}
		}
	}
	
	private func updateNavBarColours() {
		guard !isPopping else { return }
		
//		let adjustedOffset = tableView.contentOffset.y
//		let alpha = (0...1.0).clamp(adjustedOffset / solidNavBarThreshhold)
		navBarTinter.backgroundColor = UIColor.dark
//		navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(white: 1, alpha: alpha*alpha)] // alpha^2 so it fades in slower
	}
	
	private func tappedReserve(_ numPeople: Int) {
		if AccountManager.main.user == nil {
			AccountManager.main.showLoginUI(from: self)
		} else if restaurant.isOpen() {
			showReserveConfirmationScreen(numPeople)
		} else {
			RescountsAlert.showAlert(title: l10n("resClosedWarnTitle"), text: "\(restaurant?.name ?? l10n("theRes"))\(l10n("theResClosedWarnText"))", options: [l10n("no"), l10n("yes")]) { [weak self] (alert, buttonIndex) in
				if (buttonIndex == 1) {
					self?.showReserveConfirmationScreen(numPeople)
				} else {
					self?.navigationController?.popToRootViewController(animated: true)
				}
			}
		}
	}
	
	private func showReserveConfirmationScreen(_ numPeople: Int) {
		let vc = ConfirmReservationViewController(restaurant: restaurant, numPeople: numPeople, desiredTime: reservationView.desiredTime, rDeals: isRDeals)
		navigationController?.pushViewController(vc, animated: true)
	}
	
	private func tappedCancel() {
		RescountsAlert.showAlert(title: "", text: l10n("cancelResPrompt"), icon: nil, postIconText: nil, options: [l10n("cancelResNo"), l10n("cancelResYes")]) { [weak self] (alert, buttonIndex) in
			if buttonIndex == 1 {
				FullScreenSpinner.show()
				self?.reservationView.hideTimer()
				
				if OrderManager.main.currentTable?.pickup ?? false {
					OrderManager.main.cancelPickUp {
						FullScreenSpinner.hideAll()
					}
				} else {
					OrderManager.main.cancelTable {
						FullScreenSpinner.hideAll()
					}
				}

				if let trackingDict = GAIDictionaryBuilder.createEvent(withCategory: "action", action: "cancelled_reservation", label: nil, value: nil)?.build() as? [AnyHashable : Any] {
					GAI.sharedInstance()?.defaultTracker.send(trackingDict)
				}
			}
		}
	}
	
	private func orderStateChanged(_ notification: Notification?) {
		if let table = OrderManager.main.currentTable, table.restaurantID == restaurant.restaurantID {
			if table.approved {
				reservationView.showCheckmark()
			} else {
				reservationView.showSpinner()
			}
		} else {
			reservationView.showButton()
		}
		view.setNeedsLayout() // Since reservationView's height can change
	}
	
	private func makingReservation(_ notification: Notification?) {
		var shouldShowTimer = true
		if let confirmVC = navigationController?.topViewController as? ConfirmReservationViewController {
			reservationView.updateData(numPeople: confirmVC.detailsButton.numPeople, desiredTime: confirmVC.detailsButton.desiredTime)
			shouldShowTimer = confirmVC.detailsButton.numPeople != 0
		}
		
		if shouldShowTimer {
			reservationView.showTimer()
		}
	}
	
	private func checkIfNeedToGoToMenu(){
		if (needToScrollMenu && !tableView.visibleCells.isEmpty) {
			tableView.reloadData()
			DispatchQueue.main.async { [weak self] in
				self?.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
				self?.navBarTinter.backgroundColor = UIColor.dark.withAlpha(1)
				self?.needToScrollMenu = false
			}
		}
	}
	
	// MARK: - UITableViewDelegate
	
	public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		guard let item = menu?.itemForIndex(indexPath.row, withRDeals: isRDeals) else {
			return 0
		}
        if isPhotos {
            let photoURLs = restaurant.restaurantPhotos
            return CGFloat(((photoURLs.count/3) * 160.0))
        }
        if isInfoMenu || isReviews  {
            return  UITableViewAutomaticDimension

        }
        return MenuTableViewCell.heightForItem(item, width: tableView.frame.width, isRDeals: isRDeals)
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
        if isInfoMenu || isPhotos || isReviews {
            return 1

          } else {
              return menu?.numItems(withRDeals: isRDeals) ?? 0
          }
	}
	
	public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return isPhotos || isReviews ? 0 : 50.0
	}
	
	public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		sectionTabBar.frame =  CGRect(0, 0, view.bounds.width, 50)
        
        if isInfoMenu || isReviews {
            sectionTabBar.titles = infoSectionsArray

            sectionTabBar.didChangeCallback = { [weak self] (tabBar: ScrollingTabBar) -> Void in
                guard let sSelf = self else { return }

                sSelf.selectedInfoItem = tabBar.selectedIndex

                sSelf.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
        } else {
            sectionTabBar.titles = menu?.allSections(withRDeals: isRDeals) ?? ["Sections"]
            sectionTabBar.didChangeCallback = { [weak self] (tabBar: ScrollingTabBar) -> Void in
                guard let sSelf = self else { return }

                var index = sSelf.menu?.firstItemIndexForSectionIndex(tabBar.selectedIndex, withRDeals: sSelf.isRDeals) ?? 0
                if index < 0 { index = 0 }
                sSelf.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
            }
        }

		return sectionTabBar
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
        if isInfoMenu {
            switch selectedInfoItem {
            case InfoCellType.Map.rawValue :
                     let cell = tableView.dequeueReusableCell(withIdentifier:  String(describing: MapCell.self), for: indexPath)
                     cell.selectionStyle = .none
                     return cell
            case InfoCellType.Description.rawValue :
                      let cell = tableView.dequeueReusableCell(withIdentifier:  String(describing: DescriptionCell.self), for: indexPath)
                      cell.isUserInteractionEnabled = false
                      cell.selectionStyle = .none
                      return cell
            case InfoCellType.Hours.rawValue :
                          let cell = tableView.dequeueReusableCell(withIdentifier:  String(describing: HoursCell.self), for: indexPath)
                          cell.isUserInteractionEnabled = false
                          cell.selectionStyle = .none
                        return cell
            
            default:
                print("invalid selection")
            }
       
        } else if isPhotos {
            let cell = tableView.dequeueReusableCell(withIdentifier:  String(describing: PhotosCell.self), for: indexPath) as! PhotosCell
//                       cell.isUserInteractionEnabled = false
                       cell.selectionStyle = .none
//            let photoURLs = restaurant.restaurantPhotos
            
            cell.delegate = self
//            cell.heightOfView.constant = CGFloat(((photoURLs.count/3) * 160.0))
//            cell.layoutIfNeeded()
            return cell
        } else if isReviews {
                    let cell = tableView.dequeueReusableCell(withIdentifier:  String(describing: ReviewCell.self), for: indexPath) as! ReviewCell
//                               cell.isUserInteractionEnabled = false
                               cell.selectionStyle = .none
           
                            cell.heightOfTableView.constant = CGFloat(restaurant.reviews.count * 200)
            return cell
                }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		return cell
	}
	
	public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		//If we want to hit go to Menu and directly to the top of menu
		//checkIfNeedToGoToMenu()
         if isInfoMenu {
             switch selectedInfoItem {
             case InfoCellType.Map.rawValue :
                   if let cell = cell as? MapCell {

                                 cell.restaurant = self.restaurant
                             }
             case InfoCellType.Description.rawValue :
                      
                           if let cell = cell as? DescriptionCell {

                                  cell.restaurant = self.restaurant
                            
                              }
             case InfoCellType.Hours.rawValue :
                        if let cell = cell as? HoursCell {

                            cell.restaurant = self.restaurant
                            
                                  }
             
             default:
                 print("invalid selection")
             }
        
         } else if isPhotos {
            if let cell = cell as? PhotosCell {

                                cell.restaurant = self.restaurant
                    }
         } else if isReviews {
            if let cell = cell as? ReviewCell {

                                cell.restaurant = self.restaurant

            }
         }
       else {
		if let cell = cell as? MenuTableViewCell, let item = menu?.itemForIndex(indexPath.row, withRDeals: isRDeals) {
			cell.item = item
			cell.prepareForDisplay(isRDeals: isRDeals)
		} else {
			cell.textLabel?.text = "ERROR - Row \(indexPath.row)"
            }
        }
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let _ = tableView.cellForRow(at: indexPath) as? MapCell {
                return
         }
        
            if let item = menu?.itemForIndex(indexPath.row, withRDeals: isRDeals) {
			print("Selected dish is : \(item.title)  \(item.itemID )")
			
			tableView.deselectRow(at: indexPath, animated: true)
			if let newItem = item.copy() as? MenuItem {
				let vc = MenuOptionsViewController(item: newItem, restaurant: restaurant, rDeals: newItem.rDealsPrice != nil)
				navigationController?.pushViewController(vc, animated: true)
			} else {
				// What? Can't copy?? This is crazy!
				print("ERROR: Couldn't copy item!")
			}
		}
	}
	
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let adjustedOffset = scrollView.contentOffset.y - imageCarousel.frame.minY
		if (adjustedOffset < carouselHeight() || (navBarTinter.backgroundColor?.getAlpha ?? 1) < 0.999) {
			updateNavBarColours()
			
//			if scrollView.contentSize.width > 100 {
//				let imageScalar = max(1, 1-adjustedOffset*0.01)
//				imageCarousel.scrollView.transform = CGAffineTransform(scaleX: imageScalar, y: imageScalar)
//				print ("        adjusted: \(adjustedOffset)  imageScalar: \(imageScalar)  isIdentity: \(CGAffineTransform(scaleX: imageScalar, y: imageScalar).isIdentity)")
//			}
			
		} else {
			// Check if we need to update the section slider
			if (scrollView.isDecelerating || scrollView.isDragging),
				let visibleIndices = tableView.indexPathsForVisibleRows, visibleIndices.count > 0
			{
				let middleIndex = visibleIndices[visibleIndices.count / 3].row
				if let sectionIndex = menu?.sectionForItemIndex(middleIndex, withRDeals: isRDeals) {
					sectionTabBar.selectSection(sectionIndex)
				}
			}
		}
	}
}

enum InfoCellType: Int {
    case Map = 0
    case Description = 1
    case Hours = 2
}

extension RestaurantViewController: PhotosCellDelegate {
    func galleryTapped(at startingIndex: Int) {
        let  photoURLs = restaurant.restaurantPhotos
        let vc = GalleryViewController(imageURLs: photoURLs, startingIndex: startingIndex)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

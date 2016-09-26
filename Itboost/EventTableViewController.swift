//
//  EventTableViewController.swift
//  Itboost
//
//  Created by Admin on 07.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class EventTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timeSegmantedControl: UISegmentedControl!
    @IBOutlet weak var viewMore: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mainActivityIndicator: UIActivityIndicatorView!
    
    var refreshControl:UIRefreshControl!
    var searchBar = UISearchBar()
    
    var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    
    var eventList = [Community]()
    var pictureList = [UIImage]()
    var loadMoreStatus = false
    var currentPostsPage = 1
    var selectedEvent: Community?
    var searchFilter: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create search bar and filter navigation button
        
        createSearchBar()
        
        let filterButton = UIBarButtonItem(image: UIImage(named: "FilterLevers")!.withRenderingMode(.alwaysOriginal), style: UIBarButtonItemStyle.plain, target: self, action: #selector(EventTableViewController.filterButtonDidTouch))
        navigationItem.rightBarButtonItem = filterButton
        
        // Open login/registration window if user is not authorized
        
        if UserDefaults.standard.bool(forKey: Constants.kAlreadyRun) {
            if (UserDefaults.standard.value(forKey: Constants.kUserToken) == nil) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "NavigationEnterScreen") as! UINavigationController
                self.present(viewController, animated: true, completion: nil)
            }
            UserDefaults.standard.set(false,forKey:Constants.kAlreadyRun)
        }
        
        // Set footer for pull to refresh
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.clear
        tableView.addSubview(refreshControl)
        self.tableView.tableFooterView = viewMore
        self.tableView.tableFooterView!.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(EventCollectionViewController.getCommunitiesFromDatabase), name: Constants.LoadCommunitiesNotification, object: nil)
        
        // Make navigation bar translucent
        
        //navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        //navigationController?.navigationBar.shadowImage = UIImage()
        //navigationController?.navigationBar.translucent = true
        
        pictureList = [UIImage(named:"Doge")!]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = Constants.darkMintBlue
        
        if eventList.count == 0 {
            mainActivityIndicator.startAnimating()
        }
        
        //getCommunitiesFromDatabase()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Loading data for table view
    
    /*
    func loadEventsFromServer() {
        
        ServerManager().getOnePageEventsWithPagination(currentPage: self.currentPostsPage, success: { (response) in
            
            let communitiesArray = response as! [AnyObject]
            DataBaseManager().writeAllCommunities(communitiesArray, isLastPage:false)
            self.currentPostsPage += 1
            
            }) { (error) in
                print("Error loading one page events with pagination: " + error!.localizedDescription)
        }
        
    }
    */
    
    func getCommunitiesFromDatabase() {
        
        let dataBaseManager = DataBaseManager()
        managedObjectContext = dataBaseManager.managedObjectContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Community")
        fetchRequest.fetchBatchSize = 10
        let sortDescriptor = NSSortDescriptor(key: "communityID", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if self.searchFilter != nil {
            let filterPredicate = NSPredicate(format: "name CONTAINS[cd] %@", self.searchFilter!)
            fetchRequest.predicate = filterPredicate
        }
        
        do {
            let allCommunities = try managedObjectContext.fetch(fetchRequest) as! [Community]
            eventList.removeAll()
            eventList = allCommunities
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
//                self.loadMoreStatus = false
//                self.activityIndicator.stopAnimating()
//                self.tableView.tableFooterView!.isHidden = true
//                self.mainActivityIndicator.stopAnimating()
            }
            
        } catch {
            print("Collection can't get all communities from database")
        }
        
    }
    
    func createSearchBar() {
        
        searchBar.showsCancelButton = false
        searchBar.delegate = self
        searchBar.enablesReturnKeyAutomatically = false
        
        // Customize view of search bar
        
        searchBar.setImage(UIImage(named:"MagnifyingGlass")!, for: UISearchBarIcon.search, state: UIControlState())
        searchBar.setImage(UIImage(named:"ClearButton")!, for: UISearchBarIcon.clear, state: UIControlState())
        
        searchBar.tintColor = UIColor.white
        searchBar.barTintColor = Constants.backgroundBlue
        searchBar.searchBarStyle = UISearchBarStyle.minimal
        
        for view in searchBar.subviews {
            for subview in view.subviews {
                if subview .isKind(of: UITextField.self) {
                    let searchBarTextField: UITextField = subview as! UITextField
                    searchBarTextField.backgroundColor = Constants.backgroundBlue
                    searchBarTextField.textColor = UIColor.white
                    searchBarTextField.attributedPlaceholder = NSAttributedString(string: "Введите ключ поиска...", attributes: [NSForegroundColorAttributeName:UIColor.white])
                    searchBarTextField.autocapitalizationType = UITextAutocapitalizationType.none
                    //searchBarTextField.layer.cornerRadius = 15
                }
            }
        }
        
        navigationItem.titleView = searchBar
    }
    
    // MARK: Actions
    
    @IBAction func changeEventTimeControl(_ sender: AnyObject) {
    }
    
    func filterButtonDidTouch(_ sender: AnyObject) {
        // Call profile view controller
        self.performSegue(withIdentifier: "openFilters", sender: nil)
    }
    
    // MARK: SearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(false)
        
        if (searchBar.text?.characters.count)! > 0 {
            self.searchFilter = searchBar.text
        } else {
            self.searchFilter = nil
        }
        getCommunitiesFromDatabase()
    }
    
    // MARK: TableView DataSource and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let eventCell = tableView.dequeueReusableCell(withIdentifier: "EventsTableCell", for: indexPath) as! EventsTableCell
        
        let event = eventList[indexPath.item]
        
        eventCell.logoImage.image = nil
        if event.avatarImage != nil {
            //eventCell.logoImage.image = pictureList[0]
            eventCell.logoImage.image = UIImage(data: event.avatarImage!)
        }
        
        eventCell.titleLabel.text = event.name
        
        if event.eventType != nil {
            eventCell.eventTypeLabel.text = event.eventType!
        } 
        
        if event.eventDate != nil {
            eventCell.dateLabel.text = convertDateToText(event.eventDate!)
        }
        
        if let price = event.eventPrice {
            if price != 0 {
                eventCell.priceLabel.text = "\(event.eventPrice!) грн."
            }
        }
        
        if event.eventSpecializations != nil {
            let specializationsArray = NSKeyedUnarchiver.unarchiveObject(with: event.eventSpecializations!) as! [String]
            eventCell.descriptionLabel.text = specializationsArray.joined(separator: ", ")
        }
        
        if event.locations != nil {
            let locationDictionary = NSKeyedUnarchiver.unarchiveObject(with: event.locations!) as! [String:AnyObject]
            let adress = ReusableMethods().convertLocationDictionaryToAdressString(locationDictionary)
            if adress.characters.count > 0 {
                eventCell.adressLabel.text = adress
            }
        }
        
        return eventCell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedEvent = eventList[indexPath.row]
        self.performSegue(withIdentifier: "openEvent", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 151.0
    }
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "openEvent") {
            let viewController = segue.destination as! DetailEventViewController
            let indexPath = tableView.indexPathForSelectedRow
            viewController.communityObject = eventList[(indexPath?.row)!]
            //viewController.communityObject = self.selectedEvent
        } 
        
    }

    // MARK: Helping methods
    
    func convertDateToText(_ date:Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm  dd/MM/yyyy"
        return dateFormatter.string(from: date)
    }
    
    // MARK: Refreshing Table
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 0 {
            loadMore()
        }
    }
    
    func loadMore() {
        if !loadMoreStatus {
            self.loadMoreStatus = true
            self.activityIndicator.startAnimating()
            self.tableView.tableFooterView!.isHidden = false
            loadMoreBegin("Load more",
                          loadMoreEnd: {(x:Int) -> () in
                            self.tableView.reloadData()
                            self.loadMoreStatus = false
                            self.activityIndicator.stopAnimating()
                            self.tableView.tableFooterView!.isHidden = true
            })
        }
    }
    
    func loadMoreBegin(_ newtext:String, loadMoreEnd:@escaping (Int) -> ()) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            print("loadmore")
            
            //if self.currentPostsPage != 1 {
            self.getCommunitiesFromDatabase()
            //}
            
            sleep(2)
            
            DispatchQueue.main.async {
                loadMoreEnd(0)
            }
        }
    }

    
}

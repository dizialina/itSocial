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
    
    var searchBar = UISearchBar()
    
    var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    
    var eventList = [Community]()
    var pictureList = [UIImage]()
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(EventCollectionViewController.getCommunitiesFromDatabase), name: NSNotification.Name(rawValue: Constants.kLoadCommunitiesNotification), object: nil)
        
        // Make navigation bar translucent
        
        //navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        //navigationController?.navigationBar.shadowImage = UIImage()
        //navigationController?.navigationBar.translucent = true
        
        pictureList = [UIImage(named:"Doge")!]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = Constants.darkMintBlue
        
        getCommunitiesFromDatabase()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Loading data for table view
    
    func getCommunitiesFromDatabase() {
        
        let dataBaseManager = DataBaseManager()
        managedObjectContext = dataBaseManager.managedObjectContext
        eventList.removeAll()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Community")
        fetchRequest.fetchBatchSize = 15
        let sortDescriptor = NSSortDescriptor(key: "eventDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let allCommunities = try managedObjectContext.fetch(fetchRequest) as! [Community]
            eventList = allCommunities
            tableView.reloadData()
            
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
    }
    
    // MARK: SearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(false)
    }
    
    // MARK: TableView DataSource and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let eventCell = tableView.dequeueReusableCell(withIdentifier: "EventsTableCell", for: indexPath) as! EventsTableCell
        
        //let event = eventList[indexPath.item]
        
        eventCell.logoImage.image = pictureList[0]
        
        return eventCell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "openEvent", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 151.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "openEvent") {
            let viewController = segue.destination as! DetailEventViewController
            let indexPath = tableView.indexPathForSelectedRow
            viewController.communityObject = eventList[((indexPath as NSIndexPath?)?.row)!]
        }
        
    }

    // MARK: Helping methods
    
    func convertDateToText(_ date:Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter.string(from: date)
    }
    
}

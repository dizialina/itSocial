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
    
    var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
    
    var eventList = [Community]()
    var pictureList = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create search bar and filter navigation button
        
        createSearchBar()
        
        let filterButton = UIBarButtonItem(image: UIImage(named: "FilterLevers")!.imageWithRenderingMode(.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EventTableViewController.filterButtonDidTouch))
        navigationItem.rightBarButtonItem = filterButton
        
        // Open login/registration window if user is not authorized
        
        if NSUserDefaults.standardUserDefaults().boolForKey(Constants.kAlreadyRun) {
            if (NSUserDefaults.standardUserDefaults().valueForKey(Constants.kUserToken) == nil) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewControllerWithIdentifier("NavigationEnterScreen") as! UINavigationController
                self.presentViewController(viewController, animated: true, completion: nil)
            }
            NSUserDefaults.standardUserDefaults().setBool(false,forKey:Constants.kAlreadyRun)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventCollectionViewController.getCommunitiesFromDatabase), name: Constants.kLoadCommunitiesNotification, object: nil)
        
        // Make navigation bar translucent
        
        //navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        //navigationController?.navigationBar.shadowImage = UIImage()
        //navigationController?.navigationBar.translucent = true
        
        pictureList = [UIImage(named:"Doge")!]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = Constants.mintBlue
        
        getCommunitiesFromDatabase()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Loading data for table view
    
    func getCommunitiesFromDatabase() {
        
        let dataBaseManager = DataBaseManager()
        managedObjectContext = dataBaseManager.managedObjectContext
        eventList.removeAll()
        
        let fetchRequest = NSFetchRequest(entityName: "Community")
        fetchRequest.fetchBatchSize = 15
        let sortDescriptor = NSSortDescriptor(key: "eventDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let allCommunities = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Community]
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
        
        searchBar.setImage(UIImage(named:"MagnifyingGlass")!, forSearchBarIcon: UISearchBarIcon.Search, state: UIControlState.Normal)
        searchBar.setImage(UIImage(named:"ClearButton")!, forSearchBarIcon: UISearchBarIcon.Clear, state: UIControlState.Normal)
        
        searchBar.tintColor = UIColor.whiteColor()
        searchBar.barTintColor = Constants.backgroundBlue
        searchBar.searchBarStyle = UISearchBarStyle.Minimal
        
        for view in searchBar.subviews {
            for subview in view.subviews {
                if subview .isKindOfClass(UITextField) {
                    let searchBarTextField: UITextField = subview as! UITextField
                    searchBarTextField.backgroundColor = Constants.backgroundBlue
                    searchBarTextField.textColor = UIColor.whiteColor()
                    searchBarTextField.attributedPlaceholder = NSAttributedString(string: "Введите ключ поиска...", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
                    //searchBarTextField.layer.cornerRadius = 15
                }
            }
        }
        
        navigationItem.titleView = searchBar
    }
    
    // MARK: Actions
    
    @IBAction func changeEventTimeControl(sender: AnyObject) {
    }
    
    func filterButtonDidTouch(sender: AnyObject) {
        // Call profile view controller
    }
    
    // MARK: SearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(false)
    }
    
    // MARK: TableView DataSource and Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return eventList.count
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let eventCell = tableView.dequeueReusableCellWithIdentifier("EventsTableCell", forIndexPath: indexPath) as! EventsTableCell
        
        //let event = eventList[indexPath.item]
        
        eventCell.logoImage.image = pictureList[0]
        
        return eventCell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("openEvent", sender: nil)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 151.0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "openEvent") {
            let viewController = segue.destinationViewController as! DetailEventViewController
            let indexPath = tableView.indexPathForSelectedRow
            viewController.communityObject = eventList[(indexPath?.row)!]
        }
        
    }

    // MARK: Helping methods
    
    func convertDateToText(date:NSDate) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter.stringFromDate(date)
    }
    
}

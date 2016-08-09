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

class EventTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
    
    var communityList = [Community]()
    var pictureList = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if NSUserDefaults.standardUserDefaults().boolForKey(Constants.kAlreadyRun) {
            if (NSUserDefaults.standardUserDefaults().valueForKey(Constants.kUserToken) == nil) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewControllerWithIdentifier("EnterScreenViewController") as! EnterScreenViewController
                self.presentViewController(viewController, animated: true, completion: nil)
            }
            NSUserDefaults.standardUserDefaults().setBool(false,forKey:Constants.kAlreadyRun)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventCollectionViewController.getCommunitiesFromDatabase), name: Constants.kLoadCommunitiesNotification, object: nil)
        
        self.navigationItem.title = "События"
        
        pictureList = [UIImage(named:"PhotoExample1")!]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
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
        communityList.removeAll()
        
        let fetchRequest = NSFetchRequest(entityName: "Community")
        let sortDescriptor = NSSortDescriptor(key: "eventDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let allCommunities = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Community]
            for community in allCommunities {
                communityList.append(community)
            }
            tableView.reloadData()
            
        } catch {
            print("Collection can't get all communities from database")
        }
        
    }
    
    // MARK: TableView DataSource and Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return communityList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let eventCell = tableView.dequeueReusableCellWithIdentifier("EventTableCell", forIndexPath: indexPath) as! EventTableCell
        
        let community = communityList[indexPath.item]
        
        let eventDate = convertDateToText(community.eventDate!)
        let textToShow = "\(community.name) \n\nСостоится: \(eventDate) \nОрганизатор: \(community.createdBy.userName)"
        
        // Make event title bold
        
        let stringToBold = community.name
        let range = (textToShow as NSString).rangeOfString(stringToBold)
        let attributedString = NSMutableAttributedString(string: textToShow)
        let font = UIFont.boldSystemFontOfSize(15)
        attributedString.addAttribute(NSFontAttributeName, value: font, range: range)
        eventCell.descriptionLabel.attributedText = attributedString
        
        // Calculate height of description lable
        
        let title:NSString = textToShow
        let commentHeight = title.heightForText(title, viewWidth: (self.view.frame.width - 125), device: nil)
        let height = commentHeight + 8 * 2
        
        eventCell.logoImage.image = pictureList[0]
        eventCell.heightDescriptionLabel.constant = height
        
        return eventCell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("openEvent", sender: nil)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let community = communityList[indexPath.item]
        
        let eventDate = convertDateToText(community.eventDate!)
        let textToShow = "\(community.name) \n\nСостоится: \(eventDate) \nОрганизатор: \(community.createdBy.userName)"
        
        let title:NSString = textToShow
        
        let commentHeight = title.heightForText(title, viewWidth: (self.view.frame.width - 125), device: nil)
        let height = commentHeight + 8 * 2
        
        guard height > 91.0 else { return 91.0 }
        
        return height
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "openEvent") {
            let viewController = segue.destinationViewController as! DetailEventViewController
            let indexPath = tableView.indexPathForSelectedRow
            viewController.communityObject = communityList[(indexPath?.row)!]
        }
        
    }

    // MARK: Helping methods
    
    func convertDateToText(date:NSDate) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter.stringFromDate(date)
    }
    
}

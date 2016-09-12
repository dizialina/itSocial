//
//  OrganizationsViewController.swift
//  Itboost
//
//  Created by Alina Yehorova on 12.09.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class OrganizationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
    
    var organizationList = [Organization]()
    var pictureList = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OrganizationsViewController.getOrganizationsFromDatabase), name: Constants.kLoadOrganizationsNotification, object: nil)
        
        self.navigationItem.title = "Организации"
        
        pictureList = [UIImage(named:"SadCat")!]
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            LoadPaginaionManager().loadAllOrganizationsFromServer()
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if organizationList.count == 0 {
            activityIndicator.startAnimating()
        }
        getOrganizationsFromDatabase()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Loading data for table view
    
    func getOrganizationsFromDatabase() {
        
        let dataBaseManager = DataBaseManager()
        managedObjectContext = dataBaseManager.managedObjectContext
        organizationList.removeAll()
        
        let fetchRequest = NSFetchRequest(entityName: "Organization")
        fetchRequest.fetchBatchSize = 15
        let sortDescriptor = NSSortDescriptor(key: "organizationID", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let allOrganizations = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Organization]
            organizationList = allOrganizations
            activityIndicator.stopAnimating()
            tableView.reloadData()
            
        } catch {
            print("Collection can't get all organizations from database")
        }
        
    }
    
    // MARK: TableView DataSource and Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return organizationList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let organizationCell = tableView.dequeueReusableCellWithIdentifier("OrganizationTableCell", forIndexPath: indexPath) as! EventTableCell
        
        let organization = organizationList[indexPath.item]
        
        organizationCell.descriptionLabel.text = organization.name
        organizationCell.logoImage.image = pictureList[0]
        
        return organizationCell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //self.performSegueWithIdentifier("openEvent", sender: nil)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 91.0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "openEvent") {
            
        }
        
    }
    
    // MARK: Helping methods
    
    func convertDateToText(date:NSDate) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter.stringFromDate(date)
    }
    
}

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
    
    var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    
    var organizationList = [Organization]()
    var pictureList = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(OrganizationsViewController.getOrganizationsFromDatabase), name: NSNotification.Name(rawValue: Constants.kLoadOrganizationsNotification), object: nil)
        
        self.navigationItem.title = "Организации"
        
        pictureList = [UIImage(named:"SadCat")!]
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
            LoadPaginaionManager().loadAllOrganizationsFromServer()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Loading data for table view
    
    func getOrganizationsFromDatabase() {
        
        let dataBaseManager = DataBaseManager()
        managedObjectContext = dataBaseManager.managedObjectContext
        organizationList.removeAll()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Organization")
        fetchRequest.fetchBatchSize = 15
        let sortDescriptor = NSSortDescriptor(key: "organizationID", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let allOrganizations = try managedObjectContext.fetch(fetchRequest) as! [Organization]
            organizationList = allOrganizations
            activityIndicator.stopAnimating()
            tableView.reloadData()
            
        } catch {
            print("Collection can't get all organizations from database")
        }
        
    }
    
    // MARK: TableView DataSource and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return organizationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let organizationCell = tableView.dequeueReusableCell(withIdentifier: "OrganizationTableCell", for: indexPath) as! EventTableCell
        
        let organization = organizationList[(indexPath as NSIndexPath).item]
        
        let textToShow = "\(organization.name) \n\nОрганизатор: \(organization.createdBy!.userName)"
        
        // Make event title bold
        
        let stringToBold = organization.name
        let range = (textToShow as NSString).range(of: stringToBold)
        let attributedString = NSMutableAttributedString(string: textToShow)
        let font = UIFont.boldSystemFont(ofSize: 15)
        attributedString.addAttribute(NSFontAttributeName, value: font, range: range)
        
        organizationCell.descriptionLabel.attributedText = attributedString
        organizationCell.logoImage.image = pictureList[0]
        
        return organizationCell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.performSegueWithIdentifier("openEvent", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 91.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "openEvent") {
            
        }
        
    }
    
    // MARK: Helping methods
    
    func convertDateToText(_ date:Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter.string(from: date)
    }
    
}

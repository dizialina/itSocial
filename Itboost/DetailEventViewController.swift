//
//  DetailEventViewController.swift
//  Itboost
//
//  Created by Admin on 09.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DetailEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var communityObject: NSManagedObject!
    var isDescriptionOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Событие"
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: TableView DataSource and Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        if indexPath.row == 0 {
        
            let eventCell = tableView.dequeueReusableCellWithIdentifier("DetailEventCell", forIndexPath: indexPath) as! DetailEventCell
            
            let community = communityObject as! Community
        
            eventCell.eventTitle.text = community.name
            eventCell.dateLabel.text = "Состоится: \(convertDateToText(community.eventDate!))"
            eventCell.creatorLabel.text = "Организатор: \(community.createdBy.userName)"
            
            eventCell.detailButton.addTarget(self, action: #selector(DetailEventViewController.openDetailDescription), forControlEvents: UIControlEvents.TouchUpInside)
        
            if isDescriptionOpen {
            
                let detailDescription:NSString = community.detailDescription!
                let detailHeight = detailDescription.heightForText(detailDescription, viewWidth: (self.view.frame.width - 32), device: nil)
            
                eventCell.heightViewDescription.constant = detailHeight
                eventCell.descriptionLabel.text = detailDescription as String
            
            } else {
                eventCell.heightViewDescription.constant = 1.0
                eventCell.descriptionLabel.text = ""
            }
        
            return eventCell
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //self.performSegueWithIdentifier("openMail", sender: nil)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            
            let community = communityObject as! Community
        
            if isDescriptionOpen {
            
                let detailDescription:NSString = community.detailDescription!
                let detailHeight = detailDescription.heightForText(detailDescription, viewWidth: (self.view.frame.width - 32), device: nil)
                return 280.0 + detailHeight
            
            } else {
                return 280.0
            }
            
        } else {
            return 280.0
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "openMail") {
            //let viewController = segue.destinationViewController as! AnswerTaskViewController
            //let indexPath = tableView.indexPathForSelectedRow
        }
        
    }
    
    // MARK: Actions
    
    func openDetailDescription() {
        
        let eventCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DetailEventCell
        let community = communityObject as! Community
        var animationDuration = 0.0
        
        if !isDescriptionOpen {
            isDescriptionOpen = true
            
            let detailDescription:NSString = community.detailDescription!
            let detailHeight = detailDescription.heightForText(detailDescription, viewWidth: (self.view.frame.width - 32), device: nil)
            
            eventCell.heightViewDescription.constant = detailHeight
            eventCell.descriptionLabel.text = community.detailDescription
            animationDuration = 0.4
            
        } else {
            isDescriptionOpen = false
            eventCell.heightViewDescription.constant = 1.0
            animationDuration = 0.3
        }
        
        UIView.animateWithDuration(animationDuration) {
            self.view.layoutIfNeeded()
        }
        
        CATransaction.begin()
        
        tableView.beginUpdates()
        CATransaction.setCompletionBlock {
            if !self.isDescriptionOpen {
                //eventCell.heightViewDescription.constant = 1.0
                eventCell.descriptionLabel.text = ""
            }
        }
        tableView.endUpdates()
        
        CATransaction.commit()
        
        
    }
    
    // MARK: Helping methods
    
    func convertDateToText(date:NSDate) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy 'в' HH:mm"
        return dateFormatter.stringFromDate(date)
    }
    
}


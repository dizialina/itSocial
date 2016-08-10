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

class DetailEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var communityObject: NSManagedObject!
    var isDescriptionOpen = false
    var newPostText = String()
    
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
        return 2
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
                let detailHeight = detailDescription.heightForText(detailDescription, viewWidth: (self.view.frame.width - 32), offset:0.0, device: nil)
            
                eventCell.heightViewDescription.constant = detailHeight
                eventCell.descriptionLabel.text = detailDescription as String
            
            } else {
                eventCell.heightViewDescription.constant = 1.0
                eventCell.descriptionLabel.text = ""
            }
        
            return eventCell
            
        } else if indexPath.row == 1 {
            
            let addPostCell = tableView.dequeueReusableCellWithIdentifier("AddPostToEventCell", forIndexPath: indexPath) as! AddPostToEventCell
            
            addPostCell.sendButton.addTarget(self, action: #selector(DetailEventViewController.sendPostToEvent), forControlEvents: UIControlEvents.TouchUpInside)
            
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
                let detailHeight = detailDescription.heightForText(detailDescription, viewWidth: (self.view.frame.width - 32), offset:0.0, device: nil)
                return 280.0 + detailHeight
            
            } else {
                return 280.0
            }
        
        } else if indexPath.row == 1 {
            return 60.0
        } else {
            return 280.0
        }
        
    }
    
    // MARK: TextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        tableView.reloadData()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        newPostText = textField.text!
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        newPostText = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        newPostText = ""
        return true
    }
    
    // MARK: Actions
    
    func openDetailDescription() {
        
        let eventCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DetailEventCell
        let community = communityObject as! Community
        var animationDuration = 0.0
        
        if !isDescriptionOpen {
            isDescriptionOpen = true
            
            let detailDescription:NSString = community.detailDescription!
            let detailHeight = detailDescription.heightForText(detailDescription, viewWidth: (self.view.frame.width - 32), offset:0.0, device: nil)
            
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
                eventCell.descriptionLabel.text = ""
            }
        }
        tableView.endUpdates()
        
        CATransaction.commit()
        
        
    }
    
    func sendPostToEvent() {
        self.performSegueWithIdentifier("addPostToWall", sender: nil)
    }
    
    // MARK: Helping methods
    
    func convertDateToText(date:NSDate) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy 'в' HH:mm"
        return dateFormatter.stringFromDate(date)
    }
    
    // MARK: Seque
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "addPostToWall") {
            let viewController = segue.destinationViewController as! NewPostViewController
            let community = communityObject as! Community
            viewController.wallThreadID = Int(community.threadID.intValue)
        }
        
    }
    
}


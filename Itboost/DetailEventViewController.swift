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
import Crashlytics

class DetailEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewMore: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var refreshControl:UIRefreshControl!
    
    var communityObject: NSManagedObject!
    var isDescriptionOpen = false
    var newPostText = String()
    var wallPostsArray = [WallPost]()
    var loadMoreStatus = false
    var currentPostsPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Событие"
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.clearColor()
        tableView.addSubview(refreshControl)
        self.tableView.tableFooterView = viewMore
        self.tableView.tableFooterView!.hidden = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        currentPostsPage = 1
        wallPostsArray.removeAll()
        tableView.reloadData()
        getEventWallPosts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Get data methods
    
    func getEventWallPosts() {
        
        let community = communityObject as! Community
        let wallThreadID = Int(community.threadID.intValue)
        
        ServerManager().getEventWallPosts(wallThreadID, currentPage: currentPostsPage, success: { (response) in
            self.wallPostsArray += ResponseParser().parseWallPost(response as! [AnyObject])
            self.currentPostsPage += 1
            self.tableView.reloadData()
        }) { (error) in
            print("Error receiving wall posts from event: " + error!.localizedDescription)
        }
        
    }
    
    // MARK: TableView DataSource and Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + wallPostsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
        
            let eventCell = tableView.dequeueReusableCellWithIdentifier("DetailEventCell", forIndexPath: indexPath) as! DetailEventCell
            
            let community = communityObject as! Community
        
            eventCell.eventTitle.text = community.name
            
            var eventDate = "no date"
            if community.eventDate != nil {
                eventDate = convertDateToText(community.eventDate!)
            }
            eventCell.dateLabel.text = "Состоится: \(eventDate)"
            
            eventCell.creatorLabel.text = "Организатор: \(community.createdBy.userName)"
            
            eventCell.detailButton.addTarget(self, action: #selector(DetailEventViewController.openDetailDescription), forControlEvents: UIControlEvents.TouchUpInside)
            
            eventCell.acceptButton.addTarget(self, action: #selector(DetailEventViewController.joinCommunity(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
            if isDescriptionOpen {
            
                var detailDescription:NSString = ""
                if community.detailDescription != nil {
                    detailDescription = community.detailDescription!
                }
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
            
            return addPostCell
            
        } else {
            
            let wallPostCell = tableView.dequeueReusableCellWithIdentifier("WallPostCell", forIndexPath: indexPath) as! WallPostCell
            
            let wallPost = wallPostsArray[indexPath.row - 2]
            
            if wallPost.postTitle.characters.count > 0 {
                wallPostCell.postTitleLabel.text = wallPost.postTitle
            } else {
                wallPostCell.postTitleLabel.text = "Без названия"
            }
            
            wallPostCell.postDateLabel.text = convertDateToText(wallPost.postedAt)
            wallPostCell.commentsCountLabel.text = "Комментарии (\(wallPost.commentsCount))"
            
            wallPostCell.commentsButton.addTarget(self, action: #selector(DetailEventViewController.openPostComments(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            wallPostCell.commentsButton.tag = wallPost.postID
            
            let postBodyText:NSString = wallPost.postBody
            wallPostCell.postBodyLabel.text = postBodyText as String
            
            let bodyHeight = postBodyText.heightForText(postBodyText, viewWidth: (self.view.frame.width - 35), offset:0.0, device: nil)
            wallPostCell.heightBodyView.constant = bodyHeight
            
            return wallPostCell
            
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //self.performSegueWithIdentifier("openMail", sender: nil)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            
            let community = communityObject as! Community
        
            if isDescriptionOpen {
            
                var detailDescription:NSString = ""
                if community.detailDescription != nil {
                    detailDescription = community.detailDescription!
                }
                
                let detailHeight = detailDescription.heightForText(detailDescription, viewWidth: (self.view.frame.width - 32), offset:0.0, device: nil)
                return 280.0 + detailHeight
            
            } else {
                return 280.0
            }
        
        } else if indexPath.row == 1 {
            return 60.0
        } else {
            
            let wallPost = wallPostsArray[indexPath.row - 2]
            
            let postBodyText:NSString = wallPost.postBody
            let bodyHeight = postBodyText.heightForText(postBodyText, viewWidth: (self.view.frame.width - 35), offset:0.0, device: nil)
            
            guard bodyHeight > 30 else { return 125.0 }
            
            let deltaHeight =  bodyHeight - 30
            return 125.0 + deltaHeight
        }
        
    }
    
    // MARK: Refreshing Table
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
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
            self.tableView.tableFooterView!.hidden = false
            loadMoreBegin("Load more",
                          loadMoreEnd: {(x:Int) -> () in
                            self.tableView.reloadData()
                            self.loadMoreStatus = false
                            self.activityIndicator.stopAnimating()
                            self.tableView.tableFooterView!.hidden = true
            })
        }
    }
    
    func loadMoreBegin(newtext:String, loadMoreEnd:(Int) -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            print("loadmore")
            
            if self.currentPostsPage != 1 {
                self.getEventWallPosts()
            }
            
            sleep(2)
            
            dispatch_async(dispatch_get_main_queue()) {
                loadMoreEnd(0)
            }
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
            
            var detailDescription:NSString = ""
            if community.detailDescription != nil {
                detailDescription = community.detailDescription!
            }
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
    
    func openPostComments(sender: UIButton) {
        self.performSegueWithIdentifier("showPostComments", sender: sender.tag)
    }
    
    func sendPostToEvent() {
        self.performSegueWithIdentifier("addPostToWall", sender: nil)
    }
    
    func joinCommunity(sender: UIButton) {
        
        let community = communityObject as! Community
        let communityID = Int(community.communityID.intValue)
        
        ServerManager().joinCommunity(communityID, success: { (response) in
            //
        }) { (error) in
            print("Error while joining community: " + error!.localizedDescription)
        }
    }
    
    // MARK: Helping methods
    
    func convertDateToText(date:NSDate) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter.stringFromDate(date)
    }
    
    // MARK: Seque
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "addPostToWall") {
            let viewController = segue.destinationViewController as! NewPostViewController
            let community = communityObject as! Community
            viewController.wallThreadID = Int(community.threadID.intValue)
            
        } else if (segue.identifier == "showPostComments") {
            let viewController = segue.destinationViewController as! CommentsViewController
            viewController.postID = sender as! Int
        }
        
    }
    
}


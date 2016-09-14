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
    var wallPostsArray = [WallPost]()
    var loadMoreStatus = false
    var currentPostsPage = 1
    
    let tempDescription = "Ciklum Харьков приглашает всех любителей .NET посетить \"Kharkiv .NET Saturday\", который состоится 16 июля 2016 года в офисе Ciklum. Приглашаем .NET разработчиков провести субботнее утро в компании вкусного кофе, а также юнит-тестирования, Windows Azure и кросс-платформенной разработки."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let community = communityObject as! Community
        self.navigationItem.title = community.name
        self.navigationItem.title = "Workshop «Ретроспектива проекта»"
        
        // Make navigation bar translucent
        
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        let navigationBackgroundView = self.navigationController?.navigationBar.subviews.first
        navigationBackgroundView?.alpha = 0.3
        
        // Set footer for pull to refresh
        
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
        
        ServerManager().getWallPosts(wallThreadID, currentPage: currentPostsPage, success: { (response) in
            self.wallPostsArray += ResponseParser().parseWallPost(response as! [AnyObject])
            self.currentPostsPage += 1
            self.tableView.reloadData()
        }) { (error) in
            print("Error receiving wall posts from event: " + error!.localizedDescription)
        }
        
    }
    
    // MARK: TableView DataSource and Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return 2 + wallPostsArray.count
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
        
            let eventCell = tableView.dequeueReusableCellWithIdentifier("EventDetailTableCell", forIndexPath: indexPath) as! EventDetailTableCell
            
            eventCell.selectionStyle = UITableViewCellSelectionStyle.None
            
            //let community = communityObject as! Community
            
            eventCell.addToCalendarButton.addTarget(self, action: #selector(DetailEventViewController.addToCalendar(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            eventCell.joinEventButton.addTarget(self, action: #selector(DetailEventViewController.joinEvent(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            let font = UIFont.systemFontOfSize(12.0, weight: UIFontWeightMedium)
            let descriptionHeight = tempDescription.heightForText(tempDescription, neededFont:font, viewWidth: (self.view.frame.width - 25), offset:0.0, device: nil)
            
            eventCell.heightDescriptionLabel.constant = descriptionHeight
            eventCell.descriptionLabel.text = tempDescription
            
            // Make avatar images round
            
            let avatarsArray = [eventCell.firstAvatar, eventCell.secondAvatar, eventCell.thirdAvatar, eventCell.fourthAvatar, eventCell.fifthAvatar]
            for avatar in avatarsArray {
                avatar.layer.cornerRadius = avatar.frame.size.width / 2
                avatar.clipsToBounds = true
            }
            
            // Add screenshot of the map
            
            let latitude = 55.675861
            let longitude = 12.584574
            let width = Int(self.view.frame.width - 16)
            let height = 190
            let googleMapData = NSData(contentsOfURL: NSURL(string: "http://maps.googleapis.com/maps/api/staticmap?center=\(latitude)+\(longitude)&zoom=15&size=\(width)x\(height)&sensor=false&markers=color:red%7Clabel:%7C55.675861+12.584574")!)
            
            if googleMapData != nil {
                let mapScreenshot = UIImage(data: googleMapData!)
                eventCell.mapImage.image = mapScreenshot
            }
        
            return eventCell
            
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
            
            //wallPostCell.commentsButton.addTarget(self, action: #selector(DetailEventViewController.openPostComments(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            wallPostCell.commentsButton.tag = wallPost.postID
            
            let postBodyText:NSString = wallPost.postBody
            wallPostCell.postBodyLabel.text = postBodyText as String
            
            let font = UIFont.systemFontOfSize(15.0)
            let bodyHeight = postBodyText.heightForText(postBodyText, neededFont:font, viewWidth: (self.view.frame.width - 35), offset:0.0, device: nil)
            wallPostCell.heightBodyView.constant = bodyHeight
            
            return wallPostCell
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //self.performSegueWithIdentifier("openMail", sender: nil)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // 836
        if indexPath.row == 0 {
            
            //let community = communityObject as! Community
            
            let font = UIFont.systemFontOfSize(12.0, weight: UIFontWeightMedium)
            let descriptionHeight = tempDescription.heightForText(tempDescription, neededFont:font, viewWidth: (self.view.frame.width - 25), offset:0.0, device: nil)
            
            guard descriptionHeight > 10 else { return 825.0 }
            
            let deltaHeight =  descriptionHeight - 10
            return 825.0 + deltaHeight
        
        } else {
            
            let wallPost = wallPostsArray[indexPath.row - 2]
            
            let postBodyText:NSString = wallPost.postBody
            let font = UIFont.systemFontOfSize(15.0)
            let bodyHeight = postBodyText.heightForText(postBodyText, neededFont:font, viewWidth: (self.view.frame.width - 35), offset:0.0, device: nil)
            
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
    
    // MARK: Actions
    
    func addToCalendar(sender: UIButton) {
        
    }
    
    func joinEvent(sender: UIButton) {
        
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


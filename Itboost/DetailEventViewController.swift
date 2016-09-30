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
import GoogleMaps

class DetailEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewMore: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var refreshControl:UIRefreshControl!
    
    var communityObject: NSManagedObject!
    //var communityObject: Community!
    var eventLocation: CLLocationCoordinate2D?
    var wallPostsArray = [WallPost]()
    var loadMoreStatus = false
    var currentPostsPage = 1
    var isJoin = false
    var membersList = [AnyObject]()
    var memberAvatarsArray = [UIImage]()
    var isMembersLoading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let community = communityObject as! Community
        self.navigationItem.title = community.name
        
        let navigationTitleFont = UIFont.systemFont(ofSize: 15)
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:navigationTitleFont]
        
        // Set footer for pull to refresh
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.clear
        tableView.addSubview(refreshControl)
        self.tableView.tableFooterView = viewMore
        self.tableView.tableFooterView!.isHidden = true
        
        // Set event location
        
        let event = communityObject as! Community
        if event.locations != nil {
            let locationDictionary = NSKeyedUnarchiver.unarchiveObject(with: event.locations!) as! [String:AnyObject]
            if let latitude = locationDictionary["latitude"] as? Double {
                if let longitude = locationDictionary["longitude"] as? Double {
                    if latitude != 0 || longitude != 0 {
                        eventLocation = CLLocationCoordinate2DMake(latitude, longitude)
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currentPostsPage = 1
        wallPostsArray.removeAll()
        tableView.reloadData()
        getEventWallPosts()
        getJoiningStatus()
        
        if membersList.count == 0 {
            getMembersList()
        }
        
        // Make navigation bar translucent
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        let navigationBackgroundView = self.navigationController?.navigationBar.subviews.first
        navigationBackgroundView?.alpha = 0.3
        
        navigationController?.hidesBarsOnSwipe = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Get data methods
    
    func getEventWallPosts() {
        
        let community = communityObject as! Community
        let wallThreadID = community.threadID.intValue
        
        ServerManager().getWallPosts(wallThreadID, currentPage: currentPostsPage, success: { (response) in
            let wallPosts = ResponseParser().parseWallPost(response!)
            self.wallPostsArray += wallPosts
            self.currentPostsPage += 1
            
            DispatchQueue.main.async {
                if wallPosts.count > 0 {
                    self.loadPostAvatars(posts: wallPosts)
                }
                self.tableView.reloadData()
            }
        }) { (error) in
            print("Error receiving wall posts from event: " + error!.localizedDescription)
        }
        
    }
    
    func getJoiningStatus() {
        
        let community = communityObject as! Community
        let eventID = community.communityID.intValue
        
        ServerManager().getEvent(eventID, success: { (response) in
            
            if let joiningStatus = response!["status"] as? String {
                
                switch joiningStatus {
                case "WILL_GO":
                    self.isJoin = true
                case "NO_DATA":
                    self.isJoin = false
                default:
                    break
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }) { (error) in
            print("Error receiving wall posts from event: " + error!.localizedDescription)
        }
    }
    
    func getMembersList() {
        
        let community = communityObject as! Community
        let eventID = community.communityID.intValue
        
        ServerManager().getMembersList(eventID, success: { (response) in
            self.membersList = response!
            
            if (response?.count)! > 0 {
                var avatarPaths = [String]()
                
                for i in 0..<response!.count {
                    if response?[i] is [String:AnyObject] {
                        if let avatar = response?[i]["avatar"] as? [String:AnyObject] {
                            if let path = avatar["path"] as? String {
                                avatarPaths.append(path)
                                if avatarPaths.count == 5 {
                                    self.loadAvatarsFromPath(paths: avatarPaths)
                                    break
                                }
                            }
                        }
                    }
                    if i == ((response?.count)! - 1) {
                        self.loadAvatarsFromPath(paths: avatarPaths)
                    }
                }
            } else {
                self.isMembersLoading = false
            }
            
            }) { (error) in
                print("Error receiving members: " + error!.localizedDescription)
        }
    }
    
    func loadAvatarsFromPath(paths:[String]) {
        
        self.memberAvatarsArray.removeAll()
        
        for i in 0..<paths.count {
            let avatarURL = URL(string: Constants.shortLinkToServerAPI + paths[i])
            
            if avatarURL != nil {
                let downloadImageTask = URLSession.shared.dataTask(with: avatarURL!) { (data, response, error) in
                    if data != nil {
                        let avatarImage = UIImage(data: data!)
                        if avatarImage != nil {
                            self.memberAvatarsArray.append(avatarImage!)
                            
                            DispatchQueue.main.async {
                                if i == (paths.count - 1) {
                                    self.isMembersLoading = false
                                }
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
                downloadImageTask.resume()
            }
        }
    }
    
    func loadPostAvatars(posts:[WallPost]) {
        
        for i in 0..<posts.count {
            
            if posts[i].avatarURL != nil {
                let downloadImageTask = URLSession.shared.dataTask(with: posts[i].avatarURL!) { (data, response, error) in
                    if data != nil {
                        let avatarImage = UIImage(data: data!)
                        if avatarImage != nil {
                            posts[i].avatarImage = avatarImage
                            
                            
                            DispatchQueue.main.async {
                                if i == (posts.count - 1) {
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                }
                downloadImageTask.resume()
            }
        }
        
    }
    
    // MARK: TableView DataSource and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + wallPostsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath as NSIndexPath).row == 0 {
        
            let eventCell = tableView.dequeueReusableCell(withIdentifier: "EventDetailTableCell", for: indexPath) as! EventDetailTableCell
            
            eventCell.selectionStyle = UITableViewCellSelectionStyle.none
            
            let event = communityObject as! Community
            
            eventCell.titleLabel.text = event.name
            
            /*
            eventCell.logoImage.isHidden = false
            if event.avatarImage != nil {
                eventCell.logoImage.image = UIImage(data: event.avatarImage!)
            } else if event.eventAvatar != nil {
                if let url = URL(string: event.eventAvatar!) {
                    if let data = try? Data(contentsOf: url) {
                        eventCell.logoImage.image = UIImage(data: data)
                    }
                }
            } else {
                eventCell.logoImage.isHidden = true
                eventCell.authorLabel.text = event.createdBy.userName
            }
            */
            eventCell.logoImage.isHidden = true
            eventCell.authorLabel.text = event.createdBy.userName
            
            if let price = event.eventPrice {
                if price != 0 {
                    eventCell.priceLabel.text = "\(event.eventPrice!) грн."
                }
            }
 
            if event.locations != nil {
                let locationDictionary = NSKeyedUnarchiver.unarchiveObject(with: event.locations!) as! [String:AnyObject]
                let adress = ReusableMethods().convertLocationDictionaryToAdressString(locationDictionary)
                if adress.characters.count > 0 {
                    eventCell.adressLabel.text = adress
                }
            }
            
            if event.eventDate != nil {
                eventCell.timeLabel.text = convertDateToTimeText(event.eventDate!)
                eventCell.dateLabel.text = convertDateToDateText(event.eventDate!)
            }
            
            if event.subscribersCount != nil {
                //eventCell.membersCountLabel.text = "\(event.subscribersCount!)"
                eventCell.membersCountLabel.text = "\(membersList.count)"
            }
            
            // Set actions for cell buttons
            
            eventCell.addToCalendarButton.addTarget(self, action: #selector(DetailEventViewController.addToCalendar(_:)), for: UIControlEvents.touchUpInside)
            
            eventCell.joinEventButton.addTarget(self, action: #selector(DetailEventViewController.joinEvent(_:)), for: UIControlEvents.touchUpInside)
            
            eventCell.addPostButton.addTarget(self, action: #selector(DetailEventViewController.addPost(_:)), for: UIControlEvents.touchUpInside)
            
            eventCell.membersButton.addTarget(self, action: #selector(DetailEventViewController.openMembersList(_:)), for: UIControlEvents.touchUpInside)
            if membersList.count == 0 {
                eventCell.membersButton.isEnabled = false
            } else {
                eventCell.membersButton.isEnabled = true
            }
            if isMembersLoading {
                eventCell.membersActivityIndicator.startAnimating()
            } else {
                eventCell.membersActivityIndicator.stopAnimating()
            }
            
            // Set height of description label
            
            if let detailDescription = event.detailDescription {
                
                let font = UIFont.systemFont(ofSize: 12.0, weight: UIFontWeightMedium)
                let descriptionHeight = detailDescription.heightForText(detailDescription as NSString, neededFont:font, viewWidth: (self.view.frame.width - 20), offset: 2.0, device: nil)
            
                eventCell.heightDescriptionLabel.constant = descriptionHeight
                eventCell.descriptionLabel.text = detailDescription
            }
            
            // Set join button title
            
            if !isJoin {
                eventCell.joinEventButton.setTitle("Я пойду", for: UIControlState.normal)
                eventCell.joinEventButton.backgroundColor = Constants.lightGreenColor
            } else {
                eventCell.joinEventButton.setTitle("Я не пойду", for: UIControlState.normal)
                eventCell.joinEventButton.backgroundColor = Constants.lightGrayColor
            }
            
            // Make avatar images round and show them
            
            let avatarsArray = [eventCell.firstAvatar, eventCell.secondAvatar, eventCell.thirdAvatar, eventCell.fourthAvatar, eventCell.fifthAvatar]
            for i in 0..<avatarsArray.count {
                avatarsArray[i]?.layer.cornerRadius = (avatarsArray[i]?.frame.size.width)! / 2
                avatarsArray[i]?.clipsToBounds = true
                
                if memberAvatarsArray.count > i {
                    avatarsArray[i]?.image = memberAvatarsArray[i]
                } else {
                    if membersList.count > i {
                        avatarsArray[i]?.image = UIImage(named: "AvatarDefault")
                    } else {
                        avatarsArray[i]?.image = nil
                    }
                }
            }
            
            // Add screenshot of the map
            
            var latitude = 50.4501
            var longitude = 30.5234
            if eventLocation != nil {
                latitude = eventLocation!.latitude
                longitude = eventLocation!.longitude
            }
            let width = Int(self.view.frame.width - 16)
            let height = 190
            let googleMapData = try? Data(contentsOf: URL(string: "http://maps.googleapis.com/maps/api/staticmap?center=\(latitude)+\(longitude)&zoom=17&size=\(width)x\(height)&sensor=false&markers=color:red%7Clabel:%7C\(latitude)+\(longitude)")!)
            
            if googleMapData != nil {
                let mapScreenshot = UIImage(data: googleMapData!)
                eventCell.mapImage.image = mapScreenshot
            }
        
            return eventCell
            
        } else {
            
            let wallPostCell = tableView.dequeueReusableCell(withIdentifier: "WallPostCell", for: indexPath) as! WallPostCell
            
            wallPostCell.userAvatar.image = nil
            
            let wallPost = wallPostsArray[(indexPath as NSIndexPath).row - 1]
            
            if wallPost.authorUsername.characters.count > 0 {
                wallPostCell.authorLabel.text = wallPost.authorUsername
            }
            
            wallPostCell.postDateLabel.text = convertDateToDateText(wallPost.postedAt as Date)
            wallPostCell.postTimeLabel.text = convertDateToTimeText(wallPost.postedAt as Date)
            wallPostCell.commentsButton.setTitle("Комментарии (\(wallPost.commentsCount))", for: UIControlState.normal)
            
            // Add actions
            
            wallPostCell.commentsButton.addTarget(self, action: #selector(DetailEventViewController.openPostComments(_:)), for: UIControlEvents.touchUpInside)
            wallPostCell.commentsButton.tag = wallPost.postID
            
            wallPostCell.deletePostButton.addTarget(self, action: #selector(DetailEventViewController.deletePost(_:)), for: UIControlEvents.touchUpInside)
            wallPostCell.deletePostButton.tag = wallPost.postID
            
            // Set height of description label
            
            let postBody = wallPost.postBody
            let font = UIFont.systemFont(ofSize: 12.0)
            let bodyHeight = postBody.heightForText(postBody as NSString, neededFont:font, viewWidth: (self.view.frame.width - 71), offset: 2.0, device: nil)
                
            wallPostCell.heightBodyView.constant = bodyHeight
            wallPostCell.postBodyLabel.text = postBody
            
            // Load avatar
            
            if let avatarImage = wallPost.avatarImage {
                wallPostCell.userAvatar.image = avatarImage
            } else {
                wallPostCell.userAvatar.image = UIImage(named: "AvatarDefault")
            }
            
            // Make avatar image round
            
            wallPostCell.userAvatar.layer.cornerRadius = 40 / 2
            wallPostCell.userAvatar.clipsToBounds = true
            
            return wallPostCell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.performSegueWithIdentifier("openMail", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath as NSIndexPath).row == 0 {
            
            let community = communityObject as! Community
            guard community.detailDescription != nil else { return 868.0 }
            let detailDescription = community.detailDescription!
            
            let font = UIFont.systemFont(ofSize: 12.0, weight: UIFontWeightMedium)
            let descriptionHeight = detailDescription.heightForText(detailDescription as NSString, neededFont:font, viewWidth: (self.view.frame.width - 20), offset: 2.0, device: nil)
            
            guard descriptionHeight > 15 else { return 868.0 }
            
            let deltaHeight =  descriptionHeight - 15
            return 868.0 + deltaHeight
        
        } else {
            
            let wallPost = wallPostsArray[(indexPath as NSIndexPath).row - 1]
            
            let postBody = wallPost.postBody
            let font = UIFont.systemFont(ofSize: 12.0)
            let bodyHeight = postBody.heightForText(postBody as NSString, neededFont:font, viewWidth: (self.view.frame.width - 71), offset: 2.0, device: nil)
           
            guard bodyHeight > 16 else { return 85.0 }
            
            let deltaHeight =  bodyHeight - 16
            return 85.0 + deltaHeight
        }
        
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
            
            if self.currentPostsPage != 1 {
                self.getEventWallPosts()
            }
            
            sleep(2)
            
            DispatchQueue.main.async {
                loadMoreEnd(0)
            }
        }
    }
    
    // MARK: Actions
    
    func openMembersList(_ sender: UIButton) {
        self.performSegue(withIdentifier: "openMembers", sender: nil)
    }

    
    func addToCalendar(_ sender: UIButton) {
        
    }
    
    func joinEvent(_ sender: UIButton) {
        
        let eventCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? EventDetailTableCell
        eventCell?.joinActivityIndicator.startAnimating()
        
        let community = communityObject as! Community
        let eventID = community.communityID.intValue
        
        if !isJoin {
        
            ServerManager().joinEvent(eventID, notSure: 0, success: { (response) in
                print("You successfully joined event \(eventID)!")
                self.isJoin = true
               
                DispatchQueue.main.async {
                    eventCell?.joinEventButton.setTitle("Я не пойду", for: UIControlState.normal)
                    UIView.animate(withDuration: 0.3, animations: {
                        eventCell?.joinEventButton.backgroundColor = Constants.lightGrayColor
                    })
                    eventCell?.joinActivityIndicator.stopAnimating()
                }
            }) { (error) in
                print("Error while joining event: " + error!.localizedDescription)
                eventCell?.joinActivityIndicator.stopAnimating()
            }
            
        } else {
            
            ServerManager().leaveEvent(eventID, success: { (response) in
                print("You successfully leaved event \(eventID)!")
                self.isJoin = false
                
                DispatchQueue.main.async {
                    eventCell?.joinEventButton.setTitle("Я пойду", for: UIControlState.normal)
                    UIView.animate(withDuration: 0.3, animations: {
                        eventCell?.joinEventButton.backgroundColor = Constants.lightGreenColor
                    })
                    eventCell?.joinActivityIndicator.stopAnimating()
                }
            }) { (error) in
                print("Error while leaving event: " + error!.localizedDescription)
                eventCell?.joinActivityIndicator.stopAnimating()
            }
        }
    }
    
    func addPost(_ sender: UIButton) {
        self.performSegue(withIdentifier: "addNewPost", sender: nil)
    }
    
    func openPostComments(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showPostComments", sender: sender.tag)
    }
    
    func deletePost(_ sender: UIButton) {
        
        let postIDToDelete = sender.tag
        
        // Delete post from server
        
        ServerManager().deleteWallPost(postIDToDelete, success: { (response) in
            
            // Delete post from table view if success
            
            DispatchQueue.main.async {
                
                // Detect indexPath for deleted post
                
                var postIndexToDelete: Int?
                var indexPath: IndexPath?
                for wallPost in self.wallPostsArray {
                    if wallPost.postID == postIDToDelete {
                        postIndexToDelete = self.wallPostsArray.index(of: wallPost)!
                        indexPath = IndexPath(row: postIndexToDelete! + 1, section: 0)
                    }
                }
                
                // Delete post from table view and from array
                
                self.tableView.beginUpdates()
                if indexPath != nil {
                    self.wallPostsArray.remove(at: postIndexToDelete!)
                    self.tableView.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.bottom)
                }
                self.tableView.endUpdates()
            }
            
        }) { (error) in
            print("Error while deleting wall post: " + error!.localizedDescription)
        }
        
    }
    
    // MARK: Helping methods
    
    func convertDateToTimeText(_ date:Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
    
    func convertDateToDateText(_ date:Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: date)
    }
    
    // MARK: Seque
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "addNewPost") {
            let viewController = segue.destination as! NewPostViewController
            let community = communityObject as! Community
            viewController.wallThreadID = community.threadID.intValue
            
        } else if (segue.identifier == "showPostComments") {
            let viewController = segue.destination as! CommentsViewController
            viewController.postID = sender as! Int
            
        } else if (segue.identifier == "openMembers") {
            let viewController = segue.destination as! MembersViewController
            viewController.membersResponseList = membersList
        }
        
    }
    
    
}


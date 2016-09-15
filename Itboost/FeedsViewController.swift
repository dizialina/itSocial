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

class FeedsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewMore: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var refreshControl:UIRefreshControl!
    
    var communityObject: NSManagedObject!
    var isDescriptionOpen = false
    var newPostText = String()
    var feedsArray = [WallPost]()
    var loadMoreStatus = false
    var currentPostsPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Мои новости"
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.clear
        tableView.addSubview(refreshControl)
        self.tableView.tableFooterView = viewMore
        self.tableView.tableFooterView!.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currentPostsPage = 1
        feedsArray.removeAll()
        tableView.reloadData()
        getFeeds()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Get data methods
    
    func getFeeds() {
        
        ServerManager().getFeeds(currentPostsPage, success: { (response) in
            self.feedsArray += ResponseParser().parseWallPost(response!)
            self.currentPostsPage += 1
            self.tableView.reloadData()
        }) { (error) in
            print("Error receiving feeds: " + error!.localizedDescription)
        }
        
    }
    
    // MARK: TableView DataSource and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let feedCell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! WallPostCell
            
        let wallPost = feedsArray[(indexPath as NSIndexPath).row]
            
        if wallPost.postTitle.characters.count > 0 {
            feedCell.postTitleLabel.text = wallPost.postTitle
        } else {
            feedCell.postTitleLabel.text = "Без названия"
        }
            
        feedCell.postDateLabel.text = convertDateToText(wallPost.postedAt as Date)
        feedCell.commentsCountLabel.text = "Комментарии (\(wallPost.commentsCount))"
            
        feedCell.commentsButton.addTarget(self, action: #selector(FeedsViewController.openPostComments(_:)), for: UIControlEvents.touchUpInside)
        feedCell.commentsButton.tag = wallPost.postID
            
        let postBodyText:NSString = wallPost.postBody as NSString
        feedCell.postBodyLabel.text = postBodyText as String
        
        let font = UIFont.systemFont(ofSize: 15.0)
        let bodyHeight = postBodyText.heightForText(postBodyText, neededFont:font, viewWidth: (self.view.frame.width - 35), offset:0.0, device: nil)
        feedCell.heightBodyView.constant = bodyHeight
            
        return feedCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.performSegueWithIdentifier("openMail", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            
        let wallPost = feedsArray[(indexPath as NSIndexPath).row]
            
        let postBodyText:NSString = wallPost.postBody as NSString
        let font = UIFont.systemFont(ofSize: 15.0)
        let bodyHeight = postBodyText.heightForText(postBodyText, neededFont:font, viewWidth: (self.view.frame.width - 35), offset:0.0, device: nil)
            
        guard bodyHeight > 30 else { return 125.0 }
            
        let deltaHeight =  bodyHeight - 30
        return 125.0 + deltaHeight
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
                self.getFeeds()
            }
            
            sleep(2)
            
            DispatchQueue.main.async {
                loadMoreEnd(0)
            }
        }
    }
    
    // MARK: Actions
    
    func openPostComments(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
        viewController.postID = sender.tag
        self.navigationController?.pushViewController(viewController, animated: true)
    
    }
    
    // MARK: Helping methods
    
    func convertDateToText(_ date:Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter.string(from: date)
    }
    
    // MARK: Seque
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "showPostComments") {
            let viewController = segue.destination as! CommentsViewController
            viewController.postID = sender as! Int
        }
        
    }
    
}


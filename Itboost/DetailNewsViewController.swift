//
//  DetailNewsViewController.swift
//  Itboost
//
//  Created by Alina Yehorova on 19.09.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit

class DetailNewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newCommentField: UITextField!
    @IBOutlet weak var viewMore: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var refreshControl:UIRefreshControl!
    
    var newsID = Int()
    var currentNews = News()
    var commentsArray = [WallPost]()
    var currentPostsPage = 1
    var loadMoreStatus = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newsID = currentNews.newsID
        
        // Set navigation bar
        
        self.navigationItem.title = currentNews.title
        
        let navigationTitleFont = UIFont.systemFont(ofSize: 15)
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:navigationTitleFont]
        
        navigationController?.navigationBar.barTintColor = UIColor(red:0.78, green:0.89, blue:0.90, alpha:1.0)
        let navigationBackgroundView = self.navigationController?.navigationBar.subviews.first
        navigationBackgroundView?.alpha = 1.0
        
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Set footer for pull to refresh
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.clear
        tableView.addSubview(refreshControl)
        self.tableView.tableFooterView = viewMore
        self.tableView.tableFooterView!.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getNewsComments()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Get data methods
    
    func getNewsComments() {
        
        if currentNews.threadID != 0 {
        
            ServerManager().getWallPosts(currentNews.threadID, currentPage: currentPostsPage, success: { (response) in
                let comments = ResponseParser().parseWallPost(response!)
                self.commentsArray += comments
                self.currentPostsPage += 1
            
                DispatchQueue.main.async {
                    if comments.count > 0 {
                        self.loadPostAvatars(posts: comments)
                    }
                    self.tableView.reloadData()
                }
            }) { (error) in
                print("Error receiving wall posts from news: " + error!.localizedDescription)
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
        return 1 + commentsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath as NSIndexPath).row == 0 {
            
            let newsCell = tableView.dequeueReusableCell(withIdentifier: "DetailNewsCell", for: indexPath) as! DetailNewsCell
            
            if currentNews.authorUsername.characters.count > 0 {
                newsCell.authorLabel.text = currentNews.authorUsername
            }
            
            if currentNews.content.characters.count > 0 {
                newsCell.bodyLabel.text = currentNews.content
            }
            
            if currentNews.title.characters.count > 0 {
                newsCell.titleLabel.text = currentNews.title
            }
            
            newsCell.dateLabel.text = convertDateToTextDate(currentNews.createdAt)
            
            // Set height of post body label
            
            let newsBody = currentNews.content
            
            let font = UIFont.systemFont(ofSize: 13.0)
            let bodyHeight = newsBody.heightForText(newsBody as NSString, neededFont:font, viewWidth: (self.view.frame.width - 16), offset: 2.0, device: nil)
            
            newsCell.heightBodyLabel.constant = bodyHeight
            newsCell.bodyLabel.text = newsBody
            
            if bodyHeight > 25 {
                let deltaHeight =  bodyHeight - 25
                newsCell.heightMainInfoView.constant += deltaHeight
            }
            
            // Make avatar image round
            
            newsCell.authorAvatar.layer.cornerRadius = 33 / 2
            newsCell.authorAvatar.clipsToBounds = true
            
            // Make shadow for background view
            
            newsCell.mainInfoView.layer.shadowColor = UIColor.black.cgColor
            newsCell.mainInfoView.layer.shadowRadius = 1.0
            newsCell.mainInfoView.layer.shadowOpacity = 0.1
            newsCell.mainInfoView.layer.shadowOffset = CGSize(width: 0, height: 0)
            newsCell.mainInfoView.clipsToBounds = false
            newsCell.mainInfoView.layer.shadowPath = UIBezierPath(rect: newsCell.mainInfoView.layer.bounds).cgPath
            
            return newsCell
            
        } else {
            
            let commentCell = tableView.dequeueReusableCell(withIdentifier: "CommentNewsCell", for: indexPath) as! CommentCell
            
            let postComment = commentsArray[(indexPath as NSIndexPath).row - 1]
            
            commentCell.commentAuthorLabel.text = "От: \(postComment.authorUsername)"
            commentCell.commentDateLabel.text = convertDateToCommentDate(postComment.postedAt as Date)
            
            commentCell.deleteCommentButton.addTarget(self, action: #selector(CommentsViewController.deleteComment(_:)), for: UIControlEvents.touchUpInside)
            commentCell.deleteCommentButton.tag = postComment.postID
            
            // Set height of comment text
            
            let commentBodyText = postComment.postBody
            let font = UIFont.systemFont(ofSize: 12.0)
            let bodyHeight = commentBodyText.heightForText(commentBodyText as NSString, neededFont:font, viewWidth: (self.view.frame.width - 71), offset: 2.0, device: nil)
            
            commentCell.heightBodyView.constant = bodyHeight
            commentCell.commentBodyLabel.text = commentBodyText
            
            // Load avatar
            
            if let avatarImage = postComment.avatarImage {
                commentCell.avatarImage.image = avatarImage
            } else {
                commentCell.avatarImage.image = UIImage(named: "AvatarDefault")
            }
            
            // Make avatar image round
            
            commentCell.avatarImage.layer.cornerRadius = 40 / 2
            commentCell.avatarImage.clipsToBounds = true
            
            return commentCell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath as NSIndexPath).row == 0 {
            
            let newsBody = currentNews.content
            
            let font = UIFont.systemFont(ofSize: 13.0)
            let bodyHeight = newsBody.heightForText(newsBody as NSString, neededFont:font, viewWidth: (self.view.frame.width - 16), offset: 2.0, device: nil)
            
            guard bodyHeight > 25 else { return 318.0 }
            
            let deltaHeight =  bodyHeight - 25
            return 318.0 + deltaHeight
            
        } else {
            
            let postComment = commentsArray[indexPath.row - 1]
            
            let commentBodyText = postComment.postBody
            let font = UIFont.systemFont(ofSize: 12.0)
            let bodyHeight = commentBodyText.heightForText(commentBodyText as NSString, neededFont:font, viewWidth: (self.view.frame.width - 71), offset:2.0, device: nil)
            
            guard bodyHeight > 16 else { return 84.0 }
            
            let deltaHeight =  bodyHeight - 16
            return 84.0 + deltaHeight
        }
    }
    
    // MARK: TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Actions
    
    @IBAction func sendComment(_ sender: AnyObject) {
        
        if newCommentField.text!.characters.count > 0 {
            
            let threadIDsDict = ["id": currentNews.threadID]
            
            ServerManager().postNewMessageOnWall(threadIDsDict, title: "", body: newCommentField.text!, success: { (response) in
                
                self.currentPostsPage = 1
                self.commentsArray.removeAll()
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.newCommentField.text = ""
                }
                
                self.getNewsComments()
                
            }, failure: { (error) in
                print("Error while adding new comment: " + error!.localizedDescription)
            })
            
        }
        
    }
    
    func deleteComment(_ sender: UIButton) {
        
        let postIDToDelete = sender.tag
        
        // Delete post from server
        
        ServerManager().deleteWallPost(postIDToDelete, success: { (response) in
            
            // Delete post from table view if success
            
            DispatchQueue.main.async {
                
                // Detect indexPath for deleted post
                
                var postIndexToDelete: Int?
                var indexPath: IndexPath?
                for wallPost in self.commentsArray {
                    if wallPost.postID == postIDToDelete {
                        postIndexToDelete = self.commentsArray.index(of: wallPost)!
                        indexPath = IndexPath(row: postIndexToDelete! + 1, section: 0)
                    }
                }
                
                // Delete post from table view and from array
                
                self.tableView.beginUpdates()
                if indexPath != nil {
                    self.commentsArray.remove(at: postIndexToDelete!)
                    self.tableView.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.bottom)
                }
                self.tableView.endUpdates()
            }
            
        }) { (error) in
            print("Error while deleting comment: " + error!.localizedDescription)
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
                self.getNewsComments()
            }
            
            sleep(2)
            
            DispatchQueue.main.async {
                loadMoreEnd(0)
            }
        }
    }
    
    // MARK: Helping methods
    
    func convertDateToCommentDate(_ date:Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm dd/MM/yyyy"
        return dateFormatter.string(from: date)
    }
    
    func convertDateToTextDate(_ date:Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM в HH:mm"
        return dateFormatter.string(from: date)
    }
    
    // MARK: Seque
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
}




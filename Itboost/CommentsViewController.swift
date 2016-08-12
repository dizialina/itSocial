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

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newCommentField: UITextField!
    
    var postID = Int()
    var currentPost = WallPost()
    var commentsArray = [PostComment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Запись на стене"
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        getPostComments()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Get data methods
    
    func getPostComments() {
        
        ServerManager().getPostComments(postID, success: { (response) in
            
            let postDictionary = response as! [String:AnyObject]
            let postObjectsArray = ResponseParser().parseWallPost([postDictionary])
            if postObjectsArray.count > 0 {
                self.currentPost = postObjectsArray.first!
            }
            
            let commentsObjectsArray = postDictionary["comments"] as! [AnyObject]
            self.commentsArray = ResponseParser().parsePostComments(commentsObjectsArray)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
            
        }) { (error) in
            print("Error receiving current post from event: " + error!.localizedDescription)
        }
        
    }
    
    // MARK: TableView DataSource and Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + commentsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let wallPostCell = tableView.dequeueReusableCellWithIdentifier("WallPostCell", forIndexPath: indexPath) as! WallPostCell
            
            if currentPost.postTitle.characters.count > 0 {
                wallPostCell.postTitleLabel.text = currentPost.postTitle
            } else {
                wallPostCell.postTitleLabel.text = "Без названия"
            }
            
            wallPostCell.postDateLabel.text = convertDateToText(currentPost.postedAt)
            wallPostCell.commentsCountLabel.text = "Комментарии (\(currentPost.commentsCount))"
            
            let postBodyText:NSString = currentPost.postBody
            wallPostCell.postBodyLabel.text = postBodyText as String
            
            let bodyHeight = postBodyText.heightForText(postBodyText, viewWidth: (self.view.frame.width - 35), offset:0.0, device: nil)
            wallPostCell.heightBodyView.constant = bodyHeight
            
            return wallPostCell
            
        } else {
            
            let commentCell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
            
            let postComment = commentsArray[indexPath.row - 1]
            
            commentCell.commentAuthorLabel.text = "От: \(postComment.authorUsername)"
            commentCell.commentDateLabel.text = convertDateToText(postComment.postedAt)
            
            let commentBodyText:NSString = postComment.commentBody
            commentCell.commentBodyLabel.text = commentBodyText as String
            
            let bodyHeight = commentBodyText.heightForText(commentBodyText, viewWidth: (self.view.frame.width - 35), offset:0.0, device: nil)
            commentCell.heightBodyView.constant = bodyHeight
            
            return commentCell
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            
            let postBodyText:NSString = currentPost.postBody
            let bodyHeight = postBodyText.heightForText(postBodyText, viewWidth: (self.view.frame.width - 35), offset:0.0, device: nil)
            
            guard bodyHeight > 30 else { return 125.0 }
            
            let deltaHeight =  bodyHeight - 30
            return 125.0 + deltaHeight
            
        } else {
            
            let postComment = commentsArray[indexPath.row - 1]
            
            let commentBodyText:NSString = postComment.commentBody
            let bodyHeight = commentBodyText.heightForText(commentBodyText, viewWidth: (self.view.frame.width - 35), offset:0.0, device: nil)
            
            guard bodyHeight > 30 else { return 98.0 }
            
            let deltaHeight =  bodyHeight - 30
            return 98.0 + deltaHeight
        }
        
    }
    
    // MARK: TextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Actions
    
    @IBAction func sendComment(sender: AnyObject) {
        
        if newCommentField.text!.characters.count > 0 {
            
            ServerManager().postComment(postID, commentText: newCommentField.text!, success: { (response) in
                self.newCommentField.text = ""
                self.getPostComments()
            }, failure: { (error) in
                print("Error sending comment to post: " + error!.localizedDescription)
            })
            
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
    }
    
}



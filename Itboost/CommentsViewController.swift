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
    
    override func viewWillAppear(_ animated: Bool) {
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
            let postObjectsArray = ResponseParser().parseWallPost([postDictionary as AnyObject])
            if postObjectsArray.count > 0 {
                self.currentPost = postObjectsArray.first!
            }
            
            let commentsObjectsArray = postDictionary["comments"] as! [AnyObject]
            self.commentsArray = ResponseParser().parsePostComments(commentsObjectsArray)
            
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
            
        }) { (error) in
            print("Error receiving current post from event: " + error!.localizedDescription)
        }
        
    }
    
    // MARK: TableView DataSource and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + commentsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath as NSIndexPath).row == 0 {
            
            let wallPostCell = tableView.dequeueReusableCell(withIdentifier: "WallPostCell", for: indexPath) as! WallPostCell
            
            if currentPost.postTitle.characters.count > 0 {
                wallPostCell.postTitleLabel.text = currentPost.postTitle
            } else {
                wallPostCell.postTitleLabel.text = "Без названия"
            }
            
            wallPostCell.postDateLabel.text = convertDateToText(currentPost.postedAt as Date)
           // wallPostCell.commentsCountLabel.text = "Комментарии (\(currentPost.commentsCount))"
            
            let postBodyText:NSString = currentPost.postBody as NSString
            wallPostCell.postBodyLabel.text = postBodyText as String
            
            let font = UIFont.systemFont(ofSize: 15.0)
            let bodyHeight = postBodyText.heightForText(postBodyText, neededFont:font, viewWidth: (self.view.frame.width - 35), offset:0.0, device: nil)
            wallPostCell.heightBodyView.constant = bodyHeight
            
            return wallPostCell
            
        } else {
            
            let commentCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
            
            let postComment = commentsArray[(indexPath as NSIndexPath).row - 1]
            
            commentCell.commentAuthorLabel.text = "От: \(postComment.authorUsername)"
            commentCell.commentDateLabel.text = convertDateToText(postComment.postedAt as Date)
            
            let commentBodyText:NSString = postComment.commentBody as NSString
            commentCell.commentBodyLabel.text = commentBodyText as String
            
            let font = UIFont.systemFont(ofSize: 15.0)
            let bodyHeight = commentBodyText.heightForText(commentBodyText, neededFont:font, viewWidth: (self.view.frame.width - 35), offset:0.0, device: nil)
            commentCell.heightBodyView.constant = bodyHeight
            
            return commentCell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath as NSIndexPath).row == 0 {
            
            let postBodyText:NSString = currentPost.postBody as NSString
            let font = UIFont.systemFont(ofSize: 15.0)
            let bodyHeight = postBodyText.heightForText(postBodyText, neededFont:font, viewWidth: (self.view.frame.width - 35), offset:0.0, device: nil)
            
            guard bodyHeight > 30 else { return 125.0 }
            
            let deltaHeight =  bodyHeight - 30
            return 125.0 + deltaHeight
            
        } else {
            
            let postComment = commentsArray[(indexPath as NSIndexPath).row - 1]
            
            let commentBodyText:NSString = postComment.commentBody as NSString
            let font = UIFont.systemFont(ofSize: 15.0)
            let bodyHeight = commentBodyText.heightForText(commentBodyText, neededFont:font, viewWidth: (self.view.frame.width - 35), offset:0.0, device: nil)
            
            guard bodyHeight > 30 else { return 98.0 }
            
            let deltaHeight =  bodyHeight - 30
            return 98.0 + deltaHeight
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
            
            ServerManager().postComment(postID, commentText: newCommentField.text!, success: { (response) in
                self.newCommentField.text = ""
                self.getPostComments()
            }, failure: { (error) in
                print("Error sending comment to post: " + error!.localizedDescription)
            })
            
        }
        
    }
    
    // MARK: Helping methods
    
    func convertDateToText(_ date:Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter.string(from: date)
    }
    
    // MARK: Seque
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
}



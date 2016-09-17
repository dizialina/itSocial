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
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        navigationController?.navigationBar.barTintColor = Constants.darkMintBlue
        let navigationBackgroundView = self.navigationController?.navigationBar.subviews.first
        navigationBackgroundView?.alpha = 1.0
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
            print("Error receiving post comments from event: " + error!.localizedDescription)
        }
        
    }
    
    // MARK: TableView DataSource and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + commentsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath as NSIndexPath).row == 0 {
            
            let wallPostCell = tableView.dequeueReusableCell(withIdentifier: "WallPostCellDetail", for: indexPath) as! WallPostCell
            
            if currentPost.postTitle.characters.count > 0 {
                wallPostCell.postTitleLabel.text = currentPost.postTitle
            }
            
            if currentPost.authorUsername.characters.count > 0 {
                wallPostCell.authorLabel.text = currentPost.authorUsername
            }
            
            wallPostCell.commentsCountLabel.text = "\(currentPost.commentsCount) комментариев"
            wallPostCell.postDateLabel.text = convertDateToDateText(currentPost.postedAt as Date)
            wallPostCell.postTimeLabel.text = convertDateToTimeText(currentPost.postedAt as Date)
            
            wallPostCell.deletePostButton.addTarget(self, action: #selector(DetailEventViewController.deletePost(_:)), for: UIControlEvents.touchUpInside)
            wallPostCell.deletePostButton.tag = currentPost.postID
            
            // Set height of post body label
            
            let postBody = currentPost.postBody
            let font = UIFont.systemFont(ofSize: 12.0)
            let bodyHeight = postBody.heightForText(postBody as NSString, neededFont:font, viewWidth: (self.view.frame.width - 71), offset:2.0, device: nil)
            
            wallPostCell.heightBodyView.constant = bodyHeight
            wallPostCell.postBodyLabel.text = postBody
            
            // Make avatar image round
            
            wallPostCell.userAvatar.layer.cornerRadius = 40 / 2
            wallPostCell.userAvatar.clipsToBounds = true
            
            return wallPostCell
            
        } else {
            
            let commentCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
            
            let postComment = commentsArray[(indexPath as NSIndexPath).row - 1]
            
            commentCell.commentAuthorLabel.text = "От: \(postComment.authorUsername)"
            commentCell.commentDateLabel.text = convertDateToFullDateFormat(postComment.postedAt as Date)
            
            // Set height of comment text
            
            let commentBodyText = postComment.commentBody
            let font = UIFont.systemFont(ofSize: 12.0)
            let bodyHeight = commentBodyText.heightForText(commentBodyText as NSString, neededFont:font, viewWidth: (self.view.frame.width - 71), offset:2.0, device: nil)
            
            commentCell.heightBodyView.constant = bodyHeight
            commentCell.commentBodyLabel.text = commentBodyText
            
            // Make avatar image round
            
            commentCell.avatarImage.layer.cornerRadius = 40 / 2
            commentCell.avatarImage.clipsToBounds = true
            
            return commentCell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath as NSIndexPath).row == 0 {
            
            let postBody = currentPost.postBody
            let font = UIFont.systemFont(ofSize: 12.0)
            let bodyHeight = postBody.heightForText(postBody as NSString, neededFont:font, viewWidth: (self.view.frame.width - 71), offset:2.0, device: nil)
            
            guard bodyHeight > 16 else { return 112.0 }
            
            let deltaHeight =  bodyHeight - 16
            return 112.0 + deltaHeight
            
        } else {
            
            let postComment = commentsArray[(indexPath as NSIndexPath).row - 1]
            
            let commentBodyText = postComment.commentBody
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
            
            ServerManager().postComment(postID, commentText: newCommentField.text!, success: { (response) in
                self.newCommentField.text = ""
                self.getPostComments()
            }, failure: { (error) in
                print("Error sending comment to post: " + error!.localizedDescription)
            })
            
        }
        
    }
    
    func deletePost(_ sender: UIButton) {
        
        let postIDToDelete = sender.tag
        
        // Delete post from server
        
        ServerManager().deleteWallPost(postIDToDelete, success: { (response) in
            
            DispatchQueue.main.async {
                 _ = self.navigationController?.popViewController(animated: true)
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
    
    func convertDateToFullDateFormat(_ date:Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm dd/MM/yyyy"
        return dateFormatter.string(from: date)
    }
    
    // MARK: Seque
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
}



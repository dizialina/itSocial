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
    
    var newsID = Int()
    var currentNews = News()
    var commentsArray = [PostComment]()
    
    // Temp
    let articleText = "Прокрастинация — склонность откладывать дел на потом, несмотря на очевидные негативные последствия такого бездействия, — превратилась в глобальную проблему: по некоторым данным, каждый пятый человек страдает ею хронически. Прокрастинацию связывают с нарушением мотивации — результата совместной работы систем сознательного контроля и эмоциональной стимуляции. Волевую сферу связывают с деятельностью префронтальной коры, а эмоциональную — с лимбической системой мозга. Поэтому Тинъюн Фэн (Tingyong Feng) и его коллеги из Юго-Западного университета в китайском Чунцине предположили, что у людей, больше или меньше склонных к прокрастинации, отличия в поведении должны коррелировать с активностью этих областей мозга, а также с «силой» связей между ними."
    
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
        
        // Need to rewrite when backend add comments to news
        
        /*
        ServerManager().getPostComments(newsID, success: { (response) in
            
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
        */
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
            commentCell.deleteCommentButton.tag = postComment.commentID
            
            // Set height of comment text
            
            let commentBodyText = postComment.commentBody
            let font = UIFont.systemFont(ofSize: 12.0)
            let bodyHeight = commentBodyText.heightForText(commentBodyText as NSString, neededFont:font, viewWidth: (self.view.frame.width - 71), offset: 2.0, device: nil)
            
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
            
            let newsBody = currentNews.content
            
            let font = UIFont.systemFont(ofSize: 13.0)
            let bodyHeight = newsBody.heightForText(newsBody as NSString, neededFont:font, viewWidth: (self.view.frame.width - 16), offset: 2.0, device: nil)
            
            guard bodyHeight > 25 else { return 318.0 }
            
            let deltaHeight =  bodyHeight - 25
            return 318.0 + deltaHeight
            
        } else {
            
            let postComment = commentsArray[indexPath.row - 1]
            
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
            
            // Need to rewrite when backend add comments to news
            
            /*
            ServerManager().postComment(newsID, commentText: newCommentField.text!, success: { (response) in
                self.newCommentField.text = ""
                self.getPostComments()
                }, failure: { (error) in
                    print("Error sending comment to post: " + error!.localizedDescription)
            })
            */
            
        }
        
    }
    
    func deleteComment(_ sender: UIButton) {
        
        let commentIDToDelete = sender.tag
        
        // Delete post from server
        
        ServerManager().deleteWallComment(commentIDToDelete, success: { (response) in
            
            // Delete post from table view if success
            
            DispatchQueue.main.async {
                
                // Detect indexPath for deleted comment
                
                var commentIndexToDelete: Int?
                var indexPath: IndexPath?
                for postComment in self.commentsArray {
                    if postComment.commentID == commentIDToDelete {
                        commentIndexToDelete = self.commentsArray.index(of: postComment)!
                        indexPath = IndexPath(row: commentIndexToDelete! + 1, section: 0)
                    }
                }
                
                // Delete comment from table view and from array
                
                self.tableView.beginUpdates()
                if indexPath != nil {
                    self.commentsArray.remove(at: commentIndexToDelete!)
                    self.tableView.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.bottom)
                }
                self.tableView.endUpdates()
            }
            
        }) { (error) in
            print("Error while deleting wall comment: " + error!.localizedDescription)
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




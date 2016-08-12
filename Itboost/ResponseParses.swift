//
//  ResponseParses.swift
//  Itboost
//
//  Created by Admin on 10.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation

class ResponseParser {
    
    func parseWallPost(response: [AnyObject]) -> [WallPost] {
        
        var postsArray = [WallPost]()
        
        if response.count > 0 {
            
            for wallPost in response {
                
                let currentWallPost = wallPost as! [String:AnyObject]
                let newPost = WallPost()
                
                newPost.postID = currentWallPost["id"] as! Int
                
                if let postTitle = currentWallPost["title"] as? String {
                    newPost.postTitle = postTitle 
                }
                
                if let postBody = currentWallPost["body"] as? String {
                    newPost.postBody = postBody
                }
                
                let comments = currentWallPost["comments"] as! [AnyObject]
                if comments.count > 0 {
                    newPost.commentsArray = comments
                    newPost.commentsCount = comments.count
                }
                
                let postedAtString = currentWallPost["posted_at"] as! String
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                newPost.postedAt = dateFormatter.dateFromString(postedAtString)!
                
                let author = currentWallPost["author"] as! [String:AnyObject]
                if let authorUsername = author["username"] {
                    newPost.authorUsername = authorUsername as! String
                }
                
                postsArray.append(newPost)
            }
            
        }
        
        return postsArray
    }
    
    func parsePostComments(response: [AnyObject]) -> [PostComment] {
        
        var commentsArray = [PostComment]()
        
        if response.count > 0 {
            
            for postComment in response {
                
                let currentPostComment = postComment as! [String:AnyObject]
                let newComment = PostComment()
                
                newComment.commentBody = currentPostComment["body"] as! String
                newComment.commentID = currentPostComment["id"] as! Int
                
                let postedAtString = currentPostComment["posted_at"] as! String
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                newComment.postedAt = dateFormatter.dateFromString(postedAtString)!
                
                let author = currentPostComment["author"] as! [String:AnyObject]
                if let authorUsername = author["username"] {
                    newComment.authorUsername = authorUsername as! String
                }
                
                commentsArray.append(newComment)
            }
            
        }
        
        return commentsArray
    }
    
}

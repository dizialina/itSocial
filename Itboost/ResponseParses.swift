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
                if let authorUsername = author["username"] as? String {
                    newPost.authorUsername = authorUsername
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
                if let authorUsername = author["username"] as? String {
                    newComment.authorUsername = authorUsername
                }
                
                commentsArray.append(newComment)
            }
            
        }
        
        return commentsArray
    }
    
    func parseNews(response: [AnyObject]) -> [News] {
        
        var newsArray = [News]()
        
        if response.count > 0 {
            
            for news in response {
                
                let currentNews = news as! [String:AnyObject]
                let newNews = News()
                
                newNews.newsID = currentNews["id"] as! Int
                
                if let newsTitle = currentNews["title"] as? String {
                    newNews.title = newsTitle
                }
                
                if let newsContent = currentNews["content"] as? String {
                    newNews.content = newsContent
                }
                
                if let newsImageURL = currentNews["image"] as? String {
                    newNews.imageURL = newsImageURL
                }
                
                if let newsTypeString = currentNews["type"] as? String {
                    if let newsType = NewsType(rawValue: newsTypeString) {
                        newNews.type = newsType
                    }
                }
                
                let tags = currentNews["tags"] as! [String]
                if tags.count > 0 {
                    newNews.tagsArray = tags
                }
                
                if let viewsCount = currentNews["views_count"] as? Int {
                    newNews.viewsCount = viewsCount
                }
                
                let createdAtString = currentNews["created_at"] as! String
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                newNews.createdAt = dateFormatter.dateFromString(createdAtString)!
                
                let author = currentNews["owner"] as! [String:AnyObject]
                if let authorUsername = author["username"] as? String {
                    newNews.authorUsername = authorUsername
                }
                if let authorID = author["id"] as? Int {
                    newNews.authorID = authorID
                }
                
                newsArray.append(newNews)
            }
            
        }
        
        return newsArray
    }
    
}

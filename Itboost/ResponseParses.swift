//
//  ResponseParses.swift
//  Itboost
//
//  Created by Admin on 10.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit

class ResponseParser {
    
    func parseWallPost(_ response: [AnyObject]) -> [WallPost] {
        
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
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                newPost.postedAt = dateFormatter.date(from: postedAtString)!
                
                let author = currentWallPost["author"] as! [String:AnyObject]
                if let authorUsername = author["username"] as? String {
                    newPost.authorUsername = authorUsername
                }
                
                postsArray.append(newPost)
            }
            
        }
        
        return postsArray
    }
    
    func parsePostComments(_ response: [AnyObject]) -> [PostComment] {
        
        var commentsArray = [PostComment]()
        
        if response.count > 0 {
            
            for postComment in response {
                
                let currentPostComment = postComment as! [String:AnyObject]
                let newComment = PostComment()
                
                newComment.commentBody = currentPostComment["body"] as! String
                newComment.commentID = currentPostComment["id"] as! Int
                
                let postedAtString = currentPostComment["posted_at"] as! String
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                newComment.postedAt = dateFormatter.date(from: postedAtString)!
                
                let author = currentPostComment["author"] as! [String:AnyObject]
                if let authorUsername = author["username"] as? String {
                    newComment.authorUsername = authorUsername
                }
                
                commentsArray.append(newComment)
            }
            
        }
        
        return commentsArray
    }
    
    func parseNews(_ response: [AnyObject]) -> [News] {
        
        var newsArray = [News]()
        
        if response.count > 0 {
            
            for news in response {
                
                let currentNews = news as! [String:AnyObject]
                let newNews = News()
                
                newNews.newsID = currentNews["id"] as! Int
                
                if let threadID = currentNews["thread_id"] as? Int {
                    newNews.threadID = threadID
                }
                
                if let newsTitle = currentNews["title"] as? String {
                    newNews.title = newsTitle
                }
                
                if let newsContent = currentNews["content"] as? String {
                    // Remove HTML tags
                    
                    let attributedString = try! NSAttributedString(
                        data: newsContent.data(using: String.Encoding.unicode, allowLossyConversion: true)!,
                        options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                        documentAttributes: nil)
                    newNews.content = attributedString.string
                }
                
                if let newsImageURL = currentNews["image"] as? String {
                    newNews.imageURL = newsImageURL
                }
                
                if let newsTypeString = currentNews["type"] as? String {
                    if let newsType = NewsType(rawValue: newsTypeString) {
                        newNews.type = newsType
                    }
                }
                
                let tags = currentNews["tags"] as! [[String:AnyObject]]
                if tags.count > 0 {
                    newNews.tagsArray = tags
                }
                
                if let viewsCount = currentNews["views_count"] as? Int {
                    newNews.viewsCount = viewsCount
                }
                
                let createdAtString = currentNews["created_at"] as! String
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                newNews.createdAt = dateFormatter.date(from: createdAtString)!
                
                if let author = currentNews["owner"] as? [String:AnyObject] {
                    if let authorUsername = author["username"] as? String {
                        newNews.authorUsername = authorUsername
                    }
                    if let authorID = author["id"] as? Int {
                        newNews.authorID = authorID
                    }
                }
                
                newsArray.append(newNews)
            }
            
        }
        
        return newsArray
    }
    
    func parseMembers(_ response: [AnyObject]) -> [Member] {
        
        var membersArray = [Member]()
        
        if response.count > 0 {
            
            for member in response {
                
                let currentMember = member as! [String:AnyObject]
                let newMember = Member()
                
                if let memberID = currentMember["tid"] as? Int {
                    newMember.memberID = memberID
                }
                
                var username = String()
                if let userFirstName = currentMember["firstname"] as? String {
                    username.append(userFirstName)
                    if let userLastName = currentMember["lastname"] as? String {
                        username.append(" \(userLastName)")
                    }
                } else {
                    if let userServerName = currentMember["username"] as? String {
                        username.append(userServerName)
                    }
                }
                if username.characters.count > 0 {
                    newMember.username = username
                } else {
                    newMember.username = "Имя не указано"
                }
                
                if let userEmail = currentMember["email"] as? String {
                    newMember.email = userEmail
                } else {
                    newMember.email = "Не указан"
                }
                
                if let country = currentMember["country"] as? [String:AnyObject] {
                    if let countryName = country["country_name"] as? String {
                        newMember.adress.append(countryName)
                    }
                }
                
                if let city = currentMember["city"] as? [String:AnyObject] {
                    if let cityName = city["city_name"] as? String {
                        newMember.adress.append(cityName)
                    }
                }
                
                if let birthday = currentMember["birthday"] as? String {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    let date = dateFormatter.date(from: birthday)
                    dateFormatter.dateFormat = "dd/MM/yyyy"
                    if date != nil {
                        newMember.birthday = dateFormatter.string(from: date!)
                    }
                } else {
                    newMember.birthday = "Не указана"
                }
                
                if let avatar = currentMember["avatar"] as? [String:AnyObject] {
                    if let avatarPath = avatar["path"] as? String {
                        newMember.avatarURL = URL(string: Constants.shortLinkToServerAPI + avatarPath)
                    }
                }
                
                membersArray.append(newMember)
            }
            
        }
        
        return membersArray
    }

    
}

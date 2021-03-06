//
//  News.swift
//  Itboost
//
//  Created by Alina Yehorova on 13.09.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation

enum NewsType: String {
    case newsUser = "news_user"
    case newsOrganization = "news_organization"
}

class News: NSObject {
    
    var newsID = Int()
    var imageURL = ""
    var title = ""
    var content = ""
    var authorUsername = ""
    var authorID = Int()
    var tagsArray = [[String:AnyObject]]()
    var viewsCount = 0
    var createdAt = Date()
    var type: NewsType?
    var threadID = Int()
    
}

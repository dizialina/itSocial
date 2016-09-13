//
//  News.swift
//  Itboost
//
//  Created by Alina Yehorova on 13.09.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation

enum NewsType: String {
    case NewsUser = "news_user"
    case NewsOrganization = "news_org"
}

class News: NSObject {
    
    var newsID = Int()
    var imageURL = ""
    var title = ""
    var content = ""
    var authorUsername = ""
    var authorID = Int()
    var tagsArray = [String]()
    var viewsCount = 0
    var createdAt = NSDate()
    var type: NewsType?
    
}
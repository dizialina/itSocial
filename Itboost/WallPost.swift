//
//  WallPost.swift
//  Itboost
//
//  Created by Admin on 10.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit

class WallPost: NSObject {
    
    var postTitle = ""
    var postBody = ""
    var authorUsername = ""
    var commentsArray = [AnyObject]()
    var commentsCount = 0
    var postID = Int()
    var postedAt = Date()
    var avatarURL: URL?
    var avatarImage: UIImage?
    
}

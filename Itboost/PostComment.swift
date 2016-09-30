//
//  PostComment.swift
//  Itboost
//
//  Created by Alina Yehorova on 12.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit

class PostComment: NSObject {
    
    var commentBody = ""
    var authorUsername = ""
    var commentID = Int()
    var postedAt = Date()
    var avatarURL: URL?
    var avatarImage: UIImage?
    
}

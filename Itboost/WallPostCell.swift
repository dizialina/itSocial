//
//  WallPostCell.swift
//  Itboost
//
//  Created by Admin on 10.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit

class WallPostCell: UITableViewCell {
    
    @IBOutlet weak var postBodyLabel: UILabel!
    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var deletePostButton: UIButton!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var commentsCountLabel: UILabel!
    
    @IBOutlet weak var heightBodyView: NSLayoutConstraint!
    
}

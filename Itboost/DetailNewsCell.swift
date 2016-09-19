//
//  DetailNewsCell.swift
//  Itboost
//
//  Created by Alina Yehorova on 19.09.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit

class DetailNewsCell: UITableViewCell {
    
    @IBOutlet weak var mainInfoView: UIView!
    @IBOutlet weak var authorAvatar: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var commentsLabel: UILabel!
    
    @IBOutlet weak var heightMainInfoView: NSLayoutConstraint!
    @IBOutlet weak var heightBodyLabel: NSLayoutConstraint!
}

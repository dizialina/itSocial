//
//  EventDetailTableCell.swift
//  Itboost
//
//  Created by Alina Yehorova on 14.09.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit

class EventDetailTableCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var membersCountLabel: UILabel!
    @IBOutlet weak var speakersCountLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var mapImage: UIImageView!
    
    @IBOutlet weak var firstAvatar: UIImageView!
    @IBOutlet weak var secondAvatar: UIImageView!
    @IBOutlet weak var thirdAvatar: UIImageView!
    @IBOutlet weak var fourthAvatar: UIImageView!
    @IBOutlet weak var fifthAvatar: UIImageView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var heightDescriptionLabel: NSLayoutConstraint!
    
    @IBOutlet weak var addToCalendarButton: UIButton!
    @IBOutlet weak var joinEventButton: UIButton!
    @IBOutlet weak var joinActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addPostButton: UIButton!
    
}

//
//  Constants.swift
//  Itboost
//
//  Created by Admin on 19.07.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit

class Constants {
    
    static let APIKey = "AIzaSyCNIEsn4pLSTTwHzTEa3Nz7RdiwYuercao"
    static let linkToServerAPI = "http://api.itboost.org:88/app_dev.php/api/"
    static let shortLinkToServerAPI = "http://api.itboost.org:88"
    //prod version http://api.itboost.org/
    
    // MARK: Notification Keys
    
    static let LoadCommunitiesNotification = Notification.Name("LoadCommunitiesNotification")
    static let LoadOrganizationsNotification = Notification.Name("LoadOrganizationsNotification")
    //static let kLoadCommunitiesNotification = "LoadCommunitiesNotification"
    //static let kLoadOrganizationsNotification = "LoadOrganizationsNotification"
    
    // MARK: NSUserDefaults Keys
    
    static let kAlreadyRun = "AlreadyRun"
    static let kUserToken = "UserToken"
    static let kUserID = "UserID"
    static let kUserLogin = "UserLogin"
    static let kUserPassword = "UserPassword"
    
    // MARK: UIColors
    
    static let backgroundBlue = UIColor(red: 0.451, green: 0.58, blue: 0.655, alpha: 1)
    static let lightBluer = UIColor(red: 0.286, green: 0.447, blue: 0.541, alpha: 1)
    static let middleBlue = UIColor(red: 0.165, green: 0.337, blue: 0.439, alpha: 1)
    static let darkBlue = UIColor(red: 0.078, green: 0.243, blue: 0.341, alpha: 1)
    static let strongDarkBlue = UIColor(red: 0.016, green: 0.153, blue: 0.22, alpha: 1)
    static let mintBlue = UIColor(red:0.69, green:0.87, blue:0.85, alpha:1)
    static let darkMintBlue = UIColor(red:0.56, green:0.78, blue:0.82, alpha:1)
    static let lightGrayColor = UIColor(red:0.78, green:0.78, blue:0.78, alpha:1)
    static let lightGreenColor = UIColor(red:0.55, green:0.78, blue:0.25, alpha:1)
    static let placeholderDefaultColor = UIColor(red:0.62, green:0.69, blue:0.73, alpha:1)
    static let redAlertColor = UIColor(red:0.89, green:0.12, blue:0.22, alpha:1)
    static let mainMintBlue = UIColor(red:0.57, green:0.78, blue:0.81, alpha:1)
    static let navigationBarBlue = UIColor(red:0.69, green:0.84, blue:0.87, alpha:1)

    
    // MARK: Flaticon links
    
    // heart in round
    // http://www.flaticon.com/free-icon/like-heart-circular-outlined-button_52270#term=heart&page=6&position=35
    // round checkbox
    // http://www.flaticon.com/free-icon/success_149148#term=check&page=1&position=2
    // add post
    // http://www.flaticon.com/free-icon/chat_134822#term=comment&page=2&position=85
    // watch comments
    // http://www.flaticon.com/free-icon/chat_134835#term=comment&page=2&position=86
    // calendar
    // http://www.flaticon.com/free-icon/calendar_114357#term=calendar&page=1&position=66
    // creator
    // http://www.flaticon.com/free-icon/user_137779#term=profile&page=3&position=86
    // detail
    // http://www.flaticon.com/free-icon/more-details-circular-button_78087#term=detail&page=1&position=20
    
}

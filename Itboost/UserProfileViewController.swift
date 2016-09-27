//
//  UserProfileViewController.swift
//  Itboost
//
//  Created by Alina Yehorova on 21.09.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit

class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var bottomSpaceInfoViewToView: NSLayoutConstraint!
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userNamelabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var heightAboutlabel: NSLayoutConstraint!
    
    var userInfo = [String:AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add ability to pan info view
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(UserProfileViewController.panView(_:)))
        infoView.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set navigation bar
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.isTranslucent = true
        
        bottomSpaceInfoViewToView.constant = -155.0
        
        if (UserDefaults.standard.value(forKey: Constants.kUserToken) == nil) {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "NavigationEnterScreen") as! UINavigationController
            self.present(viewController, animated: true, completion: nil)
            
        } else {
            getUserProfileInfoFromServer()
        }
        
    }
    
    // MARK: Get data methods
    
    func getUserProfileInfoFromServer() {
        
        ServerManager().getUserProfile(otherUserProfileID: nil, success: { (response) in
            
            //                    response =     {
            //                        about = "<null>";
            //                        "avatar_album_id" = 5;
            //                        birthday = "<null>";
            //                        certificates =         (
            //                        );
            //                        city = "<null>";
            //                        country = "<null>";
            //                        "default_album_id" = 6;
            //                        description = "<null>";
            //                        email = "qwerty@mail.ru";
            //                        firstname = "<null>";
            //                        id = 3;
            //                        lastname = "<null>";
            //                        skills =         (
            //                        );
            //                        "speaker_id" = "<null>";
            //                        "thread_id" = 5;
            //                        username = qwerty;
            //                    };
            
            if response is [String:AnyObject] {
                
                self.userInfo = response as! [String : AnyObject]
                
                var userName = String()
                if let userFirstName = response?["firstname"] as? String {
                    userName.append(userFirstName)
                    if let userLastName = response?["lastname"] as? String {
                        userName.append(" \(userLastName)")
                    }
                } else {
                    if let userServerName = response?["username"] as? String {
                        userName.append(userServerName)
                    }
                }
                if userName.characters.count > 0 {
                    self.userNamelabel.text = userName
                }
                
                if let userEmail = response?["email"] as? String {
                    self.emailLabel.text = userEmail
                }
                
                // Calculate height of description
                
                if let userDescription = response?["description"] as? String {
                    
                    let maximumHeight:CGFloat = 155.0
                    let minimumHeight:CGFloat = 21.0
                    let font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
                    let descriptionHeight = userDescription.heightForText(userDescription as NSString, neededFont:font, viewWidth: self.aboutLabel.frame.size.width, offset: 0.0, device: nil)
                
                    if descriptionHeight > maximumHeight {
                        self.heightAboutlabel.constant = maximumHeight
                    } else if descriptionHeight > minimumHeight {
                        self.heightAboutlabel.constant = descriptionHeight
                    }
                    
                    self.aboutLabel.text = userDescription
                }
                
            }
            }) { (error) in
                print("Error receiving profile info: " + error!.localizedDescription)
        }
        
    }

    // MARK: Actions
    
    @IBAction func logoutUser(_ sender: AnyObject) {
        
        UserDefaults.standard.setValue(nil, forKey: Constants.kUserToken)
        UserDefaults.standard.setValue(nil, forKey: Constants.kUserID)
        UserDefaults.standard.setValue(nil, forKey: Constants.kUserLogin)
        UserDefaults.standard.setValue(nil, forKey: Constants.kUserPassword)
        
        tabBarController?.selectedIndex = 0
        let navVC = tabBarController?.viewControllers![0] as! UINavigationController
        navVC.popToRootViewController(animated: false)
    }
    
    @IBAction func editUserInfo(_ sender: AnyObject) {
    }
    
    func panView(_ sender: UIPanGestureRecognizer) {
        
        if bottomSpaceInfoViewToView.constant == -155 && sender.direction == .Up {
            UIView.animate(withDuration: 0.3) {
                self.bottomSpaceInfoViewToView.constant = 0
                self.view.layoutIfNeeded()
            }
        } else if bottomSpaceInfoViewToView.constant == 0 && sender.direction == .Down {
            UIView.animate(withDuration: 0.3) {
                self.bottomSpaceInfoViewToView.constant = -155
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: Seque
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "editProfile") {
            let viewController = segue.destination as! EditProfileViewController
            viewController.userInfo = self.userInfo
        }
        
    }
    
}

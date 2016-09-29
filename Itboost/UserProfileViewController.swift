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
    @IBOutlet weak var avatarActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var editUserInfoButton: UIBarButtonItem!
    
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
        
        self.avatarActivityIndicator.startAnimating()
        self.editUserInfoButton.isEnabled = false
        
        ServerManager().getUserProfile(otherUserProfileID: nil, success: { (response) in
            
//            response =     {
//                about = "<null>";
//                avatar =         {
//                    album =             {
//                        "album_name" = "\U0410\U0432\U0430\U0442\U0430\U0440\U043a\U0438";
//                        cover = "<null>";
//                        "created_at" = "2016-09-27T19:18:05+0000";
//                        id = 1231;
//                        images =                 (
//                        );
//                        owner = "<null>";
//                    };
//                    "created_at" = "2016-09-27T19:19:36+0000";
//                    id = 1156;
//                    path = "/uploads/gallery/57eac64888a94.jpg";
//                };
//                "avatar_album_id" = 1231;
//                birthday = "2006-11-29T23:26:27+0200";
//                certificates = "<null>";
//                city =         {
//                    "biggest_city" = 1;
//                    "city_name" = "\U041a\U0438\U0435\U0432";
//                    country =             {
//                        "country_name" = "\U0423\U043a\U0440\U0430\U0438\U043d\U0430";
//                        id = 2;
//                    };
//                    id = 2;
//                    "region_name" = "\U041a\U0438\U0435\U0432\U0441\U043a\U0430\U044f \U043e\U0431\U043b\U0430\U0441\U0442\U044c";
//                    "state_name" = "<null>";
//                };
//                country =         {
//                    "country_name" = "\U0423\U043a\U0440\U0430\U0438\U043d\U0430";
//                    id = 2;
//                };
//                "default_album_id" = 1232;
//                description = iOS;
//                email = "koteykaa@mail.ru";
//                firstname = Alina;
//                id = 30;
//                lastname = Egorova;
//                roles =         (
//                    "ROLE_USER"
//                );
//                skills = "<null>";
//                "speaker_id" = "<null>";
//                "thread_id" = 1259;
//                username = koteykaa;
//            };
//        })

            
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
                } else {
                    self.userNamelabel.text = "Имя не указано"
                }
                
                if let userEmail = response?["email"] as? String {
                    self.emailLabel.text = userEmail
                } else {
                    self.emailLabel.text = "Не указан"
                }
                
                if let country = response?["country"] as? [String:AnyObject] {
                    if let countryName = country["country_name"] as? String {
                        self.countryLabel.text = countryName
                    }
                } else {
                    self.countryLabel.text = "Не указана"
                }
                
                if let city = response?["city"] as? [String:AnyObject] {
                    if let cityName = city["city_name"] as? String {
                        self.cityLabel.text = cityName
                    }
                } else {
                    self.cityLabel.text = "Не указан"
                }
                
                if let birthday = response?["birthday"] as? String {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    let date = dateFormatter.date(from: birthday)
                    dateFormatter.dateFormat = "dd/MM/yyyy"
                    if date != nil {
                        self.birthDateLabel.text = dateFormatter.string(from: date!)
                    }
                } else {
                    self.birthDateLabel.text = "Не указан"
                }

                
                if let avatar = response?["avatar"] as? [String:AnyObject] {
                    if let avatarPath = avatar["path"] as? String {
                        
                        let avatarURL = URL(string: Constants.shortLinkToServerAPI + avatarPath)
                        
                        let downloadImageTask = URLSession.shared.dataTask(with: avatarURL!) { (data, response, error) in
                            if data != nil {
                                // Get full size image
                                let avatarImage = UIImage(data: data!)
                                DispatchQueue.main.async {
                                    self.avatarActivityIndicator.stopAnimating()
                                    self.avatarImage.image = avatarImage
                                }
                            }
                        }
                        downloadImageTask.resume()
                        
                    } else {
                        self.avatarImage.image = UIImage(named: "AvatarDefault")
                        self.avatarActivityIndicator.stopAnimating()
                    }
                } else {
                    self.avatarImage.image = UIImage(named: "AvatarDefault")
                    self.avatarActivityIndicator.stopAnimating()
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
                
                self.editUserInfoButton.isEnabled = true
                
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

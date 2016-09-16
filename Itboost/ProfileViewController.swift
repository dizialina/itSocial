//
//  ProfileViewController.swift
//  Itboost
//
//  Created by Admin on 19.07.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var skillsCollectionView: UICollectionView!
    @IBOutlet weak var awardsCollectionView: UICollectionView!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var siteLabel: UILabel!
    
    //views in topView
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userDescriptionLabel: UILabel!
    @IBOutlet weak var firstStarImage: UIImageView!
    @IBOutlet weak var secondStarImage: UIImageView!
    @IBOutlet weak var thirdStarImage: UIImageView!
    @IBOutlet weak var fourthStarImage: UIImageView!
    @IBOutlet weak var fifthStarImage: UIImageView!
    
    var skillsArray = [String]()
    var awardsArray = [String]()
    var awardColorsArray = [UIColor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set shadow for the top view
        
        topView.layer.shadowOffset = CGSize(width: 0, height: 1)
        topView.layer.shadowColor = UIColor.black.cgColor
        topView.layer.shadowRadius = 7
        topView.layer.shadowOpacity = 0.1
        topView.layer.shadowOffset = CGSize(width: 0, height: 10)
        topView.clipsToBounds = false
        topView.layer.shadowPath = UIBezierPath(rect: topView.layer.bounds).cgPath
        
        // Set navigation bar
        
        self.navigationItem.title = "Профиль"
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.isTranslucent = false
        
        // Temp settings
        
        skillsArray = ["C#", ".NET", "ASPP.NET", "HTML 5", "CSS 3", "Python", "JAVA", "Swift"]
        awardsArray = ["ТОП 5 Спикеров", "150 Событий", "100 Событий", "50 Событий", "ТОП 10 Боссов"]
        awardColorsArray = [UIColor.magenta, UIColor.purple, UIColor.orange, UIColor.cyan, UIColor.brown]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make avatar image round
        
        self.view.layer.layoutIfNeeded()
        avatarImage.layer.cornerRadius = avatarImage.frame.size.width / 2
        avatarImage.clipsToBounds = true
        
        // Call log in screen if user is not authorized
        
        if (UserDefaults.standard.value(forKey: Constants.kUserToken) == nil) {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "NavigationEnterScreen") as! UINavigationController
            self.present(viewController, animated: true, completion: nil)
            
        } else {
            getSpeakerProfileInfoFromServer()
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getSpeakerProfileInfoFromServer() {
        // use speaker.get
    }
    
    // MARK: Actions
    
    @IBAction func logoutUser(_ sender: AnyObject) {
        
        UserDefaults.standard.setValue(nil, forKey: Constants.kUserToken)
        UserDefaults.standard.setValue(nil, forKey: Constants.kUserID)
        
        tabBarController?.selectedIndex = 0
        let navVC = tabBarController?.viewControllers![0] as! UINavigationController
        navVC.popToRootViewController(animated: false)
    }
    
    
    @IBAction func editProfile(_ sender: AnyObject) {
        // editing profile
    }
    
    //MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == skillsCollectionView {
            return skillsArray.count
        } else {
            return awardsArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == skillsCollectionView {
            
            let skillsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SkillsCell", for: indexPath) as! SkillsCell
        
            let skillTitle:NSString = skillsArray[(indexPath as NSIndexPath).row] as NSString
            let textWidth = skillTitle.widthForText(skillTitle, viewHeight: 38.0, offset: 12.0, device: nil)
            
            skillsCell.textLabel.text = skillTitle as String
            skillsCell.cellViewWidth.constant = textWidth
            
            // Set shadow for cell
            
            skillsCell.layer.shadowOffset = CGSize(width: 0, height: 1)
            skillsCell.layer.shadowColor = UIColor.black.cgColor
            skillsCell.layer.shadowRadius = 5.5
            skillsCell.layer.shadowOpacity = 0.1
            skillsCell.layer.shadowOffset = CGSize(width: 3, height: 3)
            skillsCell.clipsToBounds = false
            skillsCell.layer.shadowPath = UIBezierPath(rect: skillsCell.layer.bounds).cgPath
        
            return skillsCell
            
        } else {
            
            let awardsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AwardsCell", for: indexPath) as! AwardsCell
            
            awardsCell.awardTitleLabel.text = awardsArray[(indexPath as NSIndexPath).row]
            awardsCell.backgroundColorView.backgroundColor = awardColorsArray[(indexPath as NSIndexPath).row]
            
            return awardsCell
            
        }
        
    }
    
    //MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        if collectionView == skillsCollectionView {
            
        let skillTitle:NSString = skillsArray[(indexPath as NSIndexPath).row] as NSString
        let width = skillTitle.widthForText(skillTitle, viewHeight: 38.0, offset: 12.0, device: nil)
        return CGSize(width: width, height: 38.0)
            
        } else {
            return CGSize(width: 100, height: 100)
        }
    
    }
    
    
    
}

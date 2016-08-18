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
        
        // Make navigation bar translucent
        
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.translucent = true
        
        // Set shadow for the top view
        
        topView.layer.shadowOffset = CGSizeMake(0, 1)
        topView.layer.shadowColor = UIColor.blackColor().CGColor
        topView.layer.shadowRadius = 7
        topView.layer.shadowOpacity = 0.1
        topView.layer.shadowOffset = CGSizeMake(0, 10)
        topView.clipsToBounds = false
        topView.layer.shadowPath = UIBezierPath(rect: topView.layer.bounds).CGPath
        
        // Set navigation bar items
        
        self.navigationItem.title = "Профиль"
        
        // Temp settings
        
        skillsArray = ["C#", ".NET", "ASPP.NET", "HTML 5", "CSS 3", "Python", "JAVA", "Swift"]
        awardsArray = ["ТОП 5 Спикеров", "150 Событий", "100 Событий", "50 Событий", "ТОП 10 Боссов"]
        awardColorsArray = [UIColor.blueColor(), UIColor.yellowColor(), UIColor.orangeColor(), UIColor.cyanColor(), UIColor.brownColor()]
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (NSUserDefaults.standardUserDefaults().valueForKey(Constants.kUserToken) == nil) {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewControllerWithIdentifier("NavigationEnterScreen") as! UINavigationController
            self.presentViewController(viewController, animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        print(scrollView.contentSize)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    @IBAction func logoutUser(sender: AnyObject) {
        
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: Constants.kUserToken)
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: Constants.kUserID)
        
        tabBarController?.selectedIndex = 0
        let navVC = tabBarController?.viewControllers![0] as! UINavigationController
        navVC.popToRootViewControllerAnimated(false)
    }
    
    
    @IBAction func editProfile(sender: AnyObject) {
        // editing profile
    }
    
    //MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == skillsCollectionView {
            return skillsArray.count
        } else {
            return awardsArray.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if collectionView == skillsCollectionView {
            
            let skillsCell = collectionView.dequeueReusableCellWithReuseIdentifier("SkillsCell", forIndexPath: indexPath) as! SkillsCell
        
            let skillTitle:NSString = skillsArray[indexPath.row]
            let textWidth = skillTitle.widthForText(skillTitle, viewHeight: 38.0, offset: 12.0, device: nil)
            
            skillsCell.textLabel.text = skillTitle as String
            skillsCell.cellViewWidth.constant = textWidth
            
            // Set shadow for cell
            
            skillsCell.layer.shadowOffset = CGSizeMake(0, 1)
            skillsCell.layer.shadowColor = UIColor.blackColor().CGColor
            skillsCell.layer.shadowRadius = 6
            skillsCell.layer.shadowOpacity = 0.1
            skillsCell.layer.shadowOffset = CGSizeMake(5, 5)
            skillsCell.clipsToBounds = false
            skillsCell.layer.shadowPath = UIBezierPath(rect: skillsCell.layer.bounds).CGPath
        
            return skillsCell
            
        } else {
            
            let awardsCell = collectionView.dequeueReusableCellWithReuseIdentifier("AwardsCell", forIndexPath: indexPath) as! AwardsCell
            
            return awardsCell
            
        }
        
    }
    
    //MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let skillTitle:NSString = skillsArray[indexPath.row]
        let width = skillTitle.widthForText(skillTitle, viewHeight: 38.0, offset: 12.0, device: nil)
        
        return CGSizeMake(width, 38.0)
    }
    
    
    
}
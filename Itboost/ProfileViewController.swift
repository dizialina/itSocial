//
//  ProfileViewController.swift
//  Itboost
//
//  Created by Admin on 19.07.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var topView: UIView!
    
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
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (NSUserDefaults.standardUserDefaults().valueForKey(Constants.kUserToken) == nil) {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewControllerWithIdentifier("NavigationEnterScreen") as! UINavigationController
            self.presentViewController(viewController, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutButton(sender: AnyObject) {
        
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: Constants.kUserToken)
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: Constants.kUserID)
        
        tabBarController?.selectedIndex = 0
        let navVC = tabBarController?.viewControllers![0] as! UINavigationController
        navVC.popToRootViewControllerAnimated(false)
    }
    
}
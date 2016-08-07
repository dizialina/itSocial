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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (NSUserDefaults.standardUserDefaults().valueForKey(Constants.kUserToken) == nil) {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewControllerWithIdentifier("EnterScreenViewController") as! EnterScreenViewController
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
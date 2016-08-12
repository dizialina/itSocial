//
//  EnterScreenViewController.swift
//  Itboost
//
//  Created by Admin on 07.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit

class EnterScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (NSUserDefaults.standardUserDefaults().valueForKey(Constants.kUserToken) != nil) {
            //performSegueWithIdentifier("passEnterScreen", sender: nil)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func passAuthorization(sender: AnyObject) {
        (presentingViewController as! TabBarViewController).selectedIndex = 0
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "passLogin") {
            let viewController = segue.destinationViewController as! TabBarViewController
            viewController.selectedIndex = 0
        }
        
    }
    
}

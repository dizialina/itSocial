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
        
        //self.navigationController?.navigationBar.isHidden = true
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        if (UserDefaults.standard.value(forKey: Constants.kUserToken) != nil) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    @IBAction func googleAuthorization(_ sender: AnyObject) {
    }
    
    @IBAction func facebookAuthorization(_ sender: AnyObject) {
    }
    
    @IBAction func vkontakteAuthorization(_ sender: AnyObject) {
    }
    
    @IBAction func passAuthorization(_ sender: AnyObject) {
        (presentingViewController as! TabBarViewController).selectedIndex = 0
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "passLogin") {
            let viewController = segue.destination as! TabBarViewController
            viewController.selectedIndex = 0
        }
        
    }
    
}

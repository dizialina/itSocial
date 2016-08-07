//
//  LoginViewController.swift
//  Itboost
//
//  Created by Admin on 07.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func acceptLogin(sender: AnyObject) {
        
        var userInfo = [String:String]()
        
        userInfo["username"] = emailField.text
        userInfo["password"] = passwordField.text
        
        ServerManager().postAuthorization(userInfo, success: { (response) -> Void in
            self.showAlertWithHandler()
        }) { (error) -> Void in
            let alertController = ReusableMethods().showAlertWithTitle("Ошибка", message: "Неправильный e-mail или пароль")
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func cancelLogin(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showAlertWithHandler() {
        
        let alertController = UIAlertController(title: "Готово", message: "Вы успешно вошли в систему", preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (alertAction) in
            
            //ServerManager.sharedInstance.getTaskListFromServer(true)

            self.presentingViewController?.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: TextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
}

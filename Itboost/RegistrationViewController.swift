//
//  RegistrationViewController.swift
//  Itboost
//
//  Created by Admin on 07.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit

class RegistrationViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registrationAction(sender: AnyObject) {
        
        var userInfo = [String:String]()
        
        var emailEmpty = true
        var usernameEmpty = true
        var passwordEmpty = true
        
        if emailField.text!.characters.count > 0 {
            
            let componentsInField = NSCharacterSet.init(charactersInString: emailField.text!)
            let keyCharacters:NSString = "@."
            let dog = keyCharacters.characterAtIndex(0)
            let dot = keyCharacters.characterAtIndex(1)
            if componentsInField.characterIsMember(dog) && componentsInField.characterIsMember(dot) {
                
                let textInField:NSString = emailField.text!
                let componentsByDog = textInField.componentsSeparatedByString("@")
                if componentsByDog.first!.characters.count < 3 {
                    emailLabel.textColor = UIColor.redColor()
                } else {
                    let componentsByDot = (componentsByDog[1] as NSString).componentsSeparatedByString(".")
                    if componentsByDot.first?.characters.count < 1 || componentsByDot[1].characters.count < 2 {
                        emailLabel.textColor = UIColor.redColor()
                    } else {
                        emailLabel.textColor = UIColor.blackColor()
                        userInfo["email"] = emailField.text
                        emailEmpty = false
                    }
                }
            } else {
                emailLabel.textColor = UIColor.redColor()
            }
        } else {
            emailLabel.textColor = UIColor.redColor()
        }
        
        if usernameField.text!.characters.count > 0 {
            usernameLabel.textColor = UIColor.blackColor()
            userInfo["username"] = usernameField.text
            usernameEmpty = false
        } else {
            usernameLabel.textColor = UIColor.redColor()
        }
        
        if passwordField.text!.characters.count > 5 {
            passwordLabel.textColor = UIColor.blackColor()
            userInfo["password"] = passwordField.text
            passwordEmpty = false
        } else {
            passwordLabel.textColor = UIColor.redColor()
        }
        
        
        if !emailEmpty && !usernameEmpty && !passwordEmpty {
            
            ServerManager().postRegistration(userInfo, success: { (response) -> Void in
                self.showAlertWithHandler()
                
            }) { (error) -> Void in
                
                let alertController = ReusableMethods().showAlertWithTitle("Ошибка", message: "Пользователь с таким e-mail или username уже существует")
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            
        }

        
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func showAlertWithHandler() {
        
        let alertController = UIAlertController(title: "Готово", message: "Вы успешно зарегистрировались", preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (alertAction) in
            
            //ServerManager.sharedInstance.getTaskListFromServer(true)
            
            self.presentingViewController?.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: TextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        let fieldsArray = [emailField, usernameField, passwordField]
        for field in fieldsArray {
            if field == textField {
                let nextFieldIndex = fieldsArray.indexOf{$0 === field}! + 1
                if fieldsArray.count <= nextFieldIndex {
                    textField.resignFirstResponder()
                } else {
                    fieldsArray[nextFieldIndex].becomeFirstResponder()
                }
            }
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField == emailField {
            let componentsInField = NSCharacterSet.init(charactersInString: textField.text!)
            let keyCharacters:NSString = "@."
            let dog = keyCharacters.characterAtIndex(0)
            let dot = keyCharacters.characterAtIndex(1)
            if componentsInField.characterIsMember(dog) {
                if string == "@" {
                    return false
                }
                let validationSet:NSCharacterSet = NSCharacterSet.letterCharacterSet().invertedSet
                let invertedSet:NSMutableCharacterSet = validationSet.copy() as! NSMutableCharacterSet
                invertedSet.removeCharactersInString(".")
                let components = string.componentsSeparatedByCharactersInSet(invertedSet)
                if components.count > 1 {
                    return false
                }
            }
            
            if componentsInField.characterIsMember(dot) {
                let components = textField.text!.componentsSeparatedByString("@")
                if components.count > 1 {
                    let afterDogString = components[1]
                    let componentsInAfterDogString = NSCharacterSet.init(charactersInString: afterDogString)
                    if componentsInAfterDogString.characterIsMember(dot) {
                        if string == "." {
                            return false
                        }
                    }
                }
            }
            
            let validationSet = NSCharacterSet(charactersInString: "qwertyuiopasdfghjklzcvbnm!#$%&'*+-/=?^_`{}|~1234567890@.").invertedSet
            let components = string.componentsSeparatedByCharactersInSet(validationSet)
            if components.count > 1 {
                return false
            }
            
        }
        
        if textField == usernameField {
            let resultString: NSString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            let numberOfSymbols = resultString.length
            if numberOfSymbols > 20 {
                return false
            }
            
            let validationSet = NSCharacterSet.letterCharacterSet().invertedSet
            let components = string.componentsSeparatedByCharactersInSet(validationSet)
            if components.count > 1 {
                return false
            }
        }
        
        return true
    }

    
}

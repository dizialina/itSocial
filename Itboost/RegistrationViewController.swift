//
//  RegistrationViewController.swift
//  Itboost
//
//  Created by Admin on 07.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit
/*
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}
*/

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
    
    @IBAction func registrationAction(_ sender: AnyObject) {
        
        var userInfo = [String:String]()
        
        var emailEmpty = true
        var usernameEmpty = true
        var passwordEmpty = true
        
        if emailField.text!.characters.count > 0 {
            
            let componentsInField = CharacterSet.init(charactersIn: emailField.text!)
            let keyCharacters:NSString = "@."
            let dog = keyCharacters.character(at: 0)
            let dot = keyCharacters.character(at: 1)
            if componentsInField.contains(UnicodeScalar(dog)!) && componentsInField.contains(UnicodeScalar(dot)!) {
                
                let textInField:NSString = emailField.text! as NSString
                let componentsByDog = textInField.components(separatedBy: "@")
                if componentsByDog.first!.characters.count < 3 {
                    emailLabel.textColor = UIColor.red
                } else {
                    let componentsByDot = (componentsByDog[1] as NSString).components(separatedBy: ".")
                    if (componentsByDot.first?.characters.count)! < 1 || componentsByDot[1].characters.count < 2 {
                        emailLabel.textColor = UIColor.red
                    } else {
                        emailLabel.textColor = UIColor.black
                        userInfo["email"] = emailField.text
                        emailEmpty = false
                    }
                }
            } else {
                emailLabel.textColor = UIColor.red
            }
        } else {
            emailLabel.textColor = UIColor.red
        }
        
        if usernameField.text!.characters.count > 0 {
            usernameLabel.textColor = UIColor.black
            userInfo["username"] = usernameField.text
            usernameEmpty = false
        } else {
            usernameLabel.textColor = UIColor.red
        }
        
        if passwordField.text!.characters.count > 5 {
            passwordLabel.textColor = UIColor.black
            userInfo["password"] = passwordField.text
            passwordEmpty = false
        } else {
            passwordLabel.textColor = UIColor.red
        }
        
        
        if !emailEmpty && !usernameEmpty && !passwordEmpty {
            
            ServerManager().postRegistration(userInfo as NSDictionary, success: { (response) -> Void in
                self.showAlertWithHandler()
                
            }) { (error) -> Void in
                
                let alertController = ReusableMethods().showAlertWithTitle("Ошибка", message: "Пользователь с таким e-mail или username уже существует")
                self.present(alertController, animated: true, completion: nil)
            }
            
        }

        
    }
    
    @IBAction func cancelAction(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func showAlertWithHandler() {
        
        let alertController = UIAlertController(title: "Готово", message: "Вы успешно зарегистрировались", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (alertAction) in
            
            //ServerManager.sharedInstance.getTaskListFromServer(true)
            
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let fieldsArray = [emailField, usernameField, passwordField]
        for field in fieldsArray {
            if field == textField {
                let nextFieldIndex = fieldsArray.index{$0 === field}! + 1
                if fieldsArray.count <= nextFieldIndex {
                    textField.resignFirstResponder()
                } else {
                    fieldsArray[nextFieldIndex]?.becomeFirstResponder()
                }
            }
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField == emailField {
            let componentsInField = CharacterSet.init(charactersIn: textField.text!)
            let keyCharacters:NSString = "@."
            let dog = keyCharacters.character(at: 0)
            let dot = keyCharacters.character(at: 1)
            if componentsInField.contains(UnicodeScalar(dog)!) {
                if string == "@" {
                    return false
                }
                let validationSet:CharacterSet = CharacterSet.letters.inverted
                let invertedSet:NSMutableCharacterSet = (validationSet as NSCharacterSet).copy() as! NSMutableCharacterSet
                invertedSet.removeCharacters(in: ".")
                let components = string.components(separatedBy: invertedSet as CharacterSet)
                if components.count > 1 {
                    return false
                }
            }
            
            if componentsInField.contains(UnicodeScalar(dot)!) {
                let components = textField.text!.components(separatedBy: "@")
                if components.count > 1 {
                    let afterDogString = components[1]
                    let componentsInAfterDogString = CharacterSet.init(charactersIn: afterDogString)
                    if componentsInAfterDogString.contains(UnicodeScalar(dot)!) {
                        if string == "." {
                            return false
                        }
                    }
                }
            }
            
            let validationSet = CharacterSet(charactersIn: "qwertyuiopasdfghjklzcvbnm!#$%&'*+-/=?^_`{}|~1234567890@.").inverted
            let components = string.components(separatedBy: validationSet)
            if components.count > 1 {
                return false
            }
            
        }
        
        if textField == usernameField {
            let resultString: NSString = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
            let numberOfSymbols = resultString.length
            if numberOfSymbols > 20 {
                return false
            }
            
            let validationSet = CharacterSet.letters.inverted
            let components = string.components(separatedBy: validationSet)
            if components.count > 1 {
                return false
            }
        }
        
        return true
    }

    
}

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
    @IBOutlet weak var hidePasswordButton: UIButton!
    @IBOutlet weak var usernameBackgroundView: UIView!
    @IBOutlet weak var emailBackgroundView: UIView!
    @IBOutlet weak var passwordBackgroundView: UIView!
    
    var isPasswordShow = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    @IBAction func hidePassword(_ sender: AnyObject) {
        
        if isPasswordShow {
            passwordField.isSecureTextEntry = false
            isPasswordShow = false
        } else {
            passwordField.isSecureTextEntry = true
            isPasswordShow = true
        }
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
                    emailBackgroundView.layer.borderColor = Constants.redAlertColor.cgColor
                } else {
                    let componentsByDot = (componentsByDog[1] as NSString).components(separatedBy: ".")
                    if (componentsByDot.first?.characters.count)! < 1 || componentsByDot[1].characters.count < 2 {
                        emailBackgroundView.layer.borderColor = Constants.redAlertColor.cgColor
                    } else {
                        emailBackgroundView.layer.borderColor = UIColor.white.cgColor
                        userInfo["email"] = emailField.text
                        emailEmpty = false
                    }
                }
            } else {
                emailBackgroundView.layer.borderColor = Constants.redAlertColor.cgColor
            }
        } else {
            emailBackgroundView.layer.borderColor = Constants.redAlertColor.cgColor
        }
        
        if usernameField.text!.characters.count > 0 {
            usernameBackgroundView.layer.borderColor = UIColor.white.cgColor
            userInfo["username"] = usernameField.text
            usernameEmpty = false
        } else {
            usernameBackgroundView.layer.borderColor = Constants.redAlertColor.cgColor
        }
        
        if passwordField.text!.characters.count > 2 {
            passwordBackgroundView.layer.borderColor = UIColor.white.cgColor
            userInfo["password"] = passwordField.text
            passwordEmpty = false
        } else {
            passwordBackgroundView.layer.borderColor = Constants.redAlertColor.cgColor
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
            
            let validationSet = CharacterSet(charactersIn: "qwertyuiopasdfghjklzxcvbnm!#$%&'*+-/=?^_`{}|~1234567890@.").inverted
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

//
//  EditProfileViewController.swift
//  Itboost
//
//  Created by Alina Yehorova on 27.09.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit
import ActionSheetPicker_3_0

class EditProfileViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var aboutField: UITextField!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    
    var userInfo = [String:AnyObject]()
    var selectedUserLocation = [String:FilterObject]()
    var userInput = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let firstName = userInput["firstName"] {
            firstNameField.text = firstName
        } else {
            if let userFirstName = userInfo["firstname"] as? String {
                firstNameField.text = userFirstName
            }
        }
        
        if let lastName = userInput["lastName"] {
            lastNameField.text = lastName
        } else {
            if let userLastName = userInfo["lastname"] as? String {
                lastNameField.text = userLastName
            }
        }
        
        if let birthDate = userInput["birthDate"] {
            birthDateLabel.text = birthDate
        } else {
            if let userBirthDate = userInfo["birthday"] as? String {
                birthDateLabel.text = userBirthDate
            }
        }
        
        if let about = userInput["about"] {
            aboutField.text = about
        } else {
            if let userDescription = userInfo["description"] as? String {
                aboutField.text = userDescription
            }
        }
        
        if let userCountry = userInfo["country"] as? [String:AnyObject] {
            var countryObject = FilterObject()
            if let countryName = userCountry["country_name"] as? String {
                countryObject.filterObjectName = countryName
            }
            if let countryID = userCountry["country_id"] as? Int {
                countryObject.filterObjectID = countryID
                selectedUserLocation["country"] = countryObject
            }
        }
        
        if let userCity = userInfo["city"] as? [String:AnyObject] {
            var cityObject = FilterObject()
            if let cityName = userCity["city_name"] as? String {
                cityObject.filterObjectName = cityName
            }
            if let cityID = userCity["city_id"] as? Int {
                cityObject.filterObjectID = cityID
                selectedUserLocation["city"] = cityObject
            }
        }
        
        if selectedUserLocation["country"] != nil {
            countryLabel.text = selectedUserLocation["country"]!.filterObjectName
        }
        
        if selectedUserLocation["city"] != nil {
            cityLabel.text = selectedUserLocation["city"]!.filterObjectName
        } else {
            cityLabel.text = "Не указано"
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == firstNameField {
            userInput["firstName"] = textField.text
        } else if textField == lastNameField {
            userInput["lastName"] = textField.text
        } else if textField == aboutField {
            userInput["about"] = textField.text
        }
        
        return true
    }
    
    // MARK: TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 3 || indexPath.row == 4 {
            performSegue(withIdentifier: "selectLocation", sender: nil)
            
        } else if indexPath.row == 5 {
            
            let datePicker = ActionSheetDatePicker(title: "Дата рождения", datePickerMode: UIDatePickerMode.date, selectedDate: Date(), doneBlock: {
                picker, value, index in
                
                if value != nil {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    self.userInput["birthDateTimastamp"] = formatter.string(from: value! as! Date)
                    formatter.dateFormat = "dd/MM/yyyy"
                    self.userInput["birthDate"] = formatter.string(from: value! as! Date)
                    
                    DispatchQueue.main.async {
                        self.birthDateLabel.text = self.userInput["birthDate"]
                    }
                }
                
                return
                }, cancel: { ActionStringCancelBlock in return }, origin: tableView.superview!.superview)
            
            datePicker?.toolbarButtonsColor = Constants.mainMintBlue
            
            datePicker?.show()
        }
    }
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "selectLocation") {
            let viewController = segue.destination as! UserLocationViewController
            let indexPath = tableView.indexPathForSelectedRow
            if indexPath?.row == 3 {
                viewController.filterType = .country
            } else {
                viewController.filterType = .city
            }
            if let countryFilterObject = selectedUserLocation["country"] {
                viewController.countryID = countryFilterObject.filterObjectID
            }
        }
    }
    
    
}

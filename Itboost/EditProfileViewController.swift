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

class EditProfileViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var aboutField: UITextField!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var userInfo = [String:AnyObject]()
    var selectedUserLocation = [String:FilterObject]()
    var userInput = [String:String]()
    var pickedAvatar: UIImage?
    
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
            if let birthday = userInfo["birthday"] as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                let date = dateFormatter.date(from: birthday)
                dateFormatter.dateFormat = "dd/MM/yyyy"
                if date != nil {
                    self.birthDateLabel.text = dateFormatter.string(from: date!)
                }
            }
        }
        
        if let about = userInput["about"] {
            aboutField.text = about
        } else {
            if let userDescription = userInfo["description"] as? String {
                aboutField.text = userDescription
            }
        }
        
        if selectedUserLocation["country"] == nil {
            if let userCountry = userInfo["country"] as? [String:AnyObject] {
                var countryObject = FilterObject()
                if let countryName = userCountry["country_name"] as? String {
                    countryObject.filterObjectName = countryName
                }
                if let countryID = userCountry["id"] as? Int {
                    countryObject.filterObjectID = countryID
                    selectedUserLocation["country"] = countryObject
                }
            }
        }
        
        countryLabel.text = selectedUserLocation["country"]!.filterObjectName
        
        if selectedUserLocation["city"] == nil {
            if let userCity = userInfo["city"] as? [String:AnyObject] {
                var cityObject = FilterObject()
                if let cityName = userCity["city_name"] as? String {
                    cityObject.filterObjectName = cityName
                }
                if let cityID = userCity["id"] as? Int {
                    cityObject.filterObjectID = cityID
                selectedUserLocation["city"] = cityObject
                }
            } else {
                cityLabel.text = "Не указано"
            }
        }
        
        cityLabel.text = selectedUserLocation["city"]!.filterObjectName
        
        if pickedAvatar != nil {
            self.avatarImage.image = pickedAvatar
            
        } else if let avatar = userInfo["avatar"] as? [String:AnyObject] {
            if let avatarPath = avatar["path"] as? String {
                activityIndicator.startAnimating()
                let avatarURL = URL(string: Constants.shortLinkToServerAPI + avatarPath)
                
                let downloadImageTask = URLSession.shared.dataTask(with: avatarURL!) { (data, response, error) in
                    if data != nil {
                        let avatarImage = UIImage(data: data!)
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            self.avatarImage.image = avatarImage
                        }
                    }
                }
                downloadImageTask.resume()
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    @IBAction func acceptEditing(_ sender: AnyObject) {
        
        var editedUserInfo = [String:AnyObject]()
        
        editedUserInfo["firstname"] = self.firstNameField.text as AnyObject?
        editedUserInfo["lastname"] = self.lastNameField.text as AnyObject?
        editedUserInfo["description"] = self.aboutField.text as AnyObject?
        
        if let birthDate = self.userInput["birthDateTimestamp"] {
            editedUserInfo["birthday"] = birthDate as AnyObject?
        } else {
            if birthDateLabel.text != "Не указано" {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let date = dateFormatter.date(from: birthDateLabel.text!)
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                if date != nil {
                    editedUserInfo["birthday"] = dateFormatter.string(from: date!) as AnyObject?
                }
            }
        }
        
        if let country = selectedUserLocation["country"] {
            editedUserInfo["country"] = ["id": country.filterObjectID] as AnyObject?
        }
        
        if let city = selectedUserLocation["city"] {
            editedUserInfo["city"] = ["id": city.filterObjectID] as AnyObject?
        }
        
        ServerManager().editUserProfile(editedUserInfo, success: { (response) in
            
            if self.pickedAvatar != nil {
                
                if let avatarAlbumID = self.userInfo["avatar_album_id"] as? Int {
                ServerManager().uploadImage(image: self.pickedAvatar!, albumID: avatarAlbumID, success: { (response) in
                    
                    self.showAlertWithHandler()
                    
                    }, failure: { (error) in
                        print("Error while uploading image: " + error!.localizedDescription)
                })
                }
                
            } else {
                self.showAlertWithHandler()
            }
            
            }) { (error) in
                print("Error while editing profile info: " + error!.localizedDescription)
        }
        
    }
    
    func showAlertWithHandler() {
        
        let alertController = UIAlertController(title: "", message: "Информация Вашего профиля успешно изменена", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (alertAction) in
            _ = self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
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
                    self.userInput["birthDateTimestamp"] = formatter.string(from: value! as! Date)
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
            
        } else if indexPath.row == 6 {
            
            let avatarMenu = UIAlertController(title: nil, message: "Выберите действие", preferredStyle: .actionSheet)

            let pickFromGalleryAction = UIAlertAction(title: "Выбрать из галереи", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                
                self.workWithImagePicker()
            })
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            
            avatarMenu.addAction(pickFromGalleryAction)
            avatarMenu.addAction(cancelAction)
            
            self.present(avatarMenu, animated: true, completion: nil)
        }
        
    }
    
    // MARK: Image Picker
    
    func workWithImagePicker() {
            
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        picker.dismiss(animated: true) {
            
            if pickedImage != nil {
                self.avatarImage.image = pickedImage
                self.pickedAvatar = pickedImage
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
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
    
    /*
     {
     "id": 11,
     "firstname": "test_firstname",
     "lastname": "test_lastname",
     "about": "test_about",
     "birthday": "1993-06-08",
     "country": {
        "id": 1
     },
     "city": {
        "id": 1
     },
     "description": "test_description",
     "skills": [
        {
            "id": 1
        },
        {
            "id": 2
        }
     ],
     "certificates": [
        {
            "name": "test_name",
            "url": "test_url"
        }
     ]
     }
     
     let params:NSDictionary = ["birthday": userInfo["birthday"]!,
     "about": userInfo["about"]!,
     "firstname": userInfo["firstname"]!,
     "lastname": userInfo["lastname"]!,
     "country": userInfo["country"]!,       // array
     "city": userInfo["city"]!,          // array
     "description": userInfo["description"]!,
     "skills": userInfo["skills"]!,        // array
     "sertificates": userInfo["sertificates"]!]  // array
     */
    
    
}

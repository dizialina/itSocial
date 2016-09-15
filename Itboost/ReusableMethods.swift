//
//  ReusableMethods.swift
//  Itboost
//
//  Created by Admin on 07.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit

class ReusableMethods: NSObject {
    
    func showAlertWithTitle(_ title: String, message: String) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(cancelAction)
        return alertController
        
    }
    
    func convertLocationDictionaryToAdressString(_ locationDictionary:[String:AnyObject]) -> String {
        
        var fullAdress = [String]()
        
        if let country = locationDictionary["country"] as? String {
            fullAdress.append(country)
        }
        if let city = locationDictionary["city"] as? String {
            fullAdress.append(city)
        }
        if let state = locationDictionary["state"] as? String {
            fullAdress.append(state)
        }
        if let region = locationDictionary["region"] as? String {
            fullAdress.append(region)
        }
        if let street = locationDictionary["street"] as? String {
            fullAdress.append(street)
        }
        if let place = locationDictionary["place"] as? String {
            fullAdress.append(place)
        }
        
        return fullAdress.joined(separator: ", ")
    }
    
}

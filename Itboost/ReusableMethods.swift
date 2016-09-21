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
            if country.characters.count > 0 {
                fullAdress.append(country)
            }
        }
        if let city = locationDictionary["city"] as? String {
            if city.characters.count > 0 {
                fullAdress.append(city)
            }
        }
        if let state = locationDictionary["state"] as? String {
            if state.characters.count > 0 {
                fullAdress.append(state)
            }
        }
        if let region = locationDictionary["region"] as? String {
            if region.characters.count > 0 {
                fullAdress.append(region)
            }
        }
        if let street = locationDictionary["street"] as? String {
            if street.characters.count > 0 {
                fullAdress.append(street)
            }
        }
        if let place = locationDictionary["place"] as? String {
            if place.characters.count > 0 {
                fullAdress.append(place)
            }
        }
        
        return fullAdress.joined(separator: ", ")
    }
    
}

//
//  User.swift
//  Itboost
//
//  Created by Admin on 02.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import CoreData


class User: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    override var description: String {
        get {
            var rolesArray = [String]()
            if let roles = self.roles {
                rolesArray = NSKeyedUnarchiver.unarchiveObjectWithData(roles) as! [String]
            }
            return "userID:\(self.userID), \(self.firstName), \(self.lastName), \(self.userName), \(self.email) \n\(rolesArray)"
        }
    }

}

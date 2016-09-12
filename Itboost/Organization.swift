//
//  Organization.swift
//  Itboost
//
//  Created by Alina Yehorova on 12.09.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import CoreData


class Organization: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    override var description: String {
        get {
            return "ID:\(self.organizationID), \(self.name): \n\(self.detailDescription) \n\(self.createdAt) \n\(self.createdBy) \n"
        }
    }

}

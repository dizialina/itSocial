//
//  Community.swift
//  Itboost
//
//  Created by Admin on 02.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import CoreData


class Community: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    override var description: String {
        get {
            return "ID:\(self.communityID), \(self.name): \n\(self.detailDescription) \n\(self.createdAt) \n\(self.eventDate) \n\(self.createdBy) \n"
        }
    }

}

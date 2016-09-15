//
//  Community+CoreDataClass.swift
//  Itboost
//
//  Created by Alina Yehorova on 15.09.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import CoreData


public class Community: NSManagedObject {
    
    override public var description: String {
        get {
            return "ID:\(self.communityID), \(self.name): \n\(self.detailDescription) \n\(self.createdAt) \n\(self.eventDate) \n\(self.createdBy) \n"
        }
    }

}

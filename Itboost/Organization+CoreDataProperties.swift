//
//  Organization+CoreDataProperties.swift
//  Itboost
//
//  Created by Alina Yehorova on 12.09.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Organization {

    @NSManaged var name: String
    @NSManaged var specialization: String?
    @NSManaged var organizationID: NSDecimalNumber
    @NSManaged var detailDescription: String?
    @NSManaged var subscribersCount: NSDecimalNumber?
    @NSManaged var threadID: NSDecimalNumber
    @NSManaged var createdAt: NSDate?
    @NSManaged var createdBy: User?

}

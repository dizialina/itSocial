//
//  Community+CoreDataProperties.swift
//  Itboost
//
//  Created by Admin on 02.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Community {

    @NSManaged var communityID: NSDecimalNumber
    @NSManaged var name: String
    @NSManaged var detailDescription: String?
    @NSManaged var createdAt: NSDate?
    @NSManaged var eventDate: NSDate?
    @NSManaged var createdBy: User

}

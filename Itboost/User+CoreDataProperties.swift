//
//  User+CoreDataProperties.swift
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

extension User {

    @NSManaged var userName: String
    @NSManaged var email: String?
    @NSManaged var roles: NSData?
    @NSManaged var userID: NSDecimalNumber
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var site: String?
    @NSManaged var about: String?
    @NSManaged var createdCommunity: Community?

}

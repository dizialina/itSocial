//
//  Community+CoreDataProperties.swift
//  Itboost
//
//  Created by Alina Yehorova on 15.09.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import CoreData

extension Community {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Community> {
        return NSFetchRequest<Community>(entityName: "Community");
    }

    @NSManaged public var communityID: NSDecimalNumber
    @NSManaged public var createdAt: Date?
    @NSManaged public var detailDescription: String?
    @NSManaged public var eventDate: Date?
    @NSManaged public var name: String?
    @NSManaged public var threadID: NSDecimalNumber
    @NSManaged public var eventEndDate: Date?
    @NSManaged public var eventPrice: NSDecimalNumber?
    @NSManaged public var eventSpecializations: Data?
    @NSManaged public var eventSite: String?
    @NSManaged public var eventType: String?
    @NSManaged public var locations: Data?
    @NSManaged public var subscribersCount: NSDecimalNumber?
    @NSManaged public var eventAvatar: String?
    @NSManaged public var avatarImage: Data?
    @NSManaged public var countryID: NSDecimalNumber?
    @NSManaged public var cityID: NSDecimalNumber?
    @NSManaged public var isJoined: NSNumber?
    @NSManaged var createdBy: User

}

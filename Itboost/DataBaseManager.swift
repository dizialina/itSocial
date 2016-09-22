//
//  DataBaseManager.swift
//  Itboost
//
//  Created by Admin on 01.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DataBaseManager: NSObject {
    
    // MARK: Custom methods
    
    func writeAllCommunities(_ communitiesArray:[AnyObject], isLastPage:Bool) {
        
        if communitiesArray.count > 0 {
            
            var communities = [Int:Community]()
            var newID = [Int]()
            
            for community in communitiesArray {
                
                let communityDictionary = community as! [String:AnyObject]
                let currentCommunity = NSEntityDescription.insertNewObject(forEntityName: "Community", into: self.managedObjectContext) as! Community
                
                currentCommunity.name = (communityDictionary["name"] as? String)!
                currentCommunity.eventSite = communityDictionary["event_site"] as? String
                
                if let detailDescription = communityDictionary["description"] as? String {
                    // Remove HTML tags
                    
                    let attributedString = try! NSAttributedString(
                        data: detailDescription.data(using: String.Encoding.unicode, allowLossyConversion: true)!,
                        options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                        documentAttributes: nil)
                    currentCommunity.detailDescription = attributedString.string
                }
                
                if let eventAvatar = communityDictionary["avatar"] as? [String:AnyObject] {
                    if let eventAvatar = eventAvatar["path"] as? String {
                        let formattedPath = eventAvatar.replacingOccurrences(of: "\\/", with: "\\")
                        currentCommunity.eventAvatar = "http://api.itboost.org:88\(formattedPath)"
                        if let url = URL(string: currentCommunity.eventAvatar!) {
                            if let data = try? Data(contentsOf: url) {
                                currentCommunity.avatarImage = data
                            }
                        }
                    }
                }
                
                if let eventPrice = communityDictionary["event_price"] as? Int {
                    currentCommunity.eventPrice = NSDecimalNumber(value: eventPrice)
                }
                
                if let subscribersCount = communityDictionary["subscribers_count"] as? Int {
                    currentCommunity.subscribersCount = NSDecimalNumber(value: subscribersCount)
                }
                
                if let eventType = communityDictionary["event_type"] as? [String:AnyObject] {
                    if let typeName = eventType["type_name"] as? String {
                        currentCommunity.eventType = typeName
                    }
                }
                
                let createdAtString = communityDictionary["created_at"] as? String
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                currentCommunity.createdAt = dateFormatter.date(from: createdAtString!)
                
                if let eventDateString = communityDictionary["event_start_date"] as? String {
                    currentCommunity.eventDate = dateFormatter.date(from: eventDateString)
                }
                if let eventDateString = communityDictionary["event_end_date"] as? String {
                    currentCommunity.eventEndDate = dateFormatter.date(from: eventDateString)
                }
                
                let communityIDInt = communityDictionary["id"] as? Int
                currentCommunity.communityID = NSDecimalNumber(value: communityIDInt! as Int)
                communities[communityIDInt!] = currentCommunity
                newID.append(communityIDInt!)
                
                let threadIDInt = communityDictionary["thread_id"] as? Int
                currentCommunity.threadID = NSDecimalNumber(value: threadIDInt! as Int)
                
                // Parse and write event specializations
                
                if let eventSpecializations = communityDictionary["event_specializations"] as? [AnyObject] {
                    if eventSpecializations.count > 0 {
                        
                        var specializationsName = [String]()
                        for specialization in eventSpecializations {
                            if specialization is [String:AnyObject] {
                                if let name = specialization["specialization_name"] as? String {
                                    specializationsName.append(name)
                                }
                            }
                        }
                        
                        let specializationsData = NSKeyedArchiver.archivedData(withRootObject: specializationsName)
                        currentCommunity.eventSpecializations = specializationsData
                    }
                }
                
                // Parse and write event locations
                
                if let locations = communityDictionary["locations"] as? [AnyObject] {
                    if locations.count > 0 {
                        
                        var locationsDictionary = [String:AnyObject]()
                        for location in locations {
                            if location is [String:AnyObject] {
                                if let country = location["country"] as? [String:AnyObject] {
                                    if let countryName = country["country_name"] {
                                        locationsDictionary["country"] = countryName
                                    }
                                }
                                if let city = location["city"] as? [String:AnyObject] {
                                    if let cityName = city["city_name"] as? String {
                                        locationsDictionary["city"] = cityName as AnyObject?
                                    }
                                    if let country = city["country"] as? [String:AnyObject]  {
                                        if let countryName = country["country_name"] as? String {
                                            locationsDictionary["country"] = countryName as AnyObject?
                                        }
                                    }
                                    if let regionName = city["region_name"] as? String {
                                        locationsDictionary["region"] = regionName as AnyObject?
                                    }
                                    if let stateName = city["state_name"] as? String {
                                        locationsDictionary["state"] = stateName as AnyObject?
                                    }
                                }
                                if let street = location["street"] as? String {
                                    locationsDictionary["street"] = street as AnyObject?
                                }
                                if let place = location["place"] as? String {
                                    locationsDictionary["place"] = place as AnyObject?
                                }
                                if let latitude = location["latitude"] as? Float {
                                    locationsDictionary["latitude"] = latitude as AnyObject?
                                }
                                if let longitude = location["longitude"] as? Float {
                                    locationsDictionary["longitude"] = longitude as AnyObject?
                                }
                            }
                        }
                        
                        let locationsDate = NSKeyedArchiver.archivedData(withRootObject: locationsDictionary)
                        currentCommunity.locations = locationsDate
                    }
                }
                
                // Write creator info
                
                let currentCreator = NSEntityDescription.insertNewObject(forEntityName: "User", into: self.managedObjectContext) as! User
                
                if let creator = communityDictionary["created_by"] as? [String:AnyObject] {
                
                    if let userName = creator["username"] as? String {
                        currentCreator.userName = userName
                    } else {
                        currentCreator.userName = "Speaker"
                    }
                    
                    currentCreator.email = creator["email"] as? String
                    currentCreator.firstName = creator["firstname"] as? String
                    currentCreator.lastName = creator["lastName"] as? String
                    currentCreator.site = creator["site"] as? String
                    currentCreator.about = creator["about"] as? String
                
                    let userIDInt = (creator["id"] as? Int)!
                    currentCreator.userID = NSDecimalNumber(value: userIDInt as Int)
                
                    if let roles = creator["roles"] as? [String] {
                        if roles.count > 0 {
                            let rolesData = NSKeyedArchiver.archivedData(withRootObject: roles)
                            currentCreator.roles = rolesData
                        }
                    }
                }
                
                currentCommunity.createdBy = currentCreator
            }
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Community")
            fetchRequest.includesPendingChanges = false
            fetchRequest.predicate = NSPredicate(format: "communityID IN %@", newID)
            
            do {
                let existingCommunities = try managedObjectContext.fetch(fetchRequest) as! [Community]
                
                for requestCommunity in existingCommunities {
                    let communityID = requestCommunity.communityID.intValue
                    let newCommunity = communities[communityID]
                    
                    requestCommunity.createdAt = (newCommunity?.createdAt)!
                    requestCommunity.detailDescription = newCommunity?.detailDescription
                    requestCommunity.eventDate = newCommunity?.eventDate
                    requestCommunity.name = newCommunity?.name
                    requestCommunity.threadID = (newCommunity?.threadID)!
                    requestCommunity.eventEndDate = newCommunity?.eventEndDate
                    requestCommunity.eventPrice = newCommunity?.eventPrice
                    requestCommunity.eventSpecializations = newCommunity?.eventSpecializations
                    requestCommunity.eventSite = newCommunity?.eventSite
                    requestCommunity.eventType = newCommunity?.eventType
                    requestCommunity.locations = newCommunity?.locations
                    requestCommunity.subscribersCount = newCommunity?.subscribersCount
                    requestCommunity.eventAvatar = newCommunity?.eventAvatar
                    requestCommunity.createdBy = (newCommunity?.createdBy)!
                    
                    managedObjectContext.delete(newCommunity!)
                }
                
            } catch {
                print("Can't execute fetch request by event groups need to write/update")
            }
            
            do {
                try managedObjectContext.save()
                //if isLastPage {
                    NotificationCenter.default.post(name: Constants.LoadCommunitiesNotification, object: nil)
                //}
            } catch let error as NSError {
                print("Can't save to coredata new communities. Error: \(error.localizedDescription)")
            }
            
        }
        
    }
    
    func printAllCommunitiesForDebug() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Community")
        let sortDescriptor = NSSortDescriptor(key: "communityID", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let allCommunities = try managedObjectContext.fetch(fetchRequest) as! [Community]
            for community in allCommunities {
                print(community)
            }
            
        } catch {
            print("Can't get all communities from database")
        }
        
    }
    
    func writeAllOrganizations(_ organizationsArray:[AnyObject], isLastPage:Bool) {
        
        if organizationsArray.count > 0 {
            
            var organizations = [Int:Organization]()
            var newID = [Int]()
            
            for organization in organizationsArray {
                
                let organizationDictionary = organization as! [String:AnyObject]
                let currentOrganization = NSEntityDescription.insertNewObject(forEntityName: "Organization", into: self.managedObjectContext) as! Organization
                
                currentOrganization.name = (organizationDictionary["name"] as? String)!
                currentOrganization.specialization = "some specialization"
                currentOrganization.detailDescription = organizationDictionary["description"] as? String
                
                let createdAtString = organizationDictionary["created_at"] as? String
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                currentOrganization.createdAt = dateFormatter.date(from: createdAtString!)
                
                let organizationIDInt = organizationDictionary["id"] as? Int
                currentOrganization.organizationID = NSDecimalNumber(value: organizationIDInt! as Int)
                organizations[organizationIDInt!] = currentOrganization
                newID.append(organizationIDInt!)
                
                let threadIDInt = organizationDictionary["thread_id"] as? Int
                currentOrganization.threadID = NSDecimalNumber(value: threadIDInt! as Int)
                
                let subscribersInt = organizationDictionary["subscribers_count"] as? Int
                currentOrganization.subscribersCount = NSDecimalNumber(value: subscribersInt! as Int)
                
                let creator = organizationDictionary["created_by"] as? [String:AnyObject]
                let currentCreator = NSEntityDescription.insertNewObject(forEntityName: "User", into: self.managedObjectContext) as! User
                
                currentCreator.userName = (creator!["username"] as? String)!
                currentCreator.email = creator!["email"] as? String
                currentCreator.firstName = creator!["firstname"] as? String
                currentCreator.lastName = creator!["lastName"] as? String
                currentCreator.site = creator!["site"] as? String
                currentCreator.about = creator!["about"] as? String
                
                let userIDInt = (creator!["id"] as? Int)!
                currentCreator.userID = NSDecimalNumber(value: userIDInt as Int)
                
                if let roles = creator!["roles"] as? [String] {
                    if roles.count > 0 {
                        let rolesData = NSKeyedArchiver.archivedData(withRootObject: roles)
                        currentCreator.roles = rolesData
                    }
                }
                
                currentOrganization.createdBy = currentCreator
                
            }
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Organization")
            fetchRequest.includesPendingChanges = false
            fetchRequest.predicate = NSPredicate(format: "organizationID IN %@", newID)
            
            do {
                let existingOrganizations = try managedObjectContext.fetch(fetchRequest) as! [Organization]
                
                for requestOrganization in existingOrganizations {
                    let organizationID = requestOrganization.organizationID.intValue
                    let newOrganization = organizations[organizationID]
                    
                    requestOrganization.name = (newOrganization?.name)!
                    requestOrganization.specialization = newOrganization?.specialization
                    requestOrganization.detailDescription = newOrganization?.detailDescription
                    requestOrganization.createdAt = newOrganization?.createdAt
                    requestOrganization.createdBy = newOrganization?.createdBy
                    requestOrganization.subscribersCount = newOrganization?.subscribersCount
                    requestOrganization.threadID = (newOrganization?.threadID)!
                    
                    managedObjectContext.delete(newOrganization!)
                }
                
            } catch {
                print("Can't execute fetch request by organization groups need to write/update")
            }
            
            do {
                try managedObjectContext.save()
                if isLastPage {
                    NotificationCenter.default.post(name: Constants.LoadOrganizationsNotification, object: nil)
                }
            } catch let error as NSError {
                print("Can't save to coredata new organizations. Error: \(error.localizedDescription)")
            }
            
        }
        
    }
    
    
    // MARK: Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "AE.Itboost" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        
        let modelURL = Bundle.main.url(forResource: "Itboost", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            //dict[NSUnderlyingErrorKey] = error as! NSError
            //let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            
            //NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            //abort()
            
            do {
                try FileManager.default.removeItem(at: url)
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            } catch {
                print("Error removing old database file and writing new file")
            }
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: Core Data Saving support
    
    func saveContext () {
        
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
}

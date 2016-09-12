//
//  DataBaseManager.swift
//  Itboost
//
//  Created by Admin on 01.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import CoreData

class DataBaseManager: NSObject {
    
    // MARK: Custom methods
    
    func writeAllCommunities(communitiesArray:[AnyObject], isLastPage:Bool) {
        
        if communitiesArray.count > 0 {
            
            var communities = [Int:Community]()
            var newID = [Int]()
            
            for community in communitiesArray {
                
                let communityDictionary = community as! [String:AnyObject]
                let currentCommunity = NSEntityDescription.insertNewObjectForEntityForName("Community", inManagedObjectContext: self.managedObjectContext) as! Community
                
                currentCommunity.name = (communityDictionary["name"] as? String)!
                currentCommunity.detailDescription = communityDictionary["description"] as? String
                
                let createdAtString = communityDictionary["created_at"] as? String
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                currentCommunity.createdAt = dateFormatter.dateFromString(createdAtString!)
                if let eventDateString = communityDictionary["event_start_date"] as? String {
                    currentCommunity.eventDate = dateFormatter.dateFromString(eventDateString)
                }
                
                let communityIDInt = communityDictionary["id"] as? Int
                currentCommunity.communityID = NSDecimalNumber(integer: communityIDInt!)
                communities[communityIDInt!] = currentCommunity
                newID.append(communityIDInt!)
                
                let threadIDInt = communityDictionary["thread_id"] as? Int
                currentCommunity.threadID = NSDecimalNumber(integer: threadIDInt!)
                
                let creator = communityDictionary["created_by"] as? [String:AnyObject]
                let currentCreator = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: self.managedObjectContext) as! User
                
                //currentCreator.userName = (creator!["username"] as? String)!
                currentCreator.userName = "user name"
                currentCreator.email = creator!["email"] as? String
                currentCreator.firstName = creator!["firstname"] as? String
                currentCreator.lastName = creator!["lastName"] as? String
                currentCreator.site = creator!["site"] as? String
                currentCreator.about = creator!["about"] as? String
                
                let userIDInt = (creator!["id"] as? Int)!
                currentCreator.userID = NSDecimalNumber(integer: userIDInt)
                
                let roles = creator!["roles"] as? [String]
                if roles?.count > 0 {
                    let rolesData = NSKeyedArchiver.archivedDataWithRootObject(roles!)
                    currentCreator.roles = rolesData
                }
                
                currentCommunity.createdBy = currentCreator
            }
            
            let fetchRequest = NSFetchRequest(entityName: "Community")
            fetchRequest.includesPendingChanges = false
            fetchRequest.predicate = NSPredicate(format: "communityID IN %@", newID)
            
            do {
                let existingCommunities = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Community]
                
                for requestCommunity in existingCommunities {
                    let communityID = Int(requestCommunity.communityID.intValue)
                    let newCommunity = communities[communityID]
                    
                    requestCommunity.name = (newCommunity?.name)!
                    requestCommunity.detailDescription = newCommunity?.detailDescription
                    requestCommunity.createdAt = newCommunity?.createdAt
                    requestCommunity.eventDate = newCommunity?.eventDate
                    requestCommunity.createdBy = (newCommunity?.createdBy)!
                    
                    managedObjectContext.deleteObject(newCommunity!)
                }
                
            } catch {
                print("Can't execute fetch request by event groups need to write/update")
            }
            
            do {
                try managedObjectContext.save()
                if isLastPage {
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.kLoadCommunitiesNotification, object: nil)
                }
            } catch let error as NSError {
                print("Can't save to coredata new communities. Error: \(error.localizedDescription)")
            }
            
        }
        
    }
    
    func printAllCommunitiesForDebug() {
        
        let fetchRequest = NSFetchRequest(entityName: "Community")
        let sortDescriptor = NSSortDescriptor(key: "communityID", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let allCommunities = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Community]
            for community in allCommunities {
                print(community)
            }
            
        } catch {
            print("Can't get all communities from database")
        }
        
    }
    
    func writeAllOrganizations(organizationsArray:[AnyObject], isLastPage:Bool) {
        
        if organizationsArray.count > 0 {
            
            var organizations = [Int:Organization]()
            var newID = [Int]()
            
            for organization in organizationsArray {
                
                let organizationDictionary = organization as! [String:AnyObject]
                let currentOrganization = NSEntityDescription.insertNewObjectForEntityForName("Organization", inManagedObjectContext: self.managedObjectContext) as! Organization
                
                currentOrganization.name = (organizationDictionary["name"] as? String)!
                currentOrganization.specialization = "some specialization"
                currentOrganization.detailDescription = organizationDictionary["description"] as? String
                
                let createdAtString = organizationDictionary["created_at"] as? String
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                currentOrganization.createdAt = dateFormatter.dateFromString(createdAtString!)
                
                let organizationIDInt = organizationDictionary["id"] as? Int
                currentOrganization.organizationID = NSDecimalNumber(integer: organizationIDInt!)
                organizations[organizationIDInt!] = currentOrganization
                newID.append(organizationIDInt!)
                
                let threadIDInt = organizationDictionary["thread_id"] as? Int
                currentOrganization.threadID = NSDecimalNumber(integer: threadIDInt!)
                
                let subscribersInt = organizationDictionary["subscribers_count"] as? Int
                currentOrganization.subscribersCount = NSDecimalNumber(integer: subscribersInt!)
                
                let creator = organizationDictionary["created_by"] as? [String:AnyObject]
                let currentCreator = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: self.managedObjectContext) as! User
                
                currentCreator.userName = (creator!["username"] as? String)!
                currentCreator.email = creator!["email"] as? String
                currentCreator.firstName = creator!["firstname"] as? String
                currentCreator.lastName = creator!["lastName"] as? String
                currentCreator.site = creator!["site"] as? String
                currentCreator.about = creator!["about"] as? String
                
                let userIDInt = (creator!["id"] as? Int)!
                currentCreator.userID = NSDecimalNumber(integer: userIDInt)
                
                let roles = creator!["roles"] as? [String]
                if roles?.count > 0 {
                    let rolesData = NSKeyedArchiver.archivedDataWithRootObject(roles!)
                    currentCreator.roles = rolesData
                }
                
                currentOrganization.createdBy = currentCreator
                
            }
            
            let fetchRequest = NSFetchRequest(entityName: "Organization")
            fetchRequest.includesPendingChanges = false
            fetchRequest.predicate = NSPredicate(format: "organizationID IN %@", newID)
            
            do {
                let existingOrganizations = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Organization]
                
                for requestOrganization in existingOrganizations {
                    let organizationID = Int(requestOrganization.organizationID.intValue)
                    let newOrganization = organizations[organizationID]
                    
                    requestOrganization.name = (newOrganization?.name)!
                    requestOrganization.specialization = newOrganization?.specialization
                    requestOrganization.detailDescription = newOrganization?.detailDescription
                    requestOrganization.createdAt = newOrganization?.createdAt
                    requestOrganization.createdBy = newOrganization?.createdBy
                    requestOrganization.subscribersCount = newOrganization?.subscribersCount
                    requestOrganization.threadID = (newOrganization?.threadID)!
                    
                    managedObjectContext.deleteObject(newOrganization!)
                }
                
            } catch {
                print("Can't execute fetch request by organization groups need to write/update")
            }
            
            do {
                try managedObjectContext.save()
                if isLastPage {
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.kLoadOrganizationsNotification, object: nil)
                }
            } catch let error as NSError {
                print("Can't save to coredata new organizations. Error: \(error.localizedDescription)")
            }
            
        }
        
    }
    
    
    // MARK: Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "AE.Itboost" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        
        let modelURL = NSBundle.mainBundle().URLForResource("Itboost", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            //dict[NSUnderlyingErrorKey] = error as! NSError
            //let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            
            //NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            //abort()
            
            do {
                try NSFileManager.defaultManager().removeItemAtURL(url)
                try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
            } catch {
                print("Error removing old database file and writing new file")
            }
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
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

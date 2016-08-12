//
//  LoadEventsOperation.swift
//  Itboost
//
//  Created by Alina Yehorova on 12.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation

class LoadEventsOperation: NSOperation {
        
    // NSOperation override
    var _executing:Bool = false
    var _finished:Bool = false
    
    //Property's of class
    let linkToRequestData:String
    let dispatchQueue:NSOperationQueue
    
    // Designed initializer
    init(linkToData:String, queue:NSOperationQueue) {
        self.linkToRequestData = linkToData
        self.dispatchQueue = queue
    }
        
    // Method start override
    override func start() {
            
        if self.cancelled {
            self._finished = true
            return;
        }
    
        createOperationForLoadTask(linkToRequestData, queue: dispatchQueue)
        self._executing = true
    }
    
    /// Function to request data from server async with block to handle responce from server
    func createOperationForLoadTask(linkToLoad:String, queue:NSOperationQueue) {
        let serverManager = ServerManager()
        
        serverManager.getOnePageCommunityFromServer(linkToLoad, operationQueue: queue, success: { (response, currentPage) in
            
            let communitiesArray = response as! [AnyObject]
            
            let countOfCommunitiesPerOnePage = communitiesArray.count
            if countOfCommunitiesPerOnePage == 10 {
                
                DataBaseManager().writeAllCommunities(communitiesArray, isLastPage:false)
                let nextPage = currentPage + 1
                let newLinkToData = self.linkToRequestData + "?page=\(nextPage)"
                let newLoadEventsOperataion = LoadEventsOperation(linkToData: newLinkToData, queue: self.dispatchQueue)
                self.dispatchQueue.addOperation(newLoadEventsOperataion)
                
            } else {
                print("Load done for all community pages")
                DataBaseManager().writeAllCommunities(communitiesArray, isLastPage:true)
            }
        
        }) { (error) in
            print("Error loading one page community: " + error!.localizedDescription)
        }
        
        
            
//        requestClient.requestCropioResourcesFromURLAsync(linkToLoad, forObjecType: objectType, inOperationQueue:  queue, successHandlerBlock: { (responce, objType) in
//                
//            /// Save downloaded object to core data
//            self.saveObjectToCoreData(objectType, data: responce)
//                
//                
//                // if the last record id not nil than add download resource to queue(pagination)
//                let lastRecordId = requestClient.checkTheResponce(responce, objType: objectType)
//                if lastRecordId != nil {
//                    // Increment last record id
//                    let incrementIDOfObjet = String(lastRecordId! + 1)
//                    // Create new link
//                    let newLink = requestClient.createLinkForResource(objType, linkType:LinkType.FromIdLink) + incrementIDOfObjet
//                    //Add new download task to queue
//                    let newDownloadTask = CTResourceDownloadProcess(linkToTheData: newLink, objType: objectType, queue: queue,operationType: operationType)
//                    queue.addOperation(newDownloadTask)
//                    
//                    
//                    
//                    
//                } else { // Last record id is nil, all data for resource is loaded
//                    
//                    let someString:String = "\n Loading Done For Object:" + objType.description + "\n"
//                    print("\(someString)")
//                    var keyToPushNotification:String
//                    
//                    if operationType == .Load {
//                        keyToPushNotification = "dataLoadInApp"
//                    } else {
//                        keyToPushNotification = "dataUpdateInApp"
//                    }
//                    NSNotificationCenter.defaultCenter().postNotificationName(keyToPushNotification,object:nil)
//                    
//                }
//                
//                self.executing = false
//                self.finished = true
//                
//                }, failureHandlerBlock: { (returnedError) in
//                    let newDownloadTask = CTResourceDownloadProcess(linkToTheData: linkToLoad, objType: objectType, queue: queue, operationType: operationType )
//                    queue.addOperation(newDownloadTask)
//                    self.executing = false
//                    self.finished = true
//                    print("Error:" + returnedError.description + " for object:" + objectType.description)
//            })
        
        
    }
    
    
    func getOnePageCommunityFromServer(sourceURL:String, operationQueue:NSOperationQueue, success: (response: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string:sourceURL)!)
        request.HTTPMethod = "GET"
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue: operationQueue)
        session.dataTaskWithRequest(request) { (data, response, error) in
            if error != nil {
                do {
                    let responseDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                    print(responseDict)
                } catch {
                    print("Error parcing community json")
                }
            }
        }
        
    }
        
    override var asynchronous: Bool {
        return true
    }
        
    override var executing: Bool {
        get { return _executing }
        set {
            willChangeValueForKey("isExecuting")
            _executing = newValue
            didChangeValueForKey("isExecuting")
        }
    }
        
    /// Override read-only superclass property as read-write.
    override var finished: Bool {
        get { return _finished }
        set {
            willChangeValueForKey("isFinished")
            _finished = newValue
            didChangeValueForKey("isFinished")
        }
    }
    
    func completeOperation() {
        self._executing = false
        self._finished = true
            
    }
        
}
    


//
//  LoadEventsOperation.swift
//  Itboost
//
//  Created by Alina Yehorova on 12.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation

class LoadEventsOperation: Operation {
        
    // NSOperation override
    var _executing:Bool = false
    var _finished:Bool = false
    
    //Property's of class
    let linkToRequestData:String
    let dispatchQueue:OperationQueue
    let dataType:LoadingDataType
    let currentPage:Int
    
    // Designed initializer
    init(linkToData:String, currentPage:Int, queue:OperationQueue, dataType:LoadingDataType) {
        self.linkToRequestData = linkToData
        self.dispatchQueue = queue
        self.dataType = dataType
        self.currentPage = currentPage
    }
        
    // Method start override
    override func start() {
            
        if self.isCancelled {
            self._finished = true
            return
        }
    
        createOperationForLoadTask()
        self._executing = true
    }
    
    /// Function to request data from server async with block to handle responce from server
    func createOperationForLoadTask() {
        let serverManager = ServerManager()
        
        switch self.dataType {
        case .events:
            
            serverManager.getOnePageEventsFromServer(linkToRequestData, currentPage: currentPage, operationQueue: dispatchQueue, success: { (response, currentPage) in
                
                let communitiesArray = response as! [AnyObject]
                
                let countOfCommunitiesPerOnePage = communitiesArray.count
                if countOfCommunitiesPerOnePage == 10 {
                    
                    DataBaseManager().writeAllCommunities(communitiesArray, isLastPage:false)
                    let nextPage = currentPage + 1
                    let newLoadEventsOperataion = LoadEventsOperation(linkToData: self.linkToRequestData, currentPage: nextPage, queue: self.dispatchQueue, dataType: self.dataType)
                    self.dispatchQueue.addOperation(newLoadEventsOperataion)
                    
                } else {
                    print("Load done for all events pages")
                    DataBaseManager().writeAllCommunities(communitiesArray, isLastPage:true)
                }
                
            }) { (error) in
                print("Error loading one page events: " + error!.localizedDescription)
            }
            
        case .organizations:
            
            serverManager.getOnePageOrganizationsFromServer(linkToRequestData, currentPage: currentPage, operationQueue: dispatchQueue, success: { (response, currentPage) in
                
                let organizationsArray = response as! [AnyObject]
                
                let countOfCommunitiesPerOnePage = organizationsArray.count
                if countOfCommunitiesPerOnePage == 10 {
                    
                    DataBaseManager().writeAllOrganizations(organizationsArray, isLastPage:false)
                    let nextPage = currentPage + 1
                    let newLoadEventsOperataion = LoadEventsOperation(linkToData: self.linkToRequestData, currentPage: nextPage, queue: self.dispatchQueue, dataType: self.dataType)
                    self.dispatchQueue.addOperation(newLoadEventsOperataion)
                    
                } else {
                    print("Load done for all organizations pages")
                    DataBaseManager().writeAllOrganizations(organizationsArray, isLastPage:true)
                }
                
            }) { (error) in
                print("Error loading one page organizations: " + error!.localizedDescription)
            }
            
        }
        
        
    }
    
    override var isAsynchronous: Bool {
        return true
    }
        
    override var isExecuting: Bool {
        get { return _executing }
        set {
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }
        
    /// Override read-only superclass property as read-write.
    override var isFinished: Bool {
        get { return _finished }
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    
    func completeOperation() {
        self._executing = false
        self._finished = true
            
    }
        
}
    


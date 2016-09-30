//
//  LoadPaginaionManager.swift
//  Itboost
//
//  Created by Alina Yehorova on 12.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation

enum LoadingDataType {
    case events
    case organizations
    case joinedEvents
}

class LoadPaginaionManager: NSObject {
    
    func loadAllEventsFromServer() {
        
        let operationQueue = OperationQueue()
        
        let urlString = Constants.linkToServerAPI + "events"
        
        let loadEventsOperation = LoadEventsOperation(linkToData: urlString, currentPage: 1, queue: operationQueue, dataType: .events)
        operationQueue.addOperation(loadEventsOperation)
        operationQueue.waitUntilAllOperationsAreFinished()
    }
    
    func loadAllOrganizationsFromServer() {
        
        let operationQueue = OperationQueue()
        
        let urlString = Constants.linkToServerAPI + "organizations"
        
        let loadOrganizationOperation = LoadEventsOperation(linkToData: urlString, currentPage: 1, queue: operationQueue, dataType: .organizations)
        operationQueue.addOperation(loadOrganizationOperation)
        operationQueue.waitUntilAllOperationsAreFinished()
    }
    
    func loadJoinedEventsFromServer() {
        
        let operationQueue = OperationQueue()
        
        let urlString = Constants.linkToServerAPI + "events"
        
        let loadEventsOperation = LoadEventsOperation(linkToData: urlString, currentPage: 1, queue: operationQueue, dataType: .joinedEvents)
        operationQueue.addOperation(loadEventsOperation)
        operationQueue.waitUntilAllOperationsAreFinished()
    }

}

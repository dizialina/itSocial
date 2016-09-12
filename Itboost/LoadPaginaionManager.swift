//
//  LoadPaginaionManager.swift
//  Itboost
//
//  Created by Alina Yehorova on 12.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation

enum LoadingDataType {
    case Events
    case Organizations
}

class LoadPaginaionManager: NSObject {
    
    func loadAllEventsFromServer() {
        
        let operationQueue = NSOperationQueue()
        
        let urlString = Constants.linkToServerAPI + "event.getAll"
        
        let loadEventsOperation = LoadEventsOperation(linkToData: urlString, queue: operationQueue, dataType: .Events)
        operationQueue.addOperation(loadEventsOperation)
        operationQueue.waitUntilAllOperationsAreFinished()
    }
    
    func loadAllOrganizationsFromServer() {
        
        let operationQueue = NSOperationQueue()
        
        let urlString = Constants.linkToServerAPI + "organization.getAll"
        
        let loadOrganizationOperation = LoadEventsOperation(linkToData: urlString, queue: operationQueue, dataType: .Organizations)
        operationQueue.addOperation(loadOrganizationOperation)
        operationQueue.waitUntilAllOperationsAreFinished()
    }
    
    func loadObjectFirstRequest() {
        
    }

}

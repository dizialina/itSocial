//
//  LoadPaginaionManager.swift
//  Itboost
//
//  Created by Alina Yehorova on 12.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation

class LoadPaginaionManager: NSObject {
    
    func loadAllEventsFromServer() {
        
        let operationQueue = NSOperationQueue()
        
        let urlString = Constants.linkToServerAPI + "event.getAll"
        
        let loadEventsOperation = LoadEventsOperation(linkToData: urlString, queue: operationQueue)
        operationQueue.addOperation(loadEventsOperation)
        operationQueue.waitUntilAllOperationsAreFinished()
    }
    
    func loadObjectFirstRequest() {
        
    }

}

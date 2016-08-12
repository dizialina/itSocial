//
//  DownloadTask.swift
//  Itboost
//
//  Created by Alina Yehorova on 11.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation

enum ObjType {
    case SomeType
    case SomeType2
}

class LoadTaskHunter: NSOperation {
    
    let linkToload:String
    let objType:ObjType
    
    var _executing:Bool = false
    var _finished:Bool = false
    
    init(link:String, type:ObjType) {
        linkToload = link
        objType = type
    }
    
    override func start() {
        if self.cancelled {
            self._finished = true
            return;
        }
        self.letsLoad()
        self._executing = true
    }
    
    func letsLoad() {
        let manger = ServerManager()
        //manger.requestItemFromID(someId) <- Start background operation
    }
    
    func saveObjects(/* objects to save */) {
        
    }
    
    override var asynchronous: Bool {
        return true;
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

class LoadManager: NSObject {
   
    func loadAllItemsFromServer() {
        
        let queue = NSOperationQueue()
        
        let urlString = "www.httpswww.com"
        
        let loadItem = LoadTaskHunter(link:urlString, type: .SomeType)
        queue.addOperation(loadItem)
        queue.waitUntilAllOperationsAreFinished()
    }
    
    func loadObjectFirstRequest() {
        
    }
}
//
//  ServerManager.swift
//  Itboost
//
//  Created by Admin on 01.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import AFNetworking

class ServerManager {
    
    var sessionManager = AFHTTPSessionManager()
    
    init() {
        let serverURL = NSURL(string: Constants.linkToServerAPI)
        sessionManager = AFHTTPSessionManager(baseURL: serverURL)
    }
    
    func loadData(typeOfDownload:String) {
        
        switch typeOfDownload {
        case "load":
            //getTaskListFromServer(false)
            break
        case "update":
            //getTaskListFromServer(true)
            break
        default:
            //getTaskListFromServer(true)
            break
            
        }
        
    }
    
    // MARK: GET methods
    
    func getAllCommunitiesFromServer() {
        
        sessionManager.GET("community.getAll", parameters:nil, progress:nil, success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
            if let response:Dictionary<String, AnyObject> = responseObject as? Dictionary {
                if let results = response["response"] {
                    //print(results)
                    DataBaseManager().writeAllCommunities(results as! [AnyObject])
                } else {
                    print("Reques tasks from server = nil")
                }
            }
        })
        { (task:NSURLSessionDataTask?, error:NSError) in
            print("Error: " + error.localizedDescription)
        }
        
    }
}


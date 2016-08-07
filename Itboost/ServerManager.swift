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
    
    // MARK: Profile methods
    
    func postAuthorization(userInfo:NSDictionary, success: (response: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        
        let params:NSDictionary = ["_username": userInfo["username"]!,
                                   "_password": userInfo["password"]!]
        
        sessionManager.POST("login_check", parameters:params, progress:nil, success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
            print(responseObject)
            if let response:Dictionary<String, AnyObject> = responseObject as? Dictionary {
                if let results = response["response"] {
                    
                    let token = results["token"]
                    let receivedUserInfo = results["user"]
                    if receivedUserInfo != nil {
                        if let userID = receivedUserInfo!!["id"] {
                            NSUserDefaults.standardUserDefaults().setValue(userID, forKey: Constants.kUserID)
                        }
                    }
                    if token != nil {
                        NSUserDefaults.standardUserDefaults().setValue(token, forKey: Constants.kUserToken)
                    }
                    success(response: nil)
                }
            } else {
                print("Post authorization didn't return dictionary responce")
            }
            })
        { (task:NSURLSessionDataTask?, error:NSError) in
            print("Error while authorization: " + error.localizedDescription)
            failure(error: error)
        }
        
    }
    
    func postRegistration(userInfo:NSDictionary, success: (response: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        
        let params:NSDictionary = ["email": userInfo["email"]!,
                                   "username": userInfo["username"]!,
                                   "password": userInfo["password"]!]
        
        sessionManager.POST("registration", parameters:params, progress:nil, success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
            print(responseObject)
            if let response:Dictionary<String, AnyObject> = responseObject as? Dictionary {
                if let results = response["response"] {
                    
                    let token = results["token"]
                    let receivedUserInfo = results["user"]
                    if receivedUserInfo != nil {
                        if let userID = receivedUserInfo!!["id"] {
                            NSUserDefaults.standardUserDefaults().setValue(userID, forKey: Constants.kUserID)
                        }
                    }
                    if token != nil {
                        NSUserDefaults.standardUserDefaults().setValue(token, forKey: Constants.kUserToken)
                    }
                    success(response: nil)
                }
            } else {
                print("Post registration didn't return dictionary responce")
            }
            })
        { (task:NSURLSessionDataTask?, error:NSError) in
            print("Error while sending registration info: " + error.localizedDescription)
            failure(error: error)
        }
        
    }

}


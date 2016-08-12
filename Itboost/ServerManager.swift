//
//  ServerManager.swift
//  Itboost
//
//  Created by Admin on 01.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import AFNetworking

class ServerManager: NSObject {
    
    var sessionManager = AFHTTPSessionManager()
    
    override init() {
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
    
    // MARK: Communities methods
    
    func getAllCommunitiesFromServer() {
        
        sessionManager.GET("community.getAll", parameters:nil, progress:nil, success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
            if let response:Dictionary<String, AnyObject> = responseObject as? Dictionary {
                if let results = response["response"] {
                    print(results)
                    DataBaseManager().writeAllCommunities(results as! [AnyObject], isLastPage:true)
                } else {
                    print("Reques tasks from server = nil")
                }
            }
        })
        { (task:NSURLSessionDataTask?, error:NSError) in
            print("Error loading all communities: " + error.localizedDescription)
        }
        
    }
    
    func getOnePageCommunityFromServer(lastID lastID:Int, success: (response: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        
        sessionManager.GET("community.getAll", parameters:nil, progress:nil, success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
            if let response:Dictionary<String, AnyObject> = responseObject as? Dictionary {
                print(response)
//                if let results = response["response"] {
//                    DataBaseManager().writeAllCommunities(results as! [AnyObject])
//                } else {
//                    print("Reques tasks from server = nil")
//                }
            }
            })
        { (task:NSURLSessionDataTask?, error:NSError) in
            print("Error loading one page community with lastID \(lastID): " + error.localizedDescription)
        }
        
    }
    
    // MARK: Profile methods
    
    func postAuthorization(userInfo:NSDictionary, success: (response: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        
        let params:NSDictionary = ["_username": userInfo["username"]!,
                                   "_password": userInfo["password"]!]
        print(params)
        
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
    
    // MARK: Wall methods
    
    func postNewMessageOnWall(threadIDDict:[String:Int], title:String, body:String, success: (response: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        
        let params:NSDictionary = ["thread": threadIDDict,
                                   "title": title,
                                   "body": body]
        print(params)
        
        if let token = NSUserDefaults.standardUserDefaults().valueForKey(Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.POST("wall.post", parameters:params, progress:nil, success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
            print(responseObject)
            success(response: nil)
            })
        { (task:NSURLSessionDataTask?, error:NSError) in
            print("Error while adding new post on wall: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error: error)
        }
        
        
    }
    
    func getEventWallPosts(threadID: Int, success: (response: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        
        let params:NSDictionary = ["thread_id": threadID]
        
        if let token = NSUserDefaults.standardUserDefaults().valueForKey(Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.GET("wall.get", parameters:params, progress:nil, success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
            //print(responseObject)
            if let response = responseObject as? [String:AnyObject] {
                if let results = response["response"] as? [AnyObject] {
                    success(response: results)
                }
            } else {
                print("Response with posts is empty")
                success(response: [])
            }
            })
        { (task:NSURLSessionDataTask?, error:NSError) in
            print("Error receiving wall posts from event: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error: error)
        }
        
        
    }

}


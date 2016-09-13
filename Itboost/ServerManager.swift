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
        
        sessionManager.GET("event.getAll", parameters:nil, success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
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
    
    func getOnePageCommunityFromServer(sourceURL:String, operationQueue:NSOperationQueue, success: (response: AnyObject!, currentPage:Int) -> Void, failure: (error: NSError?) -> Void) {
        
        let manager = AFHTTPRequestOperationManager()
        //manager.requestSerializer.setValue("application/json; charset=UTF-8", forHTTPHeaderField:"Content-Type")
        manager.operationQueue = operationQueue
        //manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        
        manager.GET(sourceURL, parameters: nil, success: { (operation, responce) in
            if let response:Dictionary<String, AnyObject> = responce as? Dictionary {
                //print(response)
                if let results = response["response"] {
                    if let communitiesArray = results["items"] as? [AnyObject] {
                        let currentPage = results["current_page_number"] as! Int
                        success(response: communitiesArray, currentPage: currentPage)
                    } else {
                        print("Response of community page has 0 items")
                    }
                }
            }
        }) { (operation, error) in
            print("Error loading one page community with url \(sourceURL): " + error.localizedDescription)
        }
    }
    
    func joinCommunity(communityID:Int, success: (response: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        
        let params:NSDictionary = ["community_id": communityID]
        
        if let token = NSUserDefaults.standardUserDefaults().valueForKey(Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.POST("community.join", parameters:params, success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
            print(responseObject)
            success(response: nil)
        })
        { (task:NSURLSessionDataTask?, error:NSError) in
            print("Error while joining community: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error: error)
        }
    }
    
    func leaveCommunity(communityID:Int, success: (response: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        
        let params:NSDictionary = ["community_id": communityID]
        
        if let token = NSUserDefaults.standardUserDefaults().valueForKey(Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.requestSerializer.HTTPMethodsEncodingParametersInURI = NSSet(array: ["GET", "HEAD"]) as! Set<String>
        
        sessionManager.DELETE("community.leave", parameters:params, success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
            print(responseObject)
            success(response: nil)
            })
        { (task:NSURLSessionDataTask?, error:NSError) in
            print("Error while leaving community: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error: error)
        }
    }
    
    // MARK: Organization methods
    
    func getOnePageOrganizationsFromServer(sourceURL:String, operationQueue:NSOperationQueue, success: (response: AnyObject!, currentPage:Int) -> Void, failure: (error: NSError?) -> Void) {
        
        let manager = AFHTTPRequestOperationManager()
        manager.operationQueue = operationQueue
        
        manager.GET(sourceURL, parameters: nil, success: { (operation, responce) in
            if let response:Dictionary<String, AnyObject> = responce as? Dictionary {
                //print(response)
                if let results = response["response"] {
                    if let communitiesArray = results["items"] as? [AnyObject] {
                        let currentPage = results["current_page_number"] as! Int
                        success(response: communitiesArray, currentPage: currentPage)
                    } else {
                        print("Response of organizations page has 0 items")
                    }
                }
            }
        }) { (operation, error) in
            print("Error loading one page organizations with url \(sourceURL): " + error.localizedDescription)
        }
    }
    
    func createOrganization(organizationName:String, success: (response: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        
        let params:NSDictionary = ["name": organizationName]
        print(params)
        
        if let token = NSUserDefaults.standardUserDefaults().valueForKey(Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.POST("organization.create", parameters:params, success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
            print(responseObject)
            success(response: nil)
            })
        { (task:NSURLSessionDataTask?, error:NSError) in
            print("Error while creating organization: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error: error)
        }
    
    }
    
    // MARK: Feed methods
    
    func getFeeds(currentPage: Int, success: (response: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        
        let params:NSDictionary = ["page": currentPage]
        
        if let token = NSUserDefaults.standardUserDefaults().valueForKey(Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.GET("feed.get", parameters:params, success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
            //print(responseObject)
            if let response = responseObject as? [String:AnyObject] {
                if let results = response["response"] as? [String:AnyObject] {
                    if let postsArray = results["items"] as? [AnyObject] {
                        success(response: postsArray)
                    }
                }
            } else {
                print("Response with feeds is empty")
                success(response: [])
            }
            })
        { (task:NSURLSessionDataTask?, error:NSError) in
            print("Error receiving feeds: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error: error)
        }
    }
    
    // MARK: Profile methods
    
    func postAuthorization(userInfo:NSDictionary, success: (response: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        
        let params:NSDictionary = ["_username": userInfo["username"]!,
                                   "_password": userInfo["password"]!]
        print(params)
        
        sessionManager.POST("login_check", parameters:params, success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
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
        
        sessionManager.POST("registration", parameters:params, success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
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
    
    func getUserProfile(otherUserProfileID profileID: Int?, success: (response: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        
        var params = [String:Int]()
        if profileID == nil {
            if let userID = NSUserDefaults.standardUserDefaults().valueForKey(Constants.kUserID) {
                params["profile_id"] = userID as? Int
            }
        } else {
            params["profile_id"] = profileID
        }
        
        if let token = NSUserDefaults.standardUserDefaults().valueForKey(Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.GET("profile.get", parameters:params, success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
            print(responseObject)
            if let response = responseObject as? [String:AnyObject] {
                if let results = response["response"] as? [String:AnyObject] {
                    success(response: results)
                    
//                    response =     {
//                        about = "<null>";
//                        "avatar_album_id" = 5;
//                        birthday = "<null>";
//                        certificates =         (
//                        );
//                        city = "<null>";
//                        country = "<null>";
//                        "default_album_id" = 6;
//                        description = "<null>";
//                        email = "qwerty@mail.ru";
//                        firstname = "<null>";
//                        id = 3;
//                        lastname = "<null>";
//                        skills =         (
//                        );
//                        "speaker_id" = "<null>";
//                        "thread_id" = 5;
//                        username = qwerty;
//                    };
                    
                }
            } else {
                print("Response profile info is empty")
            }
            })
        { (task:NSURLSessionDataTask?, error:NSError) in
            print("Error receiving profile info: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
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
        
        sessionManager.POST("wall.post", parameters:params, success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
            print(responseObject)
            success(response: nil)
            })
        { (task:NSURLSessionDataTask?, error:NSError) in
            print("Error while adding new post on wall: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error: error)
        }
        
        
    }
    
    func getWallPosts(threadID: Int, currentPage: Int, success: (response: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        
        let params:NSDictionary = ["thread_id": threadID,
                                   "page": currentPage]
        
        if let token = NSUserDefaults.standardUserDefaults().valueForKey(Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.GET("wall.get", parameters:params, success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
            //print(responseObject)
            if let response = responseObject as? [String:AnyObject] {
                if let results = response["response"] as? [String:AnyObject] {
                    if let postsArray = results["items"] as? [AnyObject] {
                        success(response: postsArray)
                    }
                }
            } else {
                print("Response with posts is empty")
                success(response: [])
            }
        })
        { (task:NSURLSessionDataTask?, error:NSError) in
            print("Error receiving wall posts: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error: error)
        }
    }
    
    func getOneWallPost(postID: Int, success: (response: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        
        let params:NSDictionary = ["post_id": postID]
        
        if let token = NSUserDefaults.standardUserDefaults().valueForKey(Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.GET("wall.getPost", parameters:params, success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
            //print(responseObject)
            if let response = responseObject as? [String:AnyObject] {
                if let results = response["response"] as? [String:AnyObject] {
                    success(response: results)
                }
            } else {
                print("Response with one post is empty")
            }
            })
        { (task:NSURLSessionDataTask?, error:NSError) in
            print("Error receiving one wall post: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error: error)
        }
    }
    
    func getPostComments(postID: Int, success: (response: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        
        let params:NSDictionary = ["post_id": postID]
        
        if let token = NSUserDefaults.standardUserDefaults().valueForKey(Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.GET("wall.getPost", parameters:params, success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
            print(responseObject)
            if let response = responseObject as? [String:AnyObject] {
                if let results = response["response"] as? [String:AnyObject] {
                    success(response: results)
                }
            } else {
                print("Response with current post is empty")
            }
        })
        { (task:NSURLSessionDataTask?, error:NSError) in
            print("Error receiving current post from event: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error: error)
        }
    }

    func postComment(postID: Int, commentText: String, success: (response: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        
        let params:NSDictionary = ["post_id": postID,
                                      "body": commentText]
        print(params)
        
        sessionManager.responseSerializer = AFHTTPResponseSerializer()
        sessionManager.requestSerializer = AFJSONRequestSerializer()
        
        sessionManager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = NSUserDefaults.standardUserDefaults().valueForKey(Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.POST("wall.addComment", parameters:params, success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
            //print(responseObject)
            success(response: responseObject)
        })
        { (task:NSURLSessionDataTask?, error:NSError) in
            print("Error sending comment to post: " + error.localizedDescription)
            print(task?.response)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error: error)
        }
    }
    
    // Editing
    
    func editWallPost(postID:Int, postTitle:String, postBody:String, success: (response: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        
        let params:NSDictionary = ["post_id": postID,
                                     "title": postTitle,
                                      "body": postBody]
        
        if let token = NSUserDefaults.standardUserDefaults().valueForKey(Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.PUT("wall.edit", parameters:params, success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
            print(responseObject)
            if let response = responseObject as? [String:AnyObject] {
                success(response: response)
            } else {
                print("Editing wall post return empty message")
            }
            success(response: nil)
            })
        { (task:NSURLSessionDataTask?, error:NSError) in
            print("Error while editing wall post: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error: error)
        }
    }
    
    func editWallComment(commentID:Int, commentBody:String, success: (response: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        
        let params:NSDictionary = ["comment_id": commentID,
                                         "body": commentBody]
        
        if let token = NSUserDefaults.standardUserDefaults().valueForKey(Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.PUT("wall.editComment", parameters:params, success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
            print(responseObject)
            if let response = responseObject as? [String:AnyObject] {
                success(response: response)
            } else {
                print("Editing wall comment return empty message")
            }
            success(response: nil)
            })
        { (task:NSURLSessionDataTask?, error:NSError) in
            print("Error while editing wall comment: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error: error)
        }
    }
    
    // Deleting
    
    func deleteWallPost(postID:Int, success: (response: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        
        let params:NSDictionary = ["post_id": postID]
        print(params)
        
        sessionManager.requestSerializer.HTTPMethodsEncodingParametersInURI = NSSet(array: ["GET", "HEAD"]) as! Set<String>
        
        if let token = NSUserDefaults.standardUserDefaults().valueForKey(Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.DELETE("wall.delete", parameters:params, success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
            print(responseObject)
            if let response = responseObject as? [String:AnyObject] {
                if let results = response["response"] {
                    print(results)
                    success(response: nil)
                }
            } else {
                print("Delete wall post return empty message")
            }
            })
        { (task:NSURLSessionDataTask?, error:NSError) in
            print("Error while deleting wall post: " + error.localizedDescription)
            
            // Example of parsing error for backend
            
            do {
                let responseDict = try NSJSONSerialization.JSONObjectWithData((error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] as! NSData), options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                print(responseDict)
            } catch {
                print("Error parsing error")
            }
            
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error: error)
        }
    }
    
    func deleteWallComment(commentID:Int, success: (response: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        
        let params:NSDictionary = ["comment_id": commentID]
        print(params)
        
        sessionManager.requestSerializer.HTTPMethodsEncodingParametersInURI = NSSet(array: ["GET", "HEAD"]) as! Set<String>
        
        if let token = NSUserDefaults.standardUserDefaults().valueForKey(Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.DELETE("wall.deleteComment", parameters:params, success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
            print(responseObject)
            if let response = responseObject as? [String:AnyObject] {
                if let results = response["response"] {
                    print(results)
                    success(response: nil)
                }
            } else {
                print("Delete wall comment return empty message")
            }
            })
        { (task:NSURLSessionDataTask?, error:NSError) in
            print("Error while deleting wall comment: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error: error)
        }
    }
    
    // MARK: Photos
    
    func getUserPhotoAlbums(otherUserID userID: Int?, success: (response: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        
        var params = [String:Int]()
        if userID == nil {
            if let userID = NSUserDefaults.standardUserDefaults().valueForKey(Constants.kUserID) {
                params["user_id"] = userID as? Int
            }
        } else {
            params["user_id"] = userID
        }
        
        if let token = NSUserDefaults.standardUserDefaults().valueForKey(Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.GET("photos.getAlbums", parameters:params, success: { (task: NSURLSessionDataTask, responseObject: AnyObject?) in
            print(responseObject)
            if let response = responseObject as? [String:AnyObject] {
                if let results = response["response"] as? [String:AnyObject] {
                    success(response: results)
                    
//                    response =     {
//                        "album_name" = "name";
//                        cover = "<null>";
//                        "created_at" = "2016-08-12T12:43:32+0000";
//                        id = 14;
//                        images =         (
//                        );
//                        owner =         {
//                        }
//                    }
                }
            } else {
                print("Response profile info is empty")
            }
            })
        { (task:NSURLSessionDataTask?, error:NSError) in
            print("Error receiving profile info: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error: error)
        }
    }
    

}


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
        let serverURL = URL(string: Constants.linkToServerAPI)
        sessionManager = AFHTTPSessionManager(baseURL: serverURL)
    }
    
    func loadData(_ typeOfDownload:String) {
        
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
    
    // MARK: Events methods
    
    func getAllEventsFromServer() {
        
        sessionManager.get("event.getAll", parameters:nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
            if let response:Dictionary<String, AnyObject> = responseObject as? Dictionary {
                if let results = response["response"] {
                    print(results)
                    DataBaseManager().writeAllCommunities(results as! [AnyObject], isLastPage:true)
                } else {
                    print("Reques all events from server is nil")
                }
            }
        })
        { (task:URLSessionDataTask?, error:Error) in
            print("Error loading all events: " + error.localizedDescription)
        }
        
    }
    
    func getOnePageEventsFromServer(_ sourceURL:String, operationQueue:OperationQueue, success: @escaping (_ response: AnyObject?, _ currentPage:Int) -> Void, failure: (_ error: Error?) -> Void) {
        
        let manager = AFHTTPRequestOperationManager()
        //manager.requestSerializer.setValue("application/json; charset=UTF-8", forHTTPHeaderField:"Content-Type")
        manager.operationQueue = operationQueue
        //manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        
        manager.get(sourceURL, parameters: nil, success: { (operation, responce) in
            if let response:Dictionary<String, AnyObject> = responce as? Dictionary {
                //print(response)
                if let results = response["response"] {
                    if let communitiesArray = results["items"] as? [AnyObject] {
                        let currentPage = results["current_page_number"] as! Int
                        success(communitiesArray as AnyObject?, currentPage)
                    } else {
                        print("Response of events page has 0 items")
                    }
                }
            }
        }) { (operation, error) in
            print("Error loading one page events with url \(sourceURL): " + error.localizedDescription)
        }
    }
    
    func getEvent(_ eventID: Int, success: @escaping (_ response: [String:AnyObject]?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        let params:NSDictionary = ["id": eventID]
        
        if let token = UserDefaults.standard.value(forKey: Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.get("event.get", parameters:params, success: { (task: URLSessionDataTask, responseObject: Any?) in
            //print(responseObject)
            if let response = responseObject as? [String:AnyObject] {
                if let results = response["response"] as? [String:AnyObject] {
                    success(results)
                }
            } else {
                print("Response with event is empty")
            }
            })
        { (task:URLSessionDataTask?, error:Error) in
            print("Error receiving event: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error)
        }
    }
    
    func joinEvent(_ eventID:Int, notSure:Int, success: @escaping (_ response: AnyObject?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        let params:NSDictionary = ["id": eventID,
                             "not_sure": notSure]
        
        if let token = UserDefaults.standard.value(forKey: Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.post("event.join", parameters:params, success: { (task: URLSessionDataTask, responseObject: Any?) in
            print(responseObject)
            success(nil)
        })
        { (task:URLSessionDataTask?, error:Error) in
            print("Error while joining event: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error)
        }
    }
    
    func leaveEvent(_ eventID:Int, success: @escaping (_ response: AnyObject?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        let params:NSDictionary = ["id": eventID]
        
        if let token = UserDefaults.standard.value(forKey: Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.requestSerializer.httpMethodsEncodingParametersInURI = NSSet(array: ["GET", "HEAD"]) as! Set<String>
        
        sessionManager.delete("event.leave", parameters:params, success: { (task: URLSessionDataTask, responseObject: Any?) in
            print(responseObject)
            success(nil)
            })
        { (task:URLSessionDataTask?, error:Error) in
            print("Error while leaving event: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error as Error?)
        }
    }
    
    func editEvent(_ eventInfo:[String:AnyObject], success: @escaping (_ response: AnyObject?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        // Pay attention not to pass empty keys in eventInfo dictionary! Put there empty strings or arrays when calling this methood
        
        let params:NSDictionary = ["id": eventInfo["id"]!,
                                 "name": eventInfo["name"]!,
                     "event_start_date": eventInfo["eventStartDate"]!,
                       "event_end_date": eventInfo["eventEndDate"]!,
                           "event_site": eventInfo["eventSite"]!,
                          "event_price": eventInfo["eventPrice"]!,
                          "description": eventInfo["description"]!,
                            "locations": eventInfo["locations"]!]      // array
        
        if let token = UserDefaults.standard.value(forKey: Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.put("event.update", parameters:params, success: { (task: URLSessionDataTask, responseObject: Any?) in
            print(responseObject)
            if let response:Dictionary<String, AnyObject> = responseObject as? Dictionary {
                if let results = response["response"] {
                    success(results)
                }
            } else {
                print("Editing event response is empty")
            }
            })
        { (task:URLSessionDataTask?, error:Error) in
            print("Error while editing event info: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error as Error?)
        }
    }
    
    // MARK: Organization methods
    
    func getOnePageOrganizationsFromServer(_ sourceURL:String, currentPage:Int, operationQueue:OperationQueue, success: @escaping (_ response: AnyObject?, _ currentPage:Int) -> Void, failure: (_ error: Error?) -> Void) {
        
        let manager = AFHTTPRequestOperationManager()
        manager.operationQueue = operationQueue
        
        let params:NSDictionary = ["page": currentPage]
        
        manager.get(sourceURL, parameters: params, success: { (operation, responce) in
            if let response:Dictionary<String, AnyObject> = responce as? Dictionary {
                //print(response)
                if let results = response["response"] {
                    if let communitiesArray = results["items"] as? [AnyObject] {
                        let currentPage = results["current_page_number"] as! Int
                        success(communitiesArray as AnyObject?, currentPage)
                    } else {
                        print("Response of organizations page has 0 items")
                    }
                }
            }
        }) { (operation, error) in
            print("Error loading one page organizations with url \(sourceURL): " + error.localizedDescription)
        }
    }
    
    func createOrganization(_ organizationName:String, success: @escaping (_ response: AnyObject?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        let params:NSDictionary = ["name": organizationName]
        print(params)
        
        if let token = UserDefaults.standard.value(forKey: Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.post("organization.create", parameters:params, success: { (task: URLSessionDataTask, responseObject: Any?) in
            print(responseObject)
            success(nil)
            })
        { (task:URLSessionDataTask?, error:Error) in
            print("Error while creating organization: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error)
        }
    
    }
    
    func joinOrganization(_ organizationID:Int, success: @escaping (_ response: AnyObject?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        let params:NSDictionary = ["id": organizationID]
        
        if let token = UserDefaults.standard.value(forKey: Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.post("organization.join", parameters:params, success: { (task: URLSessionDataTask, responseObject: Any?) in
            print(responseObject)
            success(nil)
            })
        { (task:URLSessionDataTask?, error:Error) in
            print("Error while joining organization: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error)
        }
    }
    
    func leaveOrganization(_ organizationID:Int, success: @escaping (_ response: AnyObject?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        let params:NSDictionary = ["id": organizationID]
        
        sessionManager.requestSerializer.httpMethodsEncodingParametersInURI = NSSet(array: ["GET", "HEAD"]) as! Set<String>
        
        if let token = UserDefaults.standard.value(forKey: Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.delete("organization.leave", parameters:params, success: { (task: URLSessionDataTask, responseObject: Any?) in
            print(responseObject)
            success(nil)
            })
        { (task:URLSessionDataTask?, error:Error) in
            print("Error while leaving organization: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error)
        }
    }
    
    // MARK: Feed methods
    
    func getFeeds(_ currentPage: Int, success: @escaping (_ response: [AnyObject]?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        let params:NSDictionary = ["page": currentPage]
        
        if let token = UserDefaults.standard.value(forKey: Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.get("feed.get", parameters:params, success: { (task: URLSessionDataTask, responseObject: Any?) in
            //print(responseObject)
            if let response = responseObject as? [String:AnyObject] {
                if let results = response["response"] as? [String:AnyObject] {
                    if let postsArray = results["items"] as? [AnyObject] {
                        success(postsArray)
                    }
                }
            } else {
                print("Response with feeds is empty")
                success([])
            }
            })
        { (task:URLSessionDataTask?, error:Error) in
            print("Error receiving feeds: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error)
        }
    }
    
    // MARK: Profile methods
    
    func postAuthorization(_ userInfo:NSDictionary, success: @escaping (_ response: AnyObject?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        let params:NSDictionary = ["_username": userInfo["username"]!,
                                   "_password": userInfo["password"]!]
        print(params)
        
        sessionManager.post("login_check", parameters:params, success: { (task: URLSessionDataTask, responseObject: Any?) in
            print(responseObject)
            if let response:Dictionary<String, AnyObject> = responseObject as? Dictionary {
                if let results = response["response"] {
                    
                    let token = results["token"] as? String
                    let receivedUserInfo = results["user"] as? [String:AnyObject]
                    if receivedUserInfo != nil {
                        if let userID = receivedUserInfo!["id"] {
                            UserDefaults.standard.setValue(userID, forKey: Constants.kUserID)
                        }
                    }
                    if token != nil {
                        UserDefaults.standard.setValue(token, forKey: Constants.kUserToken)
                    }
                    success(nil)
                }
            } else {
                print("Post authorization didn't return dictionary responce")
            }
            })
        { (task:URLSessionDataTask?, error:Error) in
            print("Error while authorization: " + error.localizedDescription)
            failure(error)
        }
        
    }
    
    func postRegistration(_ userInfo:NSDictionary, success: @escaping (_ response: AnyObject?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        let params:NSDictionary = ["email": userInfo["email"]!,
                                   "username": userInfo["username"]!,
                                   "password": userInfo["password"]!]
        
        sessionManager.post("registration", parameters:params, success: { (task: URLSessionDataTask, responseObject: Any?) in
            print(responseObject)
            if let response:Dictionary<String, AnyObject> = responseObject as? Dictionary {
                if let results = response["response"] {
                    
                    let token = results["token"] as? String
                    let receivedUserInfo = results["user"] as? [String:AnyObject]
                    if receivedUserInfo != nil {
                        if let userID = receivedUserInfo!["id"] {
                            UserDefaults.standard.setValue(userID, forKey: Constants.kUserID)
                        }
                    }
                    if token != nil {
                        UserDefaults.standard.setValue(token, forKey: Constants.kUserToken)
                    }
                    success(nil)
                }
            } else {
                print("Post registration didn't return dictionary responce")
            }
            })
        { (task:URLSessionDataTask?, error:Error) in
            print("Error while sending registration info: " + error.localizedDescription)
            failure(error)
        }
        
    }
    
    func getUserProfile(otherUserProfileID profileID: Int?, success: @escaping (_ response: AnyObject?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        var params = [String:Int]()
        if profileID == nil {
            if let userID = UserDefaults.standard.value(forKey: Constants.kUserID) {
                params["profile_id"] = userID as? Int
            }
        } else {
            params["profile_id"] = profileID
        }
        
        if let token = UserDefaults.standard.value(forKey: Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.get("profile.get", parameters:params, success: { (task: URLSessionDataTask, responseObject: Any?) in
            print(responseObject)
            if let response = responseObject as? [String:AnyObject] {
                if let results = response["response"] as? [String:AnyObject] {
                    success(results as AnyObject?)
                    
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
        { (task:URLSessionDataTask?, error:Error) in
            print("Error receiving profile info: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error)
        }
    }
    
    func editUserProfile(_ userInfo:[String:AnyObject], success: @escaping (_ response: AnyObject?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        // Pay attention not to pass empty keys in userInfo dictionary! Put there empty strings or arrays when calling this methood
        
        let params:NSDictionary = ["birthday": userInfo["birthday"]!,
                                      "about": userInfo["about"]!,
                                  "firstname": userInfo["firstname"]!,
                                   "lastname": userInfo["lastname"]!,
                                    "country": userInfo["country"]!,       // array
                                       "city": userInfo["city"]!,          // array
                                "description": userInfo["description"]!,
                                     "skills": userInfo["skills"]!,        // array
                               "sertificates": userInfo["sertificates"]!]  // array
        
        if let token = UserDefaults.standard.value(forKey: Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.put("profile.edit", parameters:params, success: { (task: URLSessionDataTask, responseObject: Any?) in
            print(responseObject)
            if let response:Dictionary<String, AnyObject> = responseObject as? Dictionary {
                if let results = response["response"] {
                    success(results)
                }
            } else {
                print("Editing profile response is empty")
            }
            })
        { (task:URLSessionDataTask?, error:Error) in
            print("Error while editing profile info: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error)
        }
    }
    
    // MARK: Wall methods
    
    func postNewMessageOnWall(_ threadIDDict:[String:Int], title:String, body:String, success: @escaping (_ response: AnyObject?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        let params:NSDictionary = ["thread": threadIDDict,
                                   "title": title,
                                   "body": body]
        print(params)
        
        if let token = UserDefaults.standard.value(forKey: Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.post("wall.post", parameters:params, success: { (task: URLSessionDataTask, responseObject: Any?) in
            print(responseObject)
            success(nil)
            })
        { (task:URLSessionDataTask?, error:Error) in
            print("Error while adding new post on wall: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error)
        }
        
        
    }
    
    func getWallPosts(_ threadID: Int, currentPage: Int, success: @escaping (_ response: [AnyObject]?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        let params:NSDictionary = ["thread_id": threadID,
                                   "page": currentPage]
        
        if let token = UserDefaults.standard.value(forKey: Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.get("wall.get", parameters:params, success: { (task: URLSessionDataTask, responseObject: Any?) in
            //print(responseObject)
            if let response = responseObject as? [String:AnyObject] {
                if let results = response["response"] as? [String:AnyObject] {
                    if let postsArray = results["items"] as? [AnyObject] {
                        success(postsArray)
                    }
                }
            } else {
                print("Response with posts is empty")
                success([])
            }
        })
        { (task:URLSessionDataTask?, error:Error) in
            print("Error receiving wall posts: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error)
        }
    }
    
    func getOneWallPost(_ postID: Int, success: @escaping (_ response: AnyObject?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        let params:NSDictionary = ["post_id": postID]
        
        if let token = UserDefaults.standard.value(forKey: Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.get("wall.getPost", parameters:params, success: { (task: URLSessionDataTask, responseObject: Any?) in
            //print(responseObject)
            if let response = responseObject as? [String:AnyObject] {
                if let results = response["response"] as? [String:AnyObject] {
                    success(results as AnyObject?)
                }
            } else {
                print("Response with one post is empty")
            }
            })
        { (task:URLSessionDataTask?, error:Error) in
            print("Error receiving one wall post: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error)
        }
    }
    
    func getPostComments(_ postID: Int, success: @escaping (_ response: AnyObject?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        let params:NSDictionary = ["post_id": postID]
        
        if let token = UserDefaults.standard.value(forKey: Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.get("wall.getPost", parameters:params, success: { (task: URLSessionDataTask, responseObject: Any?) in
            print(responseObject)
            if let response = responseObject as? [String:AnyObject] {
                if let results = response["response"] as? [String:AnyObject] {
                    success(results as AnyObject?)
                }
            } else {
                print("Response with current post is empty")
            }
        })
        { (task:URLSessionDataTask?, error:Error) in
            print("Error receiving current post from event: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error)
        }
    }

    func postComment(_ postID: Int, commentText: String, success: @escaping (_ response: AnyObject?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        let params:NSDictionary = ["post_id": postID,
                                      "body": commentText]
        print(params)
        
        sessionManager.responseSerializer = AFHTTPResponseSerializer()
        sessionManager.requestSerializer = AFJSONRequestSerializer()
        
        sessionManager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.value(forKey: Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.post("wall.addComment", parameters:params, success: { (task: URLSessionDataTask, responseObject: Any?) in
            //print(responseObject)
            success(responseObject as AnyObject?)
        })
        { (task:URLSessionDataTask?, error:Error) in
            print("Error sending comment to post: " + error.localizedDescription)
            print(task?.response)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error)
        }
    }
    
    // Editing
    
    func editWallPost(_ postID:Int, postTitle:String, postBody:String, success: @escaping (_ response: AnyObject?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        let params:NSDictionary = ["post_id": postID,
                                     "title": postTitle,
                                      "body": postBody]
        
        if let token = UserDefaults.standard.value(forKey: Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.put("wall.edit", parameters:params, success: { (task: URLSessionDataTask, responseObject: Any?) in
            print(responseObject)
            if let response = responseObject as? [String:AnyObject] {
                success(response as AnyObject?)
            } else {
                print("Editing wall post return empty message")
            }
            success(nil)
            })
        { (task:URLSessionDataTask?, error:Error) in
            print("Error while editing wall post: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error)
        }
    }
    
    func editWallComment(_ commentID:Int, commentBody:String, success: @escaping (_ response: AnyObject?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        let params:NSDictionary = ["comment_id": commentID,
                                         "body": commentBody]
        
        if let token = UserDefaults.standard.value(forKey: Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.put("wall.editComment", parameters:params, success: { (task: URLSessionDataTask, responseObject: Any?) in
            print(responseObject)
            if let response = responseObject as? [String:AnyObject] {
                success(response as AnyObject?)
            } else {
                print("Editing wall comment return empty message")
            }
            success(nil)
            })
        { (task:URLSessionDataTask?, error:Error) in
            print("Error while editing wall comment: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error)
        }
    }
    
    // Deleting
    
    func deleteWallPost(_ postID:Int, success: @escaping (_ response: AnyObject?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        let params:NSDictionary = ["post_id": postID]
        print(params)
        
        sessionManager.requestSerializer.httpMethodsEncodingParametersInURI = NSSet(array: ["GET", "HEAD"]) as! Set<String>
        
        if let token = UserDefaults.standard.value(forKey: Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.delete("wall.delete", parameters:params, success: { (task: URLSessionDataTask, responseObject: Any?) in
            print(responseObject)
            if let response = responseObject as? [String:AnyObject] {
                if let results = response["response"] {
                    print(results)
                    success(nil)
                }
            } else {
                print("Delete wall post return empty message")
            }
            })
        { (task:URLSessionDataTask?, error:Error) in
            print("Error while deleting wall post: " + error.localizedDescription)
            
            // Example of parsing error for backend
            
            do {
                let responseDict = try JSONSerialization.jsonObject(with: ((error as NSError).userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] as! Data), options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                print(responseDict)
            } catch {
                print("Error parsing error")
            }
            
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error)
        }
    }
    
    func deleteWallComment(_ commentID:Int, success: @escaping (_ response: AnyObject?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        let params:NSDictionary = ["comment_id": commentID]
        print(params)
        
        sessionManager.requestSerializer.httpMethodsEncodingParametersInURI = NSSet(array: ["GET", "HEAD"]) as! Set<String>
        
        if let token = UserDefaults.standard.value(forKey: Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.delete("wall.deleteComment", parameters:params, success: { (task: URLSessionDataTask, responseObject: Any?) in
            print(responseObject)
            if let response = responseObject as? [String:AnyObject] {
                if let results = response["response"] {
                    print(results)
                    success(nil)
                }
            } else {
                print("Delete wall comment return empty message")
            }
            })
        { (task:URLSessionDataTask?, error:Error) in
            print("Error while deleting wall comment: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error)
        }
    }
    
    // MARK: News methods
    
    func getNews(_ currentPage: Int, success: @escaping (_ response: [AnyObject]?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        let params:NSDictionary = ["page": currentPage]
        
        if let token = UserDefaults.standard.value(forKey: Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.get("news", parameters:params, success: { (task: URLSessionDataTask, responseObject: Any?) in
            print(responseObject)
            if let response = responseObject as? [String:AnyObject] {
                if let results = response["response"] as? [String:AnyObject] {
                    if let newsArray = results["items"] as? [AnyObject] {
                        success(newsArray)
                    }
                }
            } else {
                print("Response with news is empty")
                success([])
            }
            })
        { (task:URLSessionDataTask?, error:Error) in
            print("Error receiving news: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error)
        }
    }
    
    func postNews(_ newsBody:[String:String], type:String, organizationID:Int?, success: @escaping (_ response: AnyObject?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        // NewsForm should be with such keys:
        //    "news_form" : {
        //    "title": "123qqq",
        //    "content": "qwe"
        //    }
        
        let params:NSMutableDictionary = ["news_form": newsBody,
                                               "type": type]      // user|org
        if organizationID != nil {
            params.setObject(organizationID!, forKey: "org_id" as NSCopying)
        }
        
        print(params)
        
        if let token = UserDefaults.standard.value(forKey: Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.post("news", parameters:params, success: { (task: URLSessionDataTask, responseObject: Any?) in
            print(responseObject)
            success(nil)
            })
        { (task:URLSessionDataTask?, error:Error) in
            print("Error while adding news: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error)
        }
        
    }
    
    // MARK: Photos methods
    
    func getUserPhotoAlbums(otherUserID userID: Int?, success: @escaping (_ response: AnyObject?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        var params = [String:Int]()
        if userID == nil {
            if let userID = UserDefaults.standard.value(forKey: Constants.kUserID) {
                params["user_id"] = userID as? Int
            }
        } else {
            params["user_id"] = userID
        }
        
        if let token = UserDefaults.standard.value(forKey: Constants.kUserToken) {
            sessionManager.requestSerializer.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        sessionManager.get("photos.getAlbums", parameters:params, success: { (task: URLSessionDataTask, responseObject: Any?) in
            print(responseObject)
            if let response = responseObject as? [String:AnyObject] {
                if let results = response["response"] as? [String:AnyObject] {
                    success(results as AnyObject?)
                    
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
        { (task:URLSessionDataTask?, error:Error) in
            print("Error receiving profile info: " + error.localizedDescription)
            self.sessionManager.requestSerializer.clearAuthorizationHeader()
            failure(error)
        }
    }
    

}


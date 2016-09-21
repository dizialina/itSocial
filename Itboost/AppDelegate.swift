//
//  AppDelegate.swift
//  Itboost
//
//  Created by Admin on 19.07.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Fabric
import Crashlytics
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Change status bar color
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 20.0))
        view.backgroundColor = Constants.navigationBarBlue
        self.window?.rootViewController?.view.addSubview(view)
        
        // Set text color for all alerts buttons in application
        window?.tintColor = Constants.darkMintBlue
        
        // Value for checking user's authorization when app launched
        UserDefaults.standard.set(true, forKey:Constants.kAlreadyRun)
        
        // Enable keyboard manager
        IQKeyboardManager.sharedManager().enable = true
        
        // Load all events for initial event screen
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
           LoadPaginaionManager().loadAllEventsFromServer()
        })
        
        // Fabric + Chrashlytics
        //Fabric.sharedSDK().debug = true
        Fabric.with([Crashlytics.self])
        
        // Google services
        GMSServices.provideAPIKey(Constants.APIKey)
        
        //Updating user's token
        if UserDefaults.standard.value(forKey: Constants.kUserLogin) != nil {
            let login = UserDefaults.standard.value(forKey: Constants.kUserLogin)
            let password = UserDefaults.standard.value(forKey: Constants.kUserPassword)
            let userInfo:NSDictionary = ["username": login!, "password": password!]
            
            ServerManager().postAuthorization(userInfo, success: { (response) -> Void in
                print("Success relogin")
            }) { (error) -> Void in
                print("Error while reauthorization: " + error!.localizedDescription)
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    // MARK: Custom methods
    
}

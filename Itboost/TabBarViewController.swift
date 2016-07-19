//
//  TabBarViewController.swift
//  Itboost
//
//  Created by Admin on 19.07.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit

class TabBarViewController: UITabBarController {
    
    @IBInspectable var defaulSelectedTab:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = defaulSelectedTab
        
//        UITabBar.appearance().tintColor = Constants.activeTabColor
//        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.whiteColor()], forState: UIControlState.Normal)
//        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:Constants.activeTabColor], forState: UIControlState.Selected)
//        
//        let itemsArray = tabBar.items
//        if itemsArray?.count > 0 {
//            itemsArray![0].image = UIImage(named:"SHProfileTabNonactive")!.imageWithRenderingMode(.AlwaysOriginal)
//            itemsArray![1].image = UIImage(named:"SHMapTabNonactive")!.imageWithRenderingMode(.AlwaysOriginal)
//            itemsArray![2].image = UIImage(named:"SHMessageTabNonactive")!.imageWithRenderingMode(.AlwaysOriginal)
//            itemsArray![3].image = UIImage(named:"SHAcceptedTabNonactive")!.imageWithRenderingMode(.AlwaysOriginal)
//            itemsArray![4].image = UIImage(named:"SHNewTabNonactive")!.imageWithRenderingMode(.AlwaysOriginal)
//        }
        
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        
        let itemsArray = tabBar.items
        if item == itemsArray![0] {
            
        }
        
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        
    }
    
    
    
}

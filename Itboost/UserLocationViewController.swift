//
//  UserLocationViewController.swift
//  Itboost
//
//  Created by Alina Yehorova on 27.09.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit

class UserLocationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var filterType:FilterType?
    var countryID:Int?
    var selectionList = [FilterObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.startAnimating()
        getSelectionList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeFilters(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Receive data from server
    
    func getSelectionList() {
        
        switch filterType! {
        case .country:
            
            ServerManager().getCountries(success: { (response) in
                
                for item in response! {
                    if item is [String:AnyObject] {
                        let itemID = item["id"] as! Int
                        let itemName = item["country_name"] as! String
                        let filterObject = FilterObject(filterObjectID: itemID, filterObjectName: itemName)
                        self.selectionList.append(filterObject)
                    }
                }
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
                
                }, failure: { (error) in
                    print("Error receiving countries list: " + error!.localizedDescription)
            })
            
        case .city:
            
            ServerManager().getCities(countryID, success: { (response) in
                
                for item in response! {
                    if item is [String:AnyObject] {
                        let itemID = item["id"] as! Int
                        let itemName = item["city_name"] as! String
                        let filterObject = FilterObject(filterObjectID: itemID, filterObjectName: itemName)
                        self.selectionList.append(filterObject)
                    }
                }
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
                
                }, failure: { (error) in
                    print("Error receiving cities list: " + error!.localizedDescription)
            })
        }
    }
    
    // MARK: TableView DataSource and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let filterCell = tableView.dequeueReusableCell(withIdentifier: "UserLocationCell", for: indexPath)
        filterCell.textLabel?.text = selectionList[indexPath.row].filterObjectName
        return filterCell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let previousViewController = self.navigationController?.viewControllers[1] as! EditProfileViewController
        
        switch filterType! {
        case .country:
            previousViewController.selectedUserLocation["country"] = selectionList[indexPath.row]
            previousViewController.selectedUserLocation["city"] = nil
        case .city:
            previousViewController.selectedUserLocation["city"] = selectionList[indexPath.row]
        }
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
}


//
//  FilterViewController.swift
//  Itboost
//
//  Created by Alina Yehorova on 26.09.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit

enum FilterType: Int {
    case country = 0
    case city
}

struct FilterObject {
    var filterObjectID = 0
    var filterObjectName = ""
}

class FilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let filterCategories = ["Страна", "Город"]
    var selectedFilters = [String:FilterObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    // MARK: Actions
    
    @IBAction func acceptFilters(_ sender: AnyObject) {
        
        let eventViewController = (presentingViewController as! UINavigationController).viewControllers.first as! EventTableViewController
        eventViewController.selectedFilters = selectedFilters
        self.dismiss(animated: true, completion: nil)
        eventViewController.getCommunitiesFromDatabase()
        
    }
    
    @IBAction func closeFilters(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: TableView DataSource and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let filterCell = tableView.dequeueReusableCell(withIdentifier: "EventFilterCell", for: indexPath)
        
        filterCell.textLabel?.text = filterCategories[indexPath.row]
        
        if indexPath.row == 0 {
            if let selectedCountry = selectedFilters["country"] {
                filterCell.detailTextLabel?.text = selectedCountry.filterObjectName
            } else {
                filterCell.detailTextLabel?.text = "Не выбрано"
            }
        } else if indexPath.row == 1 {
            if let selectedCity = selectedFilters["city"] {
                filterCell.detailTextLabel?.text = selectedCity.filterObjectName
            } else {
                filterCell.detailTextLabel?.text = "Не выбрано"
            }
        }
        
        return filterCell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "selectFilterObject", sender: nil)
    }
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "selectFilterObject") {
            let viewController = segue.destination as! SelectFilterTypeViewController
            let indexPath = tableView.indexPathForSelectedRow
            viewController.filterType = FilterType(rawValue: indexPath!.row)
            if let countryFilterObject = selectedFilters["country"] {
                viewController.countryID = countryFilterObject.filterObjectID
            }
        }
        
    }
    
}

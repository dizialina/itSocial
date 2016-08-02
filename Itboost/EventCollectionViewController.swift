//
//  EventCollectionViewController.swift
//  Itboost
//
//  Created by Admin on 19.07.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import CoreData

class EventCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, EventCellLayoutDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
    var communityList = [Community]()
    var eventsList = [String]()
    var pictureList = [UIImage]()
    var cellWidth = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventCollectionViewController.getCommunitiesFromDatabase), name: Constants.kLoadCommunitiesNotification, object: nil)
        
        self.navigationItem.title = "События"
        
        if let layout = collectionView?.collectionViewLayout as? EventOneColumnCellLayout {
            layout.delegate = self
        }
        
        pictureList = [UIImage(named:"PhotoExample1")!]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: Loading data for collection view
    
    func getCommunitiesFromDatabase() {
        
        let dataBaseManager = DataBaseManager()
        managedObjectContext = dataBaseManager.managedObjectContext
        communityList.removeAll()
        
        let fetchRequest = NSFetchRequest(entityName: "Community")
        let sortDescriptor = NSSortDescriptor(key: "eventDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let allCommunities = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Community]
            for community in allCommunities {
                communityList.append(community)
            }
            collectionView.reloadData()
            
        } catch {
            print("Collection can't get all communities from database")
        }
        
    }
    
    //MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier:"AudioHeader", forIndexPath: indexPath)
        
        return headerView
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return communityList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let eventCell = collectionView.dequeueReusableCellWithReuseIdentifier("EventCell", forIndexPath: indexPath) as! EventCollectionCell
        
        let community = communityList[indexPath.item]
        
        let eventDate = convertDateToText(community.eventDate!)
        let textToShow = "\(community.name) \nСостоится: \(eventDate) \nОрганизатор: \(community.createdBy.userName)"
        
        let title:NSString = textToShow
        
        let commentHeight = title.heightForText(title, viewWidth: cellWidth, device: nil)
        let height = commentHeight + 4 * 2
        
        eventCell.titleLabel.text = title as String
        eventCell.image.image = pictureList[0]
        eventCell.textViewHeight.constant = height
        
//        defaultCell.deleteButton.addTarget(self, action: "trashAction:", forControlEvents: UIControlEvents.TouchUpInside)
    
        return eventCell
        
    }
    
    //MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
//        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        
    }
   
    //MARK: EventCellLayoutDelegate
    
    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
        
        let photo = pictureList[0]
        let boundingRect =  CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        let rect  = AVMakeRectWithAspectRatioInsideRect(photo.size, boundingRect)
        return rect.size.height
    }
    
    func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
        
        cellWidth = width
        
        let annotationPadding = CGFloat(4)
        
        let community = communityList[indexPath.item]
        
        let eventDate = convertDateToText(community.eventDate!)
        let textToShow = "\(community.name) \nСостоится: \(eventDate) \nОрганизатор: \(community.createdBy.userName)"
        
        let text:NSString = textToShow
        let commentHeight = text.heightForText(text, viewWidth: width, device: nil)
        let height = commentHeight + annotationPadding * 2
        
        return height
    }
    
    //MARK: Helping methods
    
    func convertDateToText(date:NSDate) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter.stringFromDate(date)
    }
}
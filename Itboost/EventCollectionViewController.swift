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
    
    var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    var communityList = [Community]()
    var eventsList = [String]()
    var pictureList = [UIImage]()
    var cellWidth = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(EventCollectionViewController.getCommunitiesFromDatabase), name: NSNotification.Name(rawValue: Constants.kLoadCommunitiesNotification), object: nil)
        
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
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Loading data for collection view
    
    func getCommunitiesFromDatabase() {
        
        let dataBaseManager = DataBaseManager()
        managedObjectContext = dataBaseManager.managedObjectContext
        communityList.removeAll()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Community")
        let sortDescriptor = NSSortDescriptor(key: "eventDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let allCommunities = try managedObjectContext.fetch(fetchRequest) as! [Community]
            for community in allCommunities {
                communityList.append(community)
            }
            collectionView.reloadData()
            
        } catch {
            print("Collection can't get all communities from database")
        }
        
    }
    
    //MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:"AudioHeader", for: indexPath)
        
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return communityList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let eventCell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCell", for: indexPath) as! EventCollectionCell
        
        let community = communityList[(indexPath as NSIndexPath).item]
        
        let eventDate = convertDateToText(community.eventDate! as Date)
        let textToShow = "\(community.name) \nСостоится: \(eventDate) \nОрганизатор: \(community.createdBy?.userName)"
        
        let title:NSString = textToShow as NSString
        
        let font = UIFont.systemFont(ofSize: 15.0)
        let commentHeight = title.heightForText(title, neededFont:font, viewWidth: cellWidth,  offset:5.0, device: nil)
        let height = commentHeight + 4 * 2
        
        eventCell.titleLabel.text = title as String
        eventCell.image.image = pictureList[0]
        eventCell.textViewHeight.constant = height
        
//        defaultCell.deleteButton.addTarget(self, action: "trashAction:", forControlEvents: UIControlEvents.TouchUpInside)
    
        return eventCell
        
    }
    
    //MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
//        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        
    }
   
    //MARK: EventCellLayoutDelegate
    
    func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        
        let photo = pictureList[0]
        let boundingRect =  CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        let rect  = AVMakeRect(aspectRatio: photo.size, insideRect: boundingRect)
        return rect.size.height
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        
        cellWidth = width
        
        let annotationPadding = CGFloat(4)
        
        let community = communityList[(indexPath as NSIndexPath).item]
        
        let eventDate = convertDateToText(community.eventDate! as Date)
        let textToShow = "\(community.name) \nСостоится: \(eventDate) \nОрганизатор: \(community.createdBy?.userName)"
        
        let text:NSString = textToShow as NSString
        let font = UIFont.systemFont(ofSize: 15.0)
        let commentHeight = text.heightForText(text, neededFont:font, viewWidth: width, offset:5.0, device: nil)
        let height = commentHeight + annotationPadding * 2
        
        return height
    }
    
    //MARK: Helping methods
    
    func convertDateToText(_ date:Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter.string(from: date)
    }
}

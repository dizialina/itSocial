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

class EventCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, EventCellLayoutDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var eventsList = [String]()
    var pictureList = [UIImage]()
    var cellWidth = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "События"
        
        if let layout = collectionView?.collectionViewLayout as? EventOneColumnCellLayout {
            layout.delegate = self
        }
        
        eventsList = ["Ukraine Sport Events - инновационная компания, которая оказывает услуги обслуживания и организацию спортивных мероприятий по всей территории Украины. Мы предоставляем высокотехнологичный сервис онлайн регистрации участников для организаторов мероприятий, семинаров и событий.", "Light The Night in Cinema", "Didorovka Trail Run – это интереснейший трейловый горный забег в Голосеево. Трасса не оставит вас равнодушными! Спуски и подъемы, торчки и тягуны, живописные лесные тропинки и петляющие дорожки!", "«ГОНКА НАЦІЇ» — вражаючі забіги з перешкодами. Навіть якщо Ви раніше приймали участь в марафонах, тріатлоні, пейтбольних іграх, займаєтесь CrossFit чи іншими видами активного спорту, «ГОНКА НАЦІЇ» стане для Вас справжнім випробуванням та справжньою авантюрою, яка по силах кожному, тому кожен повинен це спробувати."]
        pictureList = [UIImage(named:"PhotoExample1")!, UIImage(named:"PhotoExample2")!, UIImage(named:"PhotoExample4")!, UIImage(named:"PhotoExample3")!]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
        return pictureList.count
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let eventCell = collectionView.dequeueReusableCellWithReuseIdentifier("EventCell", forIndexPath: indexPath) as! EventCollectionCell
        
        let title:NSString = eventsList[indexPath.item]
        
        let commentHeight = title.heightForText(title, viewWidth: cellWidth, device: nil)
        let height = commentHeight + 4 * 2
        
        eventCell.titleLabel.text = title as String
        eventCell.image.image = pictureList[indexPath.row]
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
        
        let photo = pictureList[indexPath.item]
        let boundingRect =  CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        let rect  = AVMakeRectWithAspectRatioInsideRect(photo.size, boundingRect)
        return rect.size.height
    }
    
    func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
        
        cellWidth = width
        
        let annotationPadding = CGFloat(4)
        let text:NSString = eventsList[indexPath.item]
        let commentHeight = text.heightForText(text, viewWidth: width, device: nil)
        let height = commentHeight + annotationPadding * 2
        
        return height
    }
    
    
}
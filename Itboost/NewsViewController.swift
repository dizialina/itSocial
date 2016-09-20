//
//  NewsViewController.swift
//  Itboost
//
//  Created by Alina Yehorova on 19.09.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit

class NewsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var refreshControl:UIRefreshControl!
    var loadMoreView:NewsFooterCell?
    var loadMoreStatus = false
    var currentNewsPage = 1
    var newsArray = [News]()
    
    // Temp
    var numberOfTestCells = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getNews()
        
        // Set footer for pull to refresh
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.clear
        collectionView.addSubview(refreshControl)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /*
        currentNewsPage = 1
        newsArray.removeAll()
        collectionView.reloadData()
        getNews()
        */
        
        // Make navigation bar translucent
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        let navigationBackgroundView = self.navigationController?.navigationBar.subviews.first
        navigationBackgroundView?.alpha = 0.3
        
        navigationController?.hidesBarsOnSwipe = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Get data methods
    
    func getNews() {
        
        ServerManager().getNews(currentNewsPage, success: { (response) in
            self.newsArray += ResponseParser().parseNews(response!)
            self.currentNewsPage += 1
            
            //self.numberOfTestCells += 2
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        }) { (error) in
            print("Error receiving news: " + error!.localizedDescription)
        }
        
    }
    
    //MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newsArray.count
        //return numberOfTestCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
        let newsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCollectionCell", for: indexPath) as! NewsCollectionCell
        
        let currentNews = newsArray[indexPath.row]
        
        if currentNews.authorUsername.characters.count > 0 {
            newsCell.authorLabel.text = currentNews.authorUsername
        }
        
        if currentNews.content.characters.count > 0 {
            newsCell.bodyLabel.text = currentNews.content
        }
        
        if currentNews.title.characters.count > 0 {
            newsCell.titleLabel.text = currentNews.title
        }
        
        newsCell.dateLabel.text = convertDateToText(currentNews.createdAt)
        
        // Set actions for cell buttons
        
        newsCell.openCommentsButton.addTarget(self, action: #selector(NewsViewController.openComments(_:)), for: UIControlEvents.touchUpInside)
        
        newsCell.readFullButton.addTarget(self, action: #selector(NewsViewController.openDetailNews(_:)), for: UIControlEvents.touchUpInside)
        newsCell.readFullButton.tag = indexPath.row
        
        // Make avatar image round
    
        newsCell.authorAvatar.layer.cornerRadius = 33 / 2
        newsCell.authorAvatar.clipsToBounds = true
        
        // Set shadow for cell
            
        newsCell.layer.shadowColor = UIColor.black.cgColor
        newsCell.layer.shadowRadius = 2.0
        newsCell.layer.shadowOpacity = 0.3
        newsCell.layer.shadowOffset = CGSize(width: 3, height: 3)
        newsCell.clipsToBounds = false
        newsCell.layer.shadowPath = UIBezierPath(rect: newsCell.layer.bounds).cgPath
        
        return newsCell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let newsFooter = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "NewsFooter", for: indexPath) as! NewsFooterCell
        loadMoreView = newsFooter
        return newsFooter
        
    }
    
    //MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
            return CGSize(width: self.view.frame.width, height: 344)
    }
    
    // MARK: Actions
    
    func openComments(_ sender: UIButton) {
        
    }
    
    func openDetailNews(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showNewsDetail", sender: sender.tag)
    }
    
    // MARK: Refreshing Collection
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 0 {
            loadMore()
        }
    }
    
    func loadMore() {
        if !loadMoreStatus {
            self.loadMoreStatus = true
            self.loadMoreView?.activityIndicator.startAnimating()
            self.loadMoreView?.loadMoreLabel.isHidden = false
            loadMoreBegin("Load more",
                          loadMoreEnd: {(x:Int) -> () in
                            self.collectionView.reloadData()
                            self.loadMoreStatus = false
                            self.loadMoreView?.activityIndicator.stopAnimating()
                            self.loadMoreView?.loadMoreLabel.isHidden = true
            })
        }
    }
    
    func loadMoreBegin(_ newtext:String, loadMoreEnd:@escaping (Int) -> ()) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            print("loadmore")
            
            if self.currentNewsPage != 1 {
                self.getNews()
            }
            
            sleep(2)
            
            DispatchQueue.main.async {
                loadMoreEnd(0)
            }
        }
    }
    
    // MARK: Helping methods
    
    func convertDateToText(_ date:Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM в HH:mm"
        return dateFormatter.string(from: date)
    }
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "showNewsDetail") {
            let viewController = segue.destination as! DetailNewsViewController
            viewController.currentNews = newsArray[sender as! Int]
        }
        
    }
        
}

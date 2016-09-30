//
//  MembersViewController.swift
//  Itboost
//
//  Created by Alina Yehorova on 29.09.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit

class MembersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var membersResponseList = [AnyObject]()
    var membersList = [Member]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        navigationController?.navigationBar.barTintColor = Constants.darkMintBlue
        let navigationBackgroundView = self.navigationController?.navigationBar.subviews.first
        navigationBackgroundView?.alpha = 1.0
        
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.membersList = ResponseParser().parseMembers(membersResponseList)
        loadAvatars()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func loadAvatars() {
        
        for member in membersList {
            
            if let avatarURL = member.avatarURL {
                let downloadImageTask = URLSession.shared.dataTask(with: avatarURL) { (data, response, error) in
                    if data != nil {
                        let avatar = UIImage(data: data!)
                        member.avatarImage = avatar
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
                downloadImageTask.resume()
            }
        }
    }
    
    // MARK: TableView DataSource and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return membersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let memberCell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as! MemberCell
        
        let member = membersList[indexPath.row]
        
        if let username = member.username {
            memberCell.memberName.text = username
        }
        
        if let birthday = member.birthday {
            memberCell.memberBirthday.text = "Дата рождения: \(birthday)"
        }
        
        if let email = member.email {
            memberCell.emailLabel.text = "E-mail: \(email)"
        }
        
        if member.adress.count > 0 {
            memberCell.memberAdress.text = member.adress.joined(separator: ", ")
        } else {
            memberCell.memberAdress.text = "Проживает: Не указано"
        }
        
        if let avatarImage = member.avatarImage {
            memberCell.avatarImage.image = avatarImage
        } else {
            memberCell.avatarImage.image = UIImage(named: "AvatarDefault")
        }
        
        // Make avatar image round
            
        memberCell.avatarImage.layer.cornerRadius = 75 / 2
        memberCell.avatarImage.clipsToBounds = true
            
        return memberCell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 91.0
    }

    
    
}

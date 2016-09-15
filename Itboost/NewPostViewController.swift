//
//  NewPostViewController.swift
//  Itboost
//
//  Created by Admin on 10.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit
/*
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}
*/

class NewPostViewController: UIViewController {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var postBodyTextView: UITextView!
    
    var wallThreadID = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Новая запись"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendPost(_ sender: AnyObject) {
        
        if (titleField.text?.characters.count)! > 0 && postBodyTextView.text.characters.count > 0 {
            let threadIDsDict = ["id": wallThreadID]
            
            ServerManager().postNewMessageOnWall(threadIDsDict, title: titleField.text!, body: postBodyTextView.text, success: { (response) in
                self.showAlertWithHandler()
            }, failure: { (error) in
                print("Error while adding new post on wall: " + error!.localizedDescription)
            })
            
        }
    }
    
    // MARK: TextField and TextView Delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    // MARK: Helping methods
    
    func showAlertWithHandler() {
        
        let alertController = UIAlertController(title: "Готово", message: "Вы успешно опубликовали запись", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (alertAction) in
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

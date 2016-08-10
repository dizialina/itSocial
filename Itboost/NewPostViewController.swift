//
//  NewPostViewController.swift
//  Itboost
//
//  Created by Admin on 10.08.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit

class NewPostViewController: UIViewController {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var postBodyTextView: UITextView!
    
    var wallThreadID = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Новая запись"
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendPost(sender: AnyObject) {
        
        if titleField.text?.characters.count > 0 && postBodyTextView.text.characters.count > 0 {
            let threadIDsDict = ["id": wallThreadID]
            
            ServerManager().postNewMessageOnWall(threadIDsDict, title: titleField.text!, body: postBodyTextView.text, success: { (response) in
                self.showAlertWithHandler()
            }, failure: { (error) in
                print("Error while adding new post on wall: " + error!.localizedDescription)
            })
            
        }
    }
    
    // MARK: TextField and TextView Delegates
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    // MARK: Helping methods
    
    func showAlertWithHandler() {
        
        let alertController = UIAlertController(title: "Готово", message: "Вы успешно опубликовали запись", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (alertAction) in
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}

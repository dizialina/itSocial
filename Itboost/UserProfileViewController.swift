//
//  UserProfileViewController.swift
//  Itboost
//
//  Created by Alina Yehorova on 21.09.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit

public enum Direction: Int {
    case Up
    case Down
    case Left
    case Right
    
    public var isX: Bool { return self == .Left || self == .Right }
    public var isY: Bool { return !isX }
}

public extension UIPanGestureRecognizer {
    
    public var direction: Direction? {
        let velo = velocity(in: view)
        let vertical = fabs(velo.y) > fabs(velo.x)
        switch (vertical, velo.x, velo.y) {
        case (true, _, let y) where y < 0: return .Up
        case (true, _, let y) where y > 0: return .Down
        case (false, let x, _) where x > 0: return .Right
        case (false, let x, _) where x < 0: return .Left
        default: return nil
        }
    }
}

class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var bottomSpaceInfoViewToView: NSLayoutConstraint!
    
    var lastTranslation = CGPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(UserProfileViewController.panView(_:)))
        infoView.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bottomSpaceInfoViewToView.constant = -100.0
        
    }

    
    
    func panView(_ sender: UIPanGestureRecognizer) {
        //273
        
        //let yTouchPosition = sender.translation(in: self.view).y
        
        //if yTouchPosition < 273 {
            //UIView.animate(withDuration: 1.0) {
                //self.infoView.frame = CGRect(x: self.infoView.frame.origin.x, y: yTouchPosition, width: self.infoView.frame.size.width, height: self.infoView.frame.size.height)
            //}
        //}
        
        if bottomSpaceInfoViewToView.constant == -100 && sender.direction == .Up {
            UIView.animate(withDuration: 0.3) {
                self.bottomSpaceInfoViewToView.constant = 0
                self.view.layoutIfNeeded()
            }
        } else if bottomSpaceInfoViewToView.constant == 0 && sender.direction == .Down {
            UIView.animate(withDuration: 0.3) {
                self.bottomSpaceInfoViewToView.constant = -100
                self.view.layoutIfNeeded()
            }
        }
        
        
    }
    
}

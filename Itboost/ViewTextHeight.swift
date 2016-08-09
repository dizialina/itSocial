//
//  ViewTextHeight.swift
//  Itboost
//
//  Created by Admin on 19.07.16.
//  Copyright © 2016 Alina Egorova. All rights reserved.
//

import Foundation
import UIKit

extension NSString {
    
    func heightForText(text:NSString, viewWidth:CGFloat, offset:CGFloat, device:String?) -> CGFloat {
        
        var font = UIFont.systemFontOfSize(15.0)
        
        if device == "iPad" {
            font = UIFont.systemFontOfSize(23.0)
        }
        
        let fontColor = UIColor.whiteColor()
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = NSTextAlignment.Justified
        paragraph.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        let attributes:NSDictionary = [NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraph, NSForegroundColorAttributeName:fontColor]
        
        let options: NSStringDrawingOptions = [.UsesLineFragmentOrigin, .UsesFontLeading]
        
        let rect = text.boundingRectWithSize(CGSizeMake(viewWidth - 2 * offset, CGFloat.max), options: options, attributes: attributes as? [String : AnyObject], context: nil)
        
        return CGRectGetHeight(rect) + 2 * offset
        
    }
    
    
}

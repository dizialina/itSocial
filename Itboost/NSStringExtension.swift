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
    
    func heightForText(_ text:NSString, neededFont:UIFont, viewWidth:CGFloat, offset:CGFloat, device:String?) -> CGFloat {
        
        //var font = UIFont.systemFontOfSize(fontSize)
        var font = neededFont
        
        if device == "iPad" {
            font = UIFont.systemFont(ofSize: 23.0)
        }
        
        let fontColor = UIColor.white
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = NSTextAlignment.justified
        paragraph.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        let attributes:NSDictionary = [NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraph, NSForegroundColorAttributeName:fontColor]
        
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        
        let rect = text.boundingRect(with: CGSize(width: viewWidth - 2 * offset, height: CGFloat.greatestFiniteMagnitude), options: options, attributes: attributes as? [String : AnyObject], context: nil)
        
        return rect.height + 2 * offset
        
    }
    
    func widthForText(_ text:NSString, viewHeight:CGFloat, offset:CGFloat, device:String?) -> CGFloat {
        
        var font = UIFont.systemFont(ofSize: 14.0)
        
        if device == "iPad" {
            font = UIFont.systemFont(ofSize: 23.0)
        }
        
        let fontColor = UIColor.black
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = NSTextAlignment.justified
        paragraph.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        let attributes:NSDictionary = [NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraph, NSForegroundColorAttributeName:fontColor]
        
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        
        let rect = text.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: viewHeight - 2 * offset), options: options, attributes: attributes as? [String : AnyObject], context: nil)
        
        return rect.width + 2 * offset
        
    }
    
    
}

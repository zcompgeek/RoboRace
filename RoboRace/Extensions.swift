//
//  Extensions.swift
//  CookieCrunch
//
//  Created by Zach Costa on 7/28/14.
//  Copyright (c) 2014 Zach Costa. All rights reserved.
//

import Foundation
import SpriteKit

extension Dictionary {
    static func loadJSONFromBundle(filename: String) -> Dictionary<String, AnyObject>? {
        let path = NSBundle.mainBundle().pathForResource(filename, ofType: "json")
        if !path {
            println("Could not find level file: \(filename)")
            return nil
        }
        
        var error: NSError?
        let data: NSData? = NSData(contentsOfFile: path, options: NSDataReadingOptions(),
            error: &error)
        if !data {
            println("Could not load level file: \(filename), error: \(error!)")
            return nil
        }
        
        let dictionary: AnyObject! = NSJSONSerialization.JSONObjectWithData(data,
            options: NSJSONReadingOptions(), error: &error)
        if !dictionary {
            println("Level file '\(filename)' is not valid JSON: \(error!)")
            return nil
        }
        
        return dictionary as? Dictionary<String, AnyObject>
    }
}

extension Int {
    func toRad() -> CGFloat {
        return CGFloat(self) * pi / CGFloat(180.0)
    }
}
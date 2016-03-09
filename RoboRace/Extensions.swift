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
        if !(path != nil) {
            print("Could not find level file: \(filename)")
            return nil
        }
        do {
            let data: NSData? = try NSData(contentsOfFile: path!, options: NSDataReadingOptions())
            if !(data != nil) {
                print("Could not load level file: \(filename)")
                return nil
            }

            let dictionary: AnyObject! = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions())
            if !(dictionary != nil) {
                print("Level file '\(filename)' is not valid JSON")
                return nil
            }
            return dictionary as? Dictionary<String, AnyObject>
        } catch {
            print("Error")
            return nil
        }
        
    }
}

extension Int {
    func toRad() -> CGFloat {
        return CGFloat(self) * pi / CGFloat(180.0)
    }
}
//
//  Parser.swift
//  DHOW
//
//  Created by Rakesh on 21/02/18.
//  Copyright © 2018 vipra. All rights reserved.
//

import UIKit

class Parser: NSObject {
    
    // Can't init is singleton
    private override init() { }
    // MARK: Shared Instance
    static let shared = Parser()
    
    func getDictionaryFrom(data:AnyObject!, key:String) -> [String:Any] {
        if let val = data.value(forKey: key) as? [String:Any] {
            return val
        }
        return [:]
    }
    func getAnyObjectFrom(data:AnyObject!, key:String) -> AnyObject {
        return data.value(forKey: key) as AnyObject
    }
    func getArrayFrom(data:AnyObject!, key:String) -> Array<AnyObject> {
        if let val = data.value(forKey: key) as? Array<AnyObject> {
            return val
        }
        return Array<AnyObject>()
    }
    
    func getStringFrom(data:AnyObject!, key:String) -> String {
        if let val = data.value(forKey: key) as? String {
            return val
        }
        return ""
    }
    func getIntFrom(data:AnyObject!, key:String) -> Int {
        if let val = data.value(forKey: key) as? Int {
            return val
        }
        return 100000000
    }
}



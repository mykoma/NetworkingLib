//
//  HttpTransaction+Private.swift
//  Networking
//
//  Created by Apple on 2016/11/4.
//  Copyright © 2016年 goluk. All rights reserved.
//

import Foundation

extension HttpTransaction {
    
    public func toParameters() -> [String: AnyObject] {
        var dic:[String: AnyObject] = [:]
        let count = UnsafeMutablePointer<UInt32>.alloc(0)
        let buff = class_copyPropertyList(object_getClass(self), count)
        let countInt = Int(count[0])
        let excludeList = self.excludeParameters()
        for i in 0 ..< countInt {
            let temp = buff[i]
            let tempPro = property_getName(temp)
            guard let proper = String.init(UTF8String: tempPro) else {
                continue
            }
            guard excludeList.contains(proper) == false else {
                continue
            }
            let value: AnyObject? = self.valueForKey(proper)
            dic[proper] = value
        }
        
        return dic
    }
    
    public func toSuburiFromParameters() -> String {
        let parameters: [String: AnyObject] = self.toParameters()
        let urlString = NSMutableString()
        for (key, value) in parameters {
            urlString.appendString(key)
            urlString.appendString("=")
            urlString.appendString(String(value))
            urlString.appendString("&")
        }
        if urlString.hasSuffix("&") {
            urlString.deleteCharactersInRange(NSMakeRange(urlString.length - 1, 1))
        }
        return urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    }
    
}

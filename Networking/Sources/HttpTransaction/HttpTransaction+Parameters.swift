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
        let propertiesList = self.properties()
        
        var dic:[String: AnyObject] = [:]
        let excludeList = self.excludeParameters()
        for (key, value) in propertiesList {
            guard excludeList.contains(key) == false else {
                continue
            }
            dic[key] = value
        }
        return dic
    }

    public func toSuburiFromParameters() -> String {
        let parameters: [String: AnyObject] = self.toParameters()
        let urlString = NSMutableString()
        for (key, value) in parameters {
            urlString.append(key)
            urlString.append("=")
            urlString.append(String(describing: value))
            urlString.append("&")
        }
        if urlString.hasSuffix("&") {
            urlString.deleteCharacters(in: NSMakeRange(urlString.length - 1, 1))
        }
        return urlString.addingPercentEscapes(using: String.Encoding.utf8.rawValue)!
    }
    
}


extension NSObject {
    
    func properties(notNull: Bool = true) -> [String: AnyObject] {
        let mirror = Mirror.init(reflecting: self)
        
        var dict:[String: AnyObject] = [:]
        mirror.eachChild { (child) in
            if let label = child.label {
                let value = child.value as AnyObject
                if value.isKind(of: NSNull.self) && notNull == true { // If
                    // Empty
                } else {
                    dict[label] = value as AnyObject
                }
            }
        }
        return dict
    }
    
}

extension Mirror {
    
    func eachChild(_ iterator: ( (Child) -> Void )) {
        if let mirror = self.superclassMirror {
            mirror.eachChild(iterator)
        }
        
        for child in self.children {
            iterator(child)
        }
    }
    
}

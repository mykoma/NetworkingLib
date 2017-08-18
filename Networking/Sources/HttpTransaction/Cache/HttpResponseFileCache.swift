//
//  HttpResponseFileCache.swift
//  CrazyPanda
//
//  Created by apple on 16/7/14.
//  Copyright © 2016年 Goluk. All rights reserved.
//

import Foundation

public class HttpResponseFileCache: NSObject, HttpResponseCache {
    
    public var cacheFilePathName : String {
        self.doesNotRecognizeSelector(#function)
        return ""
    }
    
    public func cacheResponse(response: AnyObject!) {
        var sp = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
        guard sp.count > 0 else {
            return
        }
        let url = NSURL(fileURLWithPath: "\(sp[0])/\(cacheFilePathName)")
        let str = NSMutableString()
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: response, options: JSONSerialization.WritingOptions.prettyPrinted)
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
            str.append(jsonString!)
            try str.write(toFile: url.path!, atomically: true, encoding: String.Encoding.utf8.rawValue)
        } catch _ {
        }
    }
    
    public func loadResponse() -> AnyObject?{
        var sp = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
        guard sp.count > 0 else {
            return nil
        }
        let url = NSURL(fileURLWithPath: "\(sp[0])/\(cacheFilePathName)")
        var dict : AnyObject?
        do {
            let jsonString = try NSString(contentsOfFile: url.path!, encoding: String.Encoding.utf8.rawValue)
            dict = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding.utf8.rawValue)!, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
        } catch _ {
        }
        guard let retDict = dict else {
            return nil
        }
        return retDict
    }

}

//
//  HttpResponseFileCache.swift
//  CrazyPanda
//
//  Created by apple on 16/7/14.
//  Copyright © 2016年 Goluk. All rights reserved.
//

import Foundation
import CocoaLumberjack

public class HttpResponseFileCache: NSObject, HttpResponseCache {
    
    public var cacheFilePathName : String {
        DDLogError("Must override >>cacheFilePathName<< in subclass of HttpResponseFileCache")
        self.doesNotRecognizeSelector(#function)
        return ""
    }
    
    public func cacheResponse(response: AnyObject!) {
        var sp = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true)
        guard sp.count > 0 else {
            return
        }
        let url = NSURL(fileURLWithPath: "\(sp[0])/\(cacheFilePathName)")
        let str = NSMutableString()
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(response, options: NSJSONWritingOptions.PrettyPrinted)
            let jsonString = String(data: jsonData, encoding: NSUTF8StringEncoding)
            str.appendString(jsonString!)
            try str.writeToFile(url.path!, atomically: true, encoding: NSUTF8StringEncoding)
        } catch _ {
        }
    }
    
    public func loadResponse() -> AnyObject?{
        var sp = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true)
        guard sp.count > 0 else {
            return nil
        }
        let url = NSURL(fileURLWithPath: "\(sp[0])/\(cacheFilePathName)")
        var dict : AnyObject?
        do {
            let jsonString = try NSString(contentsOfFile: url.path!, encoding: NSUTF8StringEncoding)
            dict = try NSJSONSerialization.JSONObjectWithData(jsonString.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments)
        } catch _ {
        }
        guard let retDict = dict else {
            return nil
        }
        return retDict
    }

}
